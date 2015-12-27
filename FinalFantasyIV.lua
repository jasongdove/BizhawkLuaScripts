-- Final Fantasy IV Bot

local config = {}
config.TARGET_LEVEL = 55
config.HP_FLOOR_PCT = 0.5
config.MP_FLOOR = 5
config.USE_TURBO = false
config.UNATTENDED = true
config.LEFT_RIGHT = true

local SPELL_CURE_1 = 14
local SPELL_CURE_2 = 15

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

local function fightEnemy(game_context, keys, target_enemy)
  if game_context.battle.cursor_state == 0x01 then -- base menu
    if game_context.battle.cursor_position ~= 0 then
      -- scroll to the 'fight' menu
      keys.up = 1
    else
      -- 'fight'
      keys.A = 1
    end
  elseif game_context.battle.cursor_state == 0x04 then -- select target
    if game_context.battle.cursor_target > target_enemy then keys.left = 1
    elseif game_context.battle.cursor_target < target_enemy then keys.right = 1
    else
      keys.A = 1
    end
  else
    -- back out of any other menu
    keys.B = 1
  end
end

local function getWhiteSpellIndex(game_context, character_index, spell_id)
  local character = game_context.characters[character_index]

  if character ~= nil then
    if character.id == 1 then -- cecil
      for spell_index = 0,23 do
        if memory.readbyte(0x7E1560 + spell_index) == spell_id then
          return spell_index
        end
      end
    elseif character.id == 16 then -- rosa
      for spell_index = 0,23 do
        if memory.readbyte(0x7E1608 + spell_index) == spell_id then
          return spell_index
        end
      end
    end
  end

  return nil
end

local function getBlackSpellIndex(game_context, character_index, spell_id)
  local character = game_context.characters[character_index]

  if character ~= nil and character.id == 17 then -- rydia
    for spell_index = 0,23 do
      if memory.readbyte(0x7E15A8 + spell_index) == spell_id then
        return spell_index
      end
    end
  end

  return nil
end

local function castWhiteMagic(game_context, keys, spell_index, target_character)
  if game_context.battle.cursor_state == 0x01 then
    -- select 'white' magic menu item
    if game_context.battle.cursor_position == 0 then keys.down = 1
    elseif game_context.battle.cursor_position == 1 then keys.A = 1
    elseif game_context.battle.cursor_position > 1 then keys.up = 1
    end
  elseif game_context.battle.cursor_state == 0x06 then
    -- select the spell to cast
    if game_context.battle.cursor_spell_position < spell_index then keys.right = 1
    elseif game_context.battle.cursor_spell_position > spell_index then keys.left = 1
    else keys.A = 1
    end
  elseif game_context.battle.cursor_state == 0x0C then
    -- select the character and queue the spell
    if game_context.battle.cursor_target ~= target_character + 8 then
      keys.up = 1
    else
      keys.A = 1
    end
  end
end

local function castBlackMagic(game_context, keys, spell_index, target_enemy)
  if game_context.battle.cursor_state == 0x01 then
    -- select 'black' magic menu item
    if game_context.battle.cursor_position == 0 then keys.down = 1
    elseif game_context.battle.cursor_position == 1 then keys.A = 1
    elseif game_context.battle.cursor_position > 1 then keys.up = 1
    end
  elseif game_context.battle.cursor_state == 0x06 then
    -- select the spell to cast
    if game_context.battle.cursor_spell_position < spell_index then keys.right = 1
    elseif game_context.battle.cursor_spell_position > spell_index then keys.left = 1
    else keys.A = 1
    end
  elseif game_context.battle.cursor_state == 0x0C then
    -- select the target and queue the spell
    if game_context.battle.cursor_target ~= target_enemy then
      keys.right = 1
    else
      keys.A = 1
    end
  end
end

