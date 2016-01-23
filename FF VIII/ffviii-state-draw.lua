DrawState = State:new()

function DrawState:needToRun(game_context, bot_context)
  -- must be in battle
  if not game_context.battle.is_in_battle then
    return false
  end
  
  -- must have a character with draw
  for character_index = 0,2 do
    local character = game_context.characters[character_index]
    character.can_draw = false
  
    if character.has_command_draw then
      -- enemy must have magic that this player does not have capped
      for enemy_index = 0,2 do
        if game_context.battle.enemies[enemy_index].is_alive then
          for enemy_magic_index = 0,3 do
            local magic_id = game_context.battle.enemies[enemy_index].magic[enemy_magic_index].id
            
            if game_context.battle.enemies[enemy_index].magic[enemy_magic_index].is_unknown then
              character.can_draw = true
              break
            end
            
            local has_magic = false
            if magic_id > 0 then
              for character_magic_index = 0,31 do
                if character.magic[character_magic_index].id == magic_id then
                  has_magic = true
                  if character.magic[character_magic_index].quantity < 100 then
                    character.can_draw = true
                    break
                  end
                end
              end

              -- if we didn't find the magic, check if we have room to draw a new magic
              if not has_magic and not character.can_draw then
                for character_magic_index = 0,31 do
                  if character.magic[character_magic_index].id == 0x00 then
                    character.can_draw = true
                    break
                  end
                end
              end  
              
              if character.can_draw then break end
            end
          end
          
          if character.can_draw then break end
        end
      end
    end
  end

  for character_index = 0,2 do
    if game_context.characters[character_index].can_draw then
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
    if c.can_draw and c.can_act and bot_context.characters[character_index].can_act then
      character_to_draw = character_index
      break
    end
  end
  
  -- bail out if there isn't a character who can draw (who can also take a turn right now)
  if character_to_draw == nil then return end

  local character = game_context.characters[game_context.battle.active_character]
  
  -- if this character doesn't have draw, pass to the next character
  if not character.can_draw then
    pressAndRelease(bot_context, keys, 'Circle')
    return
  end
  
  local enemy_to_draw = nil
  local magic_to_draw = nil
  
  for enemy_index = 0,2 do
    if game_context.battle.enemies[enemy_index].is_alive then
      for enemy_magic_index = 0,3 do
        local magic_id = game_context.battle.enemies[enemy_index].magic[enemy_magic_index].id
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
    
    if enemy_to_draw ~= nil then break end
  end
  
  -- couldn't find anything to draw, so pass to the next character
  if enemy_to_draw == nil then
    pressAndRelease(bot_context, keys, 'Circle')
  elseif game_context.battle.main_menu_index < 1 then
    pressAndRelease(bot_context, keys, 'Down')
  elseif game_context.battle.main_menu_index > 1 then
    pressAndRelease(bot_context, keys, 'Up')
  elseif game_context.battle.cursor_location == 0x00 or game_context.battle.cursor_location == 0x05 or game_context.battle.cursor_location == 0x07 then
    pressAndRelease(bot_context, keys, 'Cross')
  elseif game_context.battle.target_enemy ~= enemy_to_draw then
    pressAndRelease(bot_context, keys, 'Right')
  elseif game_context.battle.cursor_location ~= 0x0E then
    pressAndRelease(bot_context, keys, 'Cross')
  elseif game_context.battle.draw_magic_id ~= magic_to_draw then
    pressAndRelease(bot_context, keys, 'Down')
  else  
    pressAndRelease(bot_context, keys, 'Cross')
    bot_context.characters[character_to_draw].queued = true
    bot_context.has_bot_done_stuff = true
  end
end