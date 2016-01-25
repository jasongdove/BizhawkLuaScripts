SeiferGrindState = State:new()

function SeiferGrindState:needToRun(game_context, bot_context)
  -- must be in battle
  if not game_context.battle.is_in_battle then
    return false
  end
  
  for character_index = 0,2 do
    local character = game_context.characters[character_index]
    
    -- we shouldn't grind while there's magic to draw
    local bot_context_character = bot_context.characters[character_index]
    if character.current_hp > 0 and bot_context_character.can_draw then
      return false
    end

    -- party must contain squall, zell and seifer
    if not (character.id == 0x00 or character.id == 0x01 or character.id == 0x06) then
      return false
    end
    
    -- squall cannot be alive
    if character.id == 0x00 and character.current_hp > 0 then
      return false
    end
    
    -- zell cannot be alive
    if character.id == 0x01 and character.current_hp > 0 then
      return false
    end
    
    -- seifer must be alive
    if character.id == 0x06 and character.current_hp <= 0 then
      return false
    end
  end
  
  return true
end

function SeiferGrindState:writeText(game_context, bot_context)
  gui.text(0, 0, "Seifer grind")
  
  for character_index = 0,2 do
    if game_context.characters[character_index].id == 0x06 then
      gui.text(0, 15, "level " .. game_context.characters[character_index].level)
    end
  end
end

function SeiferGrindState:run(game_context, bot_context, keys)
  -- attack
  if game_context.battle.main_menu_index ~= 0 then
    pressAndRelease(bot_context, keys, 'Down')
  elseif not game_context.battle.is_limit_break then
    pressAndRelease(bot_context, keys, 'Circle')
  else
    keys.Right = true
    pressAndRelease(bot_context, keys, 'Cross')
     bot_context.has_bot_done_stuff = true
  end
end