local function fightMeleeEnemy(game_context, keys)
  -- find a melee target
  local melee_target = -1
  
  for enemy_index = 0,7 do
    local enemy = game_context.battle.enemies[enemy_index]
    if enemy ~= nil and enemy.is_alive and enemy.defense < 100 then
      melee_target = enemy_index
      break
    end
  end
  
  if melee_target >= 0 then
    fightEnemy(game_context, keys, melee_target)
  else
    -- auto attack as a fallback
    if game_context.battle.cursor_state == 0x01 then
      if game_context.battle.cursor_position ~= 0 then
        -- scroll to the 'fight' menu item
        keys.up = 1
      else
        -- 'fight'
        keys.A = 1
      end
    elseif game_context.battle.cursor_state == 0x04 then
      -- auto attack
      keys.A = 1
    else
      -- back out of any other menu
      keys.B = 1
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
  if game_context.is_in_battle or (not config.UNATTENDED and not keys.select) then return false end
  
  return bot_context.has_uncapped_levels
end

function FindBattleState:getText(game_context, bot_context)
  return "find battle"
end

function FindBattleState:run(game_context, bot_context, keys)
  bot_context.find_battle_direction = bot_context.find_battle_direction or 1
  -- 0: N, 1: W, 2: S, 3: E

  if config.LEFT_RIGHT then
    if bot_context.find_battle_direction == 0 or bot_context.find_battle_direction == 1 then
      if game_context.overworld_x == bot_context.previous_overworld_x then
        keys.left = nil
        bot_context.find_battle_direction = 3
      end
    elseif bot_context.find_battle_direction == 2 or bot_context.find_battle_direction == 3 then
      if game_context.overworld_x == bot_context.previous_overworld_x then
        keys.right = nil
        bot_context.find_battle_direction = 1
      end
    end
  else
    if bot_context.find_battle_direction == 0 then
      if game_context.overworld_y == bot_context.previous_overworld_y then
        keys.up = nil
        bot_context.find_battle_direction = math.fmod(bot_context.find_battle_direction + 1, 4)
      end
    elseif bot_context.find_battle_direction == 1 then
      if game_context.overworld_x == bot_context.previous_overworld_x then
        keys.left = nil
        bot_context.find_battle_direction = math.fmod(bot_context.find_battle_direction + 1, 4)
      end
    elseif bot_context.find_battle_direction == 2 then
      if game_context.overworld_y == bot_context.previous_overworld_y then
        keys.down = nil
        bot_context.find_battle_direction = math.fmod(bot_context.find_battle_direction + 1, 4)
      end
    elseif bot_context.find_battle_direction == 3 then
      if game_context.overworld_x == bot_context.previous_overworld_x then
        keys.right = nil
        bot_context.find_battle_direction = math.fmod(bot_context.find_battle_direction + 1, 4)
      end
    end
  end

  if bot_context.find_battle_direction == 0 then
      keys.up = 1
  elseif bot_context.find_battle_direction == 1 then
      keys.left = 1
  elseif bot_context.find_battle_direction == 2 then
      keys.down = 1
  elseif bot_context.find_battle_direction == 3 then
      keys.right = 1
  end
  
  -- store our current location for checking the next time through
  bot_context.previous_overworld_x = game_context.overworld_x
  bot_context.previous_overworld_y = game_context.overworld_y
end

-- win a battle
WinBattleState = State:new()

function WinBattleState:getPriority()
  return 2
end

function WinBattleState:needToRun(game_context, bot_context)
  if not game_context.is_in_battle then return false end
  
  return true -- bot_context.has_uncapped_levels
end

function WinBattleState:getText(game_context, bot_context)
  return "win battle"
end

function WinBattleState:run(game_context, bot_context, keys)
  local character = game_context.characters[game_context.battle.active_character]
  
  if character.id == 17 then -- rydia
    -- check for a magic target
    local magic_target = -1
    
    for enemy_index = 0,7 do
      local enemy = game_context.battle.enemies[enemy_index]
      if enemy ~= nil and enemy.is_alive and enemy.defense >= 100 then
        magic_target = enemy_index
        break
      end
    end
    
    if magic_target ~= nil then
    
      -- cast spell against magic_target
      local lightning_spell_index = getBlackSpellIndex(game_context, game_context.battle.active_character, SPELL_LIGHTNING_2)
      if lightning_spell_index ~= nil then
        castBlackMagic(game_context, keys, lightning_spell_index, magic_target)
        return
      end
    end
  end

  fightMeleeEnemy(game_context, keys)
end

-- idle
AcceptBattleRewardsState = State:new()

function AcceptBattleRewardsState:getPriority()
  return 4
end

function AcceptBattleRewardsState:needToRun(game_context, bot_context)
  return game_context.is_in_battle and game_context.battle.enemy_count == 0
