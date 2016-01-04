-- Final Fantasy VI Bot

local config = {}
config.TARGET_LEVEL = 99
config.HP_FLOOR_PCT = 0.65
config.MP_FLOOR = 20
config.USE_TURBO = true
config.UNATTENDED = true
config.LEFT_RIGHT = true

local SPELL_CURE_1 = 0x0E
local SPELL_CURE_2 = 0x0F
local SPELL_HEAL = 0x12

local SPELL_LIGHTNING_2 = 0x24

-- sorted pairs
function spairs(t, order)
  -- collect the keys
  local keys = {}
  for k in pairs(t) do keys[#keys+1] = k end
  
  -- if order function given, sort by it by passing the table and keys a, b
  -- otherwise just sort the keys
  if order then
    table.sort(keys, function(a, b) return order(t, a, b) end)
  else
    table.sort(keys)
  end
  
  -- return the iterator function
  local i = 0
  return function()
    i = i + 1
    if keys[i] then
      return keys[i], t[keys[i]]
    end
  end
end

-- base state class
State = {}

function State:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function State:getPriority()
  return -1
end

function State:needToRun(game_context, bot_context)
  return false
end

function State:getText(game_context, bot_context)
  return ""
end

function State:run(game_context, bot_context)
end

-- idle
IdleState = State:new()

function IdleState:getPriority()
  return 0
end

function IdleState:needToRun(game_context, bot_context)
  return true
end

function IdleState:getText(game_context, bot_context)
  return "idle"
end

function IdleState:run(game_context, bot_context)
end

-- find a battle
FindBattleState = State:new()

function FindBattleState:getPriority()
  return 1
end

function FindBattleState:needToRun(game_context, bot_context, keys)
  -- stop when we get low hp or weird status
  for character_index = 0,9 do
    local character = game_context.characters[character_index]
    if character.id == 0x00 or character.id == 0x01 or character.id == 0x06 or character.id == 0x0A then
      if character.current_hp < 2000 or character.status ~= 0 then
        return false
      end
    end
  end

  return game_context.battle.cursor_position > 110 and bot_context.has_uncapped_levels
end

function FindBattleState:getText(game_context, bot_context)
  return "find battle"
end

function FindBattleState:run(game_context, bot_context, keys)
  -- dismiss the dialog (by tapping 'A' on and off)
  -- if bot_context.tapping_a then 
  --   bot_context.tapping_a = false
  -- else
  --   bot_context.tapping_a = true
  --   keys.A = 1
  -- end
  if bot_context.tapping_left then
    bot_context.tapping_left = false
    bot_context.tapping_right = true
    keys.right = 1
  else
    bot_context.tapping_right = false
    bot_context.tapping_left = true
    keys.left = 1
  end
end

-- win a battle
WinBattleState = State:new()

function WinBattleState:getPriority()
  return 2
end

function WinBattleState:needToRun(game_context, bot_context)
  --emu.print(game_context.battle.cursor_position)
  return game_context.battle.cursor_position < 110 and game_context.battle.enemy_count > 0
end

function WinBattleState:getText(game_context, bot_context)
  return "win battle"
end

function WinBattleState:run(game_context, bot_context, keys)
  if game_context.battle.active_character == 0 then
    local locke_cursor = memory.readbyte(0x7E890F)
    if locke_cursor == 0 then
      keys.down = 1
    elseif locke_cursor == 1 then
      keys.A = 1
    elseif locke_cursor > 1 then
      keys.up = 1
    end
  else
    keys.A = 1
  end

  -- if game_context.battle.active_character == 3 then
  --   local banon_cursor = memory.readbyte(0x7E8912)
  --   if banon_cursor == 0 then
  --     keys.down = 1
  --   elseif banon_cursor == 1 then
  --     keys.A = 1
  --   elseif banon_cursor > 1 then
  --     keys.up = 1
  --   end
  -- else
  --   keys.A = 1
  -- end
end

-- idle
AcceptBattleRewardsState = State:new()

function AcceptBattleRewardsState:getPriority()
  return 5
end

function AcceptBattleRewardsState:needToRun(game_context, bot_context)
  return game_context.battle.cursor_position < 110 and game_context.battle.enemy_count == 0
end

function AcceptBattleRewardsState:getText(game_context, bot_context)
  return "accept battle rewards"
end

function AcceptBattleRewardsState:run(game_context, bot_context, keys)
  bot_context.is_save_required = true

  -- dismiss the dialog (by tapping 'A' on and off)
  if bot_context.dismissing_battle_dialog then 
    bot_context.dismissing_battle_dialog = false
  else
    bot_context.dismissing_battle_dialog = true
    keys.A = 1
  end
end

local function bitnumer(p)
  return 2 ^ (p - 1)  -- 1-based indexing
end

local function hasbit(x, p)
  return x % (p + p) >= p
end

local function getGameContext(game_context)
  game_context.characters = {}
  
  local readCharacterByte = function(character_index, offset)
    return memory.readbyte(0x7E1600 + (character_index * 0x25) + offset)
  end

  local readCharacterWord = function(character_index, offset)
    return memory.readword(0x7E1600 + (character_index * 0x25) + offset)
  end
  
  -- read character data  
  for character_index = 0,9 do
    local character = {}
    
    character.id = character_index -- memory.readbyte(0x7E0069 + character_index)
    
    character.level = readCharacterByte(character.id, 0x08)
    character.current_hp = readCharacterWord(character.id, 0x09)
    character.status = readCharacterByte(character.id, 0x14)
    --character.health = getCharacterHP(game_context, character_index)
    --character.magic = getCharacterMP(game_context, character_index)
    
    -- if game_context.is_in_battle then
    --   character.status = memory.readword(0x7E2000 + (character_index * 0x80) + 0x03)
    -- else
    --   character.status = memory.readword(0x7E1000 + (character_index * 0x40) + 0x03)
    -- end
    
    game_context.characters[character_index] = character
  end
  
  -- read battle data
    game_context.battle = {}

    --local post_battle_state = memory.readbyte(0x7E212D)
    --game_context.battle.enemy_count = memory.readbyte(0x7E29CD)
    --game_context.battle.cursor_state = memory.readbyte(0x7E1823)
    game_context.battle.cursor_position = memory.readbyte(0x7E890F)
    --game_context.battle.cursor_spell_position = memory.readbyte(0x7E0063)
    game_context.battle.enemy_target = memory.readbyte(0x7E7B7E)
    game_context.battle.active_character = memory.readbyte(0x7E0201)
    game_context.battle.enemy_count = memory.readbyte(0x7E2015)
    --game_context.battle.arrangement = memory.readbyte(0x7E29A3)
    --game_context.battle.is_back_attack = memory.readbyte(0x7E030B) == 0x71
    
end

-- this function should perform common aggregations on the game_context so they don't have to be
-- recalculated by each state. it should NOT directly indicate which states should run
local function getBotContext(game_context, bot_context)
  bot_context.has_uncapped_levels = false

  -- check for uncapped levels
  for character_index = 0,9 do
    local character = game_context.characters[character_index]
    if character.level < config.TARGET_LEVEL then
      bot_context.has_uncapped_levels = true
    end
  end
  
  -- if bot_context.save_state == nil then
  --   bot_context.save_state = savestate.create()
  --   bot_context.is_save_required = game_context.is_in_overworld
  -- end
  -- 
  -- if game_context.is_in_battle and not bot_context.was_in_battle then
  --   bot_context.wait_for_turn = true
  -- end
  -- 
  -- bot_context.was_in_battle = game_context.is_in_battle
  -- 
  -- if bot_context.wait_for_turn and game_context.battle.cursor_state ~= 0 then
  --   bot_context.wait_for_turn = false
  -- end
  
  return bot_context
end

do
  local bot_context = {}
  local game_context = {}
  
  local states = {}
  states[0] = IdleState:new()
  states[1] = FindBattleState:new() -- spam 'A'
  states[2] = WinBattleState:new() -- spam 'A' except for banon
  states[3] = AcceptBattleRewardsState:new() -- spam 'A'
  --states[4] = HealCharacterState:new()
  --states[5] = SaveGameState:new()  
  --states[6] = ReloadGameState:new()
  --states[7] = HealCharacterStatusState:new()
  -- states[6] = UseMysidiaInnState:new()
  
  local state_to_run = nil
  
  while true do
    local keys = joypad.get(1)
    
    if config.UNATTENDED or keys.Y then
      if config.USE_TURBO then emu.speedmode("turbo") end
    
      getGameContext(game_context)
      getBotContext(game_context, bot_context)
      
      -- loop through the states in descending priority order to find the appropriate state to run
      for index,state in spairs(states, function(t, a, b) return t[a]:getPriority() > t[b]:getPriority() end) do
        if state:needToRun(game_context, bot_context, keys) then
          gui.text(0, 0, state:getText(game_context, bot_context))

          -- don't do anything if something is already happening (map is scrolling, attack animations are occurring, etc)  
          if not game_context.is_something_happening then
            state:run(game_context, bot_context, keys)
          end
          
          break
        end
      end
      
      joypad.set(1, keys)
    elseif not config.UNATTENDED then
      emu.speedmode("normal")
    end
  
    emu.frameadvance()
  end
end
