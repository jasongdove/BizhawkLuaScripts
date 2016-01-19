RunAwayState = State:new()

function RunAwayState:needToRun(game_context, bot_context)
  -- must be in battle
  if not game_context.battle.is_in_battle then
    return false
  end
  
  -- run away with low hp characters
  for character_index = 0,2 do
    local character = game_context.characters[character_index]
    if character.exists and character.current_hp <= 150 then
      return true
    end
  end
  
  -- do NOT run away if we can draw magic
  for character_index = 0,2 do
    local character = game_context.characters[character_index]
    if character.has_command_draw then
      for enemy_index = 0,2 do
        if game_context.battle.enemies[enemy_index].is_alive then
          for enemy_magic_index = 0,3 do
            local magic_id = game_context.battle.enemies[enemy_index].magic[enemy_magic_index].id
            
            if game_context.battle.enemies[enemy_index].magic[enemy_magic_index].is_unknown then
              return false
            end
            
            if magic_id > 0 then
              for character_magic_index = 0,31 do
                if character.magic[character_magic_index].id == magic_id and character.magic[character_magic_index].quantity < 100 then
                  return false
                end
              end
            end
          end
        end
      end
    end
  end

  -- run away with maxed magic
  return true
end

function RunAwayState:writeText(game_context, bot_context)
  gui.text(0, 0, "run away")
end

function RunAwayState:run(game_context, bot_context, keys)
  keys.L2 = true
  keys.R2 = true
end