end

function AcceptBattleRewardsState:getText(game_context, bot_context)
  return "accept battle rewards"
end

function AcceptBattleRewardsState:run(game_context, bot_context, keys)
    -- dismiss the dialog (by tapping 'A' on and off)
    if bot_context.dismissing_battle_dialog then 
      bot_context.dismissing_battle_dialog = false
    else
      bot_context.dismissing_battle_dialog = true
      keys.A = 1
    end
end

HealCharacterState = State:new()

function HealCharacterState:getPriority()
  return 3
end

function HealCharacterState:needToRun(game_context, bot_context)
  if not game_context.is_in_battle then return false end
  
  for character_index = 0,4 do
    local character = game_context.characters[character_index]
    if character.health.is_low then
      return true
    end
  end
  
  return false
end

function HealCharacterState:getText(game_context, bot_context)
  return "heal character"
end

function HealCharacterState:run(game_context, bot_context, keys)
  -- find low hp character
  local low_hp_character_index
  for character_index = 0,4 do
    local character = game_context.characters[character_index]
    if character.health.is_low then
      low_hp_character_index = character_index
      break
    end
  end
  
  if low_hp_character_index == nil then return end
  
  local heal_character_index
  local cure_spell_index
  
  -- check active character for CURE
  local active_character = game_context.characters[game_context.battle.active_character]
  cure_spell_index = getWhiteSpellIndex(game_context, game_context.battle.active_character, SPELL_CURE_2) or getWhiteSpellIndex(game_context, game_context.battle.active_character, SPELL_CURE_1)
  --if cure_spell_index ~= nil then emu.print("sp in: " .. game_context.battle.active_character .. "/" .. cure_spell_index .. "/" .. active_character.magic.current_mp) end
  if cure_spell_index ~= nil and not active_character.magic.is_low then
    heal_character_index = game_context.battle.active_character
  else
    -- find first character with CURE
    for character_index = 0,4 do
      local character = game_context.characters[character_index]
      cure_spell_index = getWhiteSpellIndex(game_context, character_index, SPELL_CURE_2) or getWhiteSpellIndex(game_context, character_index, SPELL_CURE_1)
      --if cure_spell_index ~= nil then emu.print("sp in: " .. character_index .. "/" .. cure_spell_index .. "/" .. character.magic.current_mp) end
      if cure_spell_index ~= nil and not character.magic.is_low then
        heal_character_index = character_index
        break
      end
    end
  end
  
  if heal_character_index == nil then return end
  
  if game_context.battle.active_character ~= heal_character_index then
    -- melee to get to character who will cast HEAL
    fightMeleeEnemy(game_context, keys)
  else
    castWhiteMagic(game_context, keys, cure_spell_index, low_hp_character_index)
  end
end

local function bitnumer(p)
  return 2 ^ (p - 1)  -- 1-based indexing
end

local function hasbit(x, p)
  return x % (p + p) >= p
end

local function getCharacterHP(game_context, character_index)
  local hp = {}
  
  if game_context.is_in_battle then
    hp.current_hp = memory.readword(0x7E2000 + (character_index * 0x0080) + 0x07)
    hp.max_hp = memory.readword(0x7E2000 + (character_index * 0x0080) + 0x09)
  else
    hp.current_hp = memory.readword(0x7E1000 + (character_index * 0x0040) + 0x07)
    hp.max_hp = memory.readword(0x7E1000 + (character_index * 0x0040) + 0x09)
  end

  hp.is_low = hp.current_hp / hp.max_hp <= config.HP_FLOOR_PCT
  
  return hp
end

local function getCharacterMP(game_context, character_index)
  local mp = {}
  
  if game_context.is_in_battle then
    mp.current_mp = memory.readword(0x7E2000 + (character_index * 0x0080) + 0x0B)
    mp.max_mp = memory.readword(0x7E2000 + (character_index * 0x0080) + 0x0D)
  else
    mp.current_mp = memory.readword(0x7E1000 + (character_index * 0x0040) + 0x0B)
    mp.max_mp = memory.readword(0x7E1000 + (character_index * 0x0040) + 0x0D)   
  end
  
  --emu.print("mp: " .. character_index .. "/" .. mp.current_mp)
  
  mp.is_low = mp.current_mp < config.MP_FLOOR
  
  return mp
