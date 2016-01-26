RunAwayState = State:new()

function RunAwayState:needToRun(game_context, bot_context)
  -- must be in battle
  if not game_context.battle.is_in_battle then
    return false
  end
  
  -- run away with low hp characters
  for character_index = 0,2 do
    local character = game_context.characters[character_index]
    if character.exists and character.current_hp > 0 and (character.current_hp / character.max_hp < 0.5) then
      return true
    end
  end
  
  -- -- do NOT run away if we can draw magic
  -- for character_index = 0,2 do
  --   local character = game_context.characters[character_index]
  --   if character.has_command_draw then
  --     for enemy_index = 0,2 do
  --       if game_context.battle.enemies[enemy_index].is_alive then
  --         for enemy_magic_index = 0,3 do
  --           local magic_id = game_context.battle.enemies[enemy_index].magic[enemy_magic_index].id
  --           
  --           if game_context.battle.enemies[enemy_index].magic[enemy_magic_index].is_unknown then
  --             return false
  --           end
  --           
  --           if magic_id > 0 then
  --             local has_magic = false
  --             for character_magic_index = 0,31 do
  --               if character.magic[character_magic_index].id == magic_id then
  --                 has_magic = true
  --                 
  --                 if character.magic[character_magic_index].quantity < 100 then
  --                   return false
  --                 end
  --               end
  --             end
  --             
  --             -- draw a new magic as long as we have room
  --             if not has_magic then
  --               for character_magic_index = 0,31 do
  --                 if character.magic[character_magic_index].id == 0x00 then
  --                   return false
  --                 end
  --               end            
  --             end
  --           end
  --         end
  --       end
  --     end
  --   end
  -- end
  
  local all_cards = true
  local has_high_hp_enemy = false
  for enemy_index = 0,3 do
    local enemy = game_context.battle.enemies[enemy_index]
    if enemy.exists then
      if not enemy.is_card then
        all_cards = false

        if enemy.max_hp > 50 then
          has_high_hp_enemy = true
          break
        end
      end
    end
  end

  -- run away with *only* low hp enemies
  if not all_cards and not has_high_hp_enemy then
    return true
  end
  
  return false
end

function RunAwayState:writeText(game_context, bot_context)
  gui.text(0, 0, "run away")
end

function RunAwayState:run(game_context, bot_context, keys)
  keys.L2 = true
  keys.R2 = true
  -- client.pause()
end
