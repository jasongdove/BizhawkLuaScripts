local MAGIC_CURE = 0x15
local MAGIC_CURA = 0x16
local MAGIC_CURAGA = 0x17

HealCharacterState = State:new()

function HealCharacterState:needToRun(game_context, bot_context, keys)
  -- must be in battle
  if not game_context.battle.is_in_battle then
    return false
  end
  
  -- someone must be able to draw
  local can_anyone_draw = false
  for character_index = 0,2 do
    if game_context.characters[character_index].has_command_draw then
      can_anyone_draw = true
      break
    end
  end
  
  if not can_anyone_draw then return false end
  
  -- enemy must have "cure" magic
  local enemy_has_cure = false
  for enemy_index = 0,3 do
    if game_context.battle.enemies[enemy_index].is_alive then
      for enemy_magic_index = 0,3 do
        local magic_id = game_context.battle.enemies[enemy_index].magic[enemy_magic_index].id
        if magic_id == MAGIC_CURAGA or magic_id == MAGIC_CURA or magic_id == MAGIC_CURE then
          enemy_has_cure = true
          break
        end
      end
      
      if enemy_has_cure then break end
    end
  end
  
  if not enemy_has_cure then return false end
    
  -- heal low hp characters
  for character_index = 0,2 do
    local character = game_context.characters[character_index]
    if character.exists and character.current_hp > 0 and character.current_hp < 200 then --(character.current_hp / character.max_hp < 0.5) then
      return true
    end
  end
  
  return false
end

function HealCharacterState:writeText(game_context, bot_context)
  gui.text(0, 0, "heal character")
end

function HealCharacterState:run(game_context, bot_context, keys)
  -- bail out if stuff is happening (no 'active' character)
  if game_context.battle.active_character == 0xFF then return end

  local character_to_draw = nil
  for character_index = 0,2 do
    local c = game_context.characters[character_index]
    if c.has_command_draw and c.can_act and bot_context.characters[character_index].can_act then
      character_to_draw = character_index
      break
    end
  end
  
  -- bail out if there isn't a character who can draw (who can also take a turn right now)
  if character_to_draw == nil then return end
  
  local character = game_context.characters[game_context.battle.active_character]

  -- if this character doesn't have draw, pass to the next character
  if not character.has_command_draw then
    pressAndRelease(bot_context, keys, 'Circle')
    return
  end

  local enemy_to_draw = nil
  local magic_to_draw = nil
  
  for enemy_index = 0,3 do
    if game_context.battle.enemies[enemy_index].is_alive then
      for enemy_magic_index = 0,3 do
        local magic_id = game_context.battle.enemies[enemy_index].magic[enemy_magic_index].id
        if magic_id == MAGIC_CURAGA or magic_id == MAGIC_CURA or magic_id == MAGIC_CURE then
          enemy_to_draw = enemy_index
          magic_to_draw = magic_id
          break
        end
      end
      
      if enemy_to_draw ~= nil then break end
    end
  end
  
  -- find a low hp character to heal
  local character_to_heal = nil
  for character_index = 0,2 do
    local c = game_context.characters[character_index]
    if c.exists and c.current_hp > 0 and c.current_hp < 200 then --(c.current_hp / c.max_hp < 0.5) then
      character_to_heal = character_index
      break
    end
  end
  
  if character_to_heal == nil then return end
  
  -- couldn't find anything to draw, so pass to the next character
  if enemy_to_draw == nil then
    pressAndRelease(bot_context, keys, 'Circle')
  else
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
    -- select 'cast'
    elseif game_context.battle.cursor_location == 0x17 then
      if game_context.battle.draw_action ~= 0x01 then
        pressAndRelease(bot_context, keys, 'Down')
      else
        pressAndRelease(bot_context, keys, 'Cross')
      end
    elseif game_context.battle.cursor_location == 0x1C then
      if game_context.battle.target_character ~= character_to_heal then
        bot_context.heal_moves = bot_context.heal_moves or 0
        
        if bot_context.heal_moves < 50 then
          pressAndRelease(bot_context, keys, 'Right')
        else
          pressAndRelease(bot_context, keys, 'Down')
        end
        
        bot_context.heal_moves = bot_context.heal_moves + 1
      else
        pressAndRelease(bot_context, keys, 'Cross')
        bot_context.characters[character_to_draw].queued = true
        bot_context.has_bot_done_stuff = true
        bot_context.heal_moves = nil
      end
    end
  end
end