end

local function getGameContext(game_context)
  game_context.previous_overworld_scroll_x = game_context.previous_overworld_scroll_x or -1
  game_context.previous_overworld_scroll_y = game_context.previous_overworld_scroll_y or -1
  local overworld_scroll_x = memory.readword(0x7E066A)
  local overworld_scroll_y = memory.readword(0x7E066C)
  
  game_context.is_in_battle = memory.readbyte(0x7E0685) == 0x01
  -- game_context.room_number = memory.readbyte(0x0048)
  -- game_context.is_in_town = hasbit(memory.readbyte(0x002D), bitnumer(1))
  game_context.is_in_overworld = not game_context.is_in_battle
  game_context.is_moving_in_overworld = false
  if game_context.is_in_overworld then
    game_context.is_moving_in_overworld = overworld_scroll_x ~= game_context.previous_overworld_scroll_x
      or overworld_scroll_y ~= game_context.previous_overworld_scroll_y
      or memory.readbyte(0x7E06AB) ~= 0
  end
  
  
  game_context.is_something_happening = game_context.is_moving_in_overworld
  game_context.overworld_x = memory.readbyte(0x7E061A)
  game_context.overworld_y = memory.readbyte(0x7E061B)
  
  game_context.characters = {}
  
  local readCharacterByte = function(character_index, offset)
    return memory.readbyte(0x7E1000 + (character_index * 0x40) + offset)
  end

  -- read character data  
  for character_index = 0,4 do
    local character = {}
    
    character.id = math.fmod(readCharacterByte(character_index, 0x00), 64)
    character.level = readCharacterByte(character_index, 0x02)
    character.health = getCharacterHP(game_context, character_index)
    character.magic = getCharacterMP(game_context, character_index)
    
    game_context.characters[character_index] = character
  end
  
  -- read battle data
  if game_context.is_in_battle then
    game_context.battle = {}

    local post_battle_state = memory.readbyte(0x7E212D)
    game_context.battle.enemy_count = memory.readbyte(0x7E29CD)
    game_context.battle.cursor_state = memory.readbyte(0x7E1823)
    game_context.battle.cursor_position = memory.readbyte(0x7E0060)
    game_context.battle.cursor_spell_position = memory.readbyte(0x7E0063)
    game_context.battle.cursor_target = memory.readbyte(0x7EEF8D)
    game_context.battle.active_character = memory.readbyte(0x7E00D0)
    
    game_context.battle.enemies = {}
    for enemy_index = 0,7 do
      local enemy = {}
      
      enemy.is_alive = memory.readword(0x7E2287 + (enemy_index * 0x80)) ~= 0 -- current_hp ~= 0
      enemy.defense = memory.readbyte(0x7E2287 + (enemy_index * 0x80) + 0x23)
      enemy.magic_defense = memory.readbyte(0x7E2287 + (enemy_index * 0x80) + 0x1D)
      
      game_context.battle.enemies[enemy_index] = enemy
    end
    
    game_context.is_something_happening = game_context.is_something_happening or (game_context.battle.enemy_count > 0 and game_context.battle.cursor_state == 0x00)
  end

  game_context.previous_overworld_scroll_x = overworld_scroll_x
  game_context.previous_overworld_scroll_y = overworld_scroll_y
end

-- this function should perform common aggregations on the game_context so they don't have to be
-- recalculated by each state. it should NOT directly indicate which states should run
local function getBotContext(game_context, bot_context)
  bot_context.has_uncapped_levels = false

  for character_index = 0,4 do
    local character = game_context.characters[character_index]
    if character.id ~= 0 then
      -- check for uncapped levels
      if character.level < config.TARGET_LEVEL then
        bot_context.has_uncapped_levels = true
      end
    end
  end

  return bot_context
end

do
  local bot_context = {}
  local game_context = {}
  
  local states = {}
  states[0] = IdleState:new()
  states[1] = FindBattleState:new()
  states[2] = WinBattleState:new()
  states[3] = AcceptBattleRewardsState:new()
  states[4] = HealCharacterState:new()
  -- states[4] = SaveGameState:new()  
  -- states[5] = ReloadGameState:new()
  -- states[6] = UseMysidiaInnState:new()
  -- states[11] = EsunaCharacterState:new()
  
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
