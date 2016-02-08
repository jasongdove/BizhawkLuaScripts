local MAGIC_FIRE = 0x01
local MAGIC_FIRA = 0x02
local MAGIC_FIRAGA = 0x03
local MAGIC_BLIZZARD = 0x04
local MAGIC_BLIZZARA = 0x05
local MAGIC_BLIZZAGA = 0x06
local MAGIC_THUNDER = 0x07
local MAGIC_THUNDARA = 0x08
local MAGIC_THUNDAGA = 0x09
local MAGIC_WATER = 0x0A
local MAGIC_AERO = 0x0B
local MAGIC_BIO = 0x0C
local MAGIC_DEMI = 0x0D
local MAGIC_HOLY = 0x0E
local MAGIC_QUAKE = 0x11
local MAGIC_TORNADO = 0x12
local MAGIC_ULTIMA = 0x13
local MAGIC_CURE = 0x15
local MAGIC_CURA = 0x16
local MAGIC_CURAGA = 0x17
local MAGIC_LIFE = 0x18
local MAGIC_FULL_LIFE = 0x19
local MAGIC_REGEN = 0x1A
local MAGIC_ESUNA = 0x1B
local MAGIC_DISPEL = 0x1C
local MAGIC_PROTECT = 0x1D
local MAGIC_SHELL = 0x1E
local MAGIC_REFLECT = 0x1F
local MAGIC_DOUBLE = 0x21
local MAGIC_HASTE = 0x23
local MAGIC_SLOW = 0x24
local MAGIC_BLIND = 0x26
local MAGIC_CONFUSE = 0x27
local MAGIC_SLEEP = 0x28
local MAGIC_SILENCE = 0x29
local MAGIC_BREAK = 0x2A
local MAGIC_DEATH = 0x2B
local MAGIC_DRAIN = 0x2C
local MAGIC_PAIN = 0x2D
local MAGIC_BERSERK = 0x2E
local MAGIC_FLOAT = 0x2F
local MAGIC_ZOMBIE = 0x30
local MAGIC_MELTDOWN = 0x31
local MAGIC_SCAN = 0x32

local MAGIC_TO_IGNORE =
{
  [MAGIC_FIRE] = true,
  [MAGIC_FIRA] = true,
  [MAGIC_BLIZZARD] = true,
  [MAGIC_BLIZZARA] = true,
  [MAGIC_THUNDER] = true,
  [MAGIC_THUNDARA] = true,
  [MAGIC_WATER] = true,
  [MAGIC_AERO] = true,
  [MAGIC_DEMI] = true,
  [MAGIC_CURE] = true,
  [MAGIC_CURA] = true,
  [MAGIC_DOUBLE] = true,
  [MAGIC_SLOW] = true,
  [MAGIC_BLIND] = true,
  [MAGIC_SILENCE] = true,
  [MAGIC_DRAIN] = true,
  [MAGIC_FLOAT] = true,
  [MAGIC_ZOMBIE] = true,
  [MAGIC_SCAN] = true,
}

DrawState = State:new()

function DrawState:needToRun(game_context, bot_context)
  -- must be in battle
  if not game_context.battle.is_in_battle then
    return false
  end
  
  for character_index = 0,2 do
    if bot_context.characters[character_index].can_draw then
      return true
    end
  end
  
  return false
end

function DrawState:writeText(game_context, bot_context)
  gui.text(0, 0, "draw")
end

function DrawState:run(game_context, bot_context, keys)
  -- bail out if stuff is happening (no 'active' character)
  if game_context.battle.active_character == 0xFF then return end
  
  local character_to_draw = nil
  for character_index = 0,2 do
    local c = game_context.characters[character_index]
    if bot_context.characters[character_index].can_draw and c.can_act and bot_context.characters[character_index].can_act then
      character_to_draw = character_index
      break
    end
  end
  
  -- bail out if there isn't a character who can draw (who can also take a turn right now)
  if character_to_draw == nil then return end

  local character = game_context.characters[game_context.battle.active_character]
  
  -- if this character doesn't have draw, pass to the next character
  if not bot_context.characters[game_context.battle.active_character].can_draw then
    pressAndRelease(bot_context, keys, 'Circle')
    return
  end
  
  -- pass to a character who can draw
  if game_context.characters[character_to_draw].can_act and game_context.battle.active_character ~= character_to_draw then
    pressAndRelease(bot_context, keys, 'Circle')
    return
  end
  
  local enemy_to_draw = nil
  local magic_to_draw = nil
  
  for enemy_index = 0,3 do
    if game_context.battle.enemies[enemy_index].is_alive then
      for enemy_magic_index = 0,3 do
        local magic_id = game_context.battle.enemies[enemy_index].magic[enemy_magic_index].id
        
        -- skip spells we don't want
        if MAGIC_TO_IGNORE[magic_id] == nil then
          if game_context.battle.enemies[enemy_index].magic[enemy_magic_index].is_unknown then
            enemy_to_draw = enemy_index
            magic_to_draw = magic_id
            break
          end
          
          if magic_id > 0 then
            local has_magic = false
            for character_magic_index = 0,31 do
              if character.magic[character_magic_index].id == magic_id then
                has_magic = true
                if character.magic[character_magic_index].quantity < 100 then
                  enemy_to_draw = enemy_index
                  magic_to_draw = magic_id
                  break
                end
                break
              end
            end
            
            -- draw a new magic as long as we have room
            if not has_magic then
              for character_magic_index = 0,31 do
                if character.magic[character_magic_index].id == 0x00 then
                  enemy_to_draw = enemy_index
                  magic_to_draw = magic_id
                  break
                end
              end            
            end

            if enemy_to_draw ~= nil then break end
          end
        end
      end
    end
    
    if enemy_to_draw ~= nil then break end
  end
  
  gui.text(0, 30, 'character to draw: ' .. character_to_draw)
  gui.text(0, 45, 'enemy to draw: ' .. enemy_to_draw)
  gui.text(0, 60, 'magic to draw: ' .. magic_to_draw)
  
  -- couldn't find anything to draw, so pass to the next character
  if enemy_to_draw == nil then
    pressAndRelease(bot_context, keys, 'Circle')
  else
    -- do nothing if we aren't on the right character
    if game_context.battle.active_character ~= character_to_draw then
      return
    end
  
    -- select 'draw'
    if game_context.battle.is_main_menu_active then
      if game_context.battle.main_menu_index < 1 then
        pressAndRelease(bot_context, keys, 'Down')
      elseif game_context.battle.main_menu_index > 1 then
        pressAndRelease(bot_context, keys, 'Up')
      else
        pressAndRelease(bot_context, keys, 'Cross')
      end
    -- select enemy
    elseif game_context.battle.cursor_location == 0x03 then
      if game_context.battle.target_enemy ~= enemy_to_draw then
        pressAndRelease(bot_context, keys, 'Right')
      else
        pressAndRelease(bot_context, keys, 'Cross')
      end
    -- select magic to draw
    elseif game_context.battle.cursor_location == 0x0E then
      if game_context.battle.draw_magic_id ~= magic_to_draw then
        pressAndRelease(bot_context, keys, 'Down')
      else
        pressAndRelease(bot_context, keys, 'Cross')
      end
    -- select 'stock'
    elseif game_context.battle.cursor_location == 0x17 then
      if game_context.battle.draw_action ~= 0x00 then
        pressAndRelease(bot_context, keys, 'Down')
      else
        pressAndRelease(bot_context, keys, 'Cross')
        bot_context.characters[character_to_draw].queued = true
        bot_context.has_bot_done_stuff = true
      end
    end
  end
end
