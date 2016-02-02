local third_character_id = 0x04 -- 0x04: rinoa, 0x01: zell

TrainCardGrindState = State:new()

function TrainCardGrindState:needToRun(game_context, bot_context)
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

    -- party must contain squall, zell and selfie
    if not (character.id == 0x00 or character.id == 0x05 or character.id == third_character_id) then
      console.writeline(character.id)
      return false
    end
  end

  -- all enemies must either be a card or alive
  for enemy_index = 0,3 do
    local enemy = game_context.battle.enemies[enemy_index]
    if enemy.exists and not enemy.is_card and not enemy.is_alive then
      return false
    end
  end

  local all_enemies_are_cards = false  
  for enemy_index = 0,3 do
    local enemy = game_context.battle.enemies[enemy_index]
    if enemy.exists and not enemy.is_card then
      all_enemies_are_cards = false
      break
    end
  end

  return not all_enemies_are_cards
end

function TrainCardGrindState:writeText(game_context, bot_context)
  local y_offset = 30

  gui.text(0, y_offset + 0, "Card grind")
  
  for enemy_index = 0,3 do
    local enemy = game_context.battle.enemies[enemy_index]
    
    if enemy.exists then
      local message = '' .. enemy_index .. ': ' .. enemy.current_hp .. '/' .. enemy.max_hp
      if enemy.is_card then
        message = '' .. enemy_index .. ': CARD'
      elseif not enemy.is_alive then
        message = '' .. enemy_index .. ': DEAD'
      end
      gui.text(0, y_offset + 15 + (enemy_index * 15), message) 
    end
  end
end

function TrainCardGrindState:run(game_context, bot_context, keys)
  -- if active character == selfie then card
  -- if active character == squall then attack while enemy hp > x
  local active_character = game_context.characters[game_context.battle.active_character]
  if active_character == nil then
    return
  end
  
  local enemy_to_attack = nil
  local attack_with_zell = false
  local attack_with_shiva = false
  for enemy_index = 0,3 do
    local enemy = game_context.battle.enemies[enemy_index]
    if enemy.exists then
      if enemy.max_hp > 10000 then
        -- TODO: attack with shiva
        if enemy.current_hp > 6000 then
          enemy_to_attack = enemy_index
          attack_with_shiva = true
          break
        end
      else
        if enemy.current_hp > 200 then
          enemy_to_attack = enemy_index
          break
        elseif enemy.current_hp > 50 then
          enemy_to_attack = enemy_index
          attack_with_zell = true
          break
        end
      end
    end
  end
  
  if mainmemory.read_u8(0x0786D4) == 0x9D or mainmemory.read_u8(0x0786D5) == 0x9D then
    enemy_to_attack = nil
    attack_with_shiva = false
    attack_with_zell = false
  end 
  
  local enemy_to_card = nil  
  for enemy_index = 0,3 do
    local enemy = game_context.battle.enemies[enemy_index]
    if enemy.exists and not enemy.is_card then
      if enemy.max_hp > 10000 then
        if enemy.current_hp < 6000 then
          enemy_to_card = enemy_index
          break
        end
      elseif enemy.current_hp < 200 and enemy.max_hp > 50 then
        enemy_to_card = enemy_index
        break
      end
    end
  end
  
  -- zell should attack if enemy hp > 50
  if active_character.id == third_character_id then
    if enemy_to_attack == nil then
      if game_context.characters_by_id[0x05].can_act and bot_context.characters_by_id[0x05].can_act and enemy_to_card ~= nil then
        pressAndRelease(bot_context, keys, 'Circle')
      else
        return
      end
    elseif attack_with_zell then
      -- select 'attack'
      if game_context.battle.is_main_menu_active then
        if game_context.battle.main_menu_index < 0 then
          pressAndRelease(bot_context, keys, 'Down')
        elseif game_context.battle.main_menu_index > 0 then
          pressAndRelease(bot_context, keys, 'Up')
        else
          pressAndRelease(bot_context, keys, 'Cross')
        end
      -- select enemy
      elseif game_context.battle.cursor_location == 0x01 then
        --gui.text(0, 100, 'enemy to attk: ' .. enemy_to_attack)
        --gui.text(0, 115, ' target enemy: ' .. game_context.battle.target_enemy)
        if game_context.battle.target_enemy ~= enemy_to_attack then
          bot_context.card_attack_moves = bot_context.card_attack_moves or 0
          
          if bot_context.card_attack_moves < 50 then
            pressAndRelease(bot_context, keys, 'Left')
          else
            pressAndRelease(bot_context, keys, 'Up')
          end
          
          bot_context.card_attack_moves = bot_context.card_attack_moves + 1
        else
          pressAndRelease(bot_context, keys, 'Cross')
          bot_context.characters[game_context.battle.active_character].queued = true
          bot_context.card_attack_moves = nil
        end
      end
    else
      if game_context.characters_by_id[0x00].can_act and bot_context.characters_by_id[0x00].can_act then
        pressAndRelease(bot_context, keys, 'Circle')
      end
    end
  end
  
  -- squall should attack if enemy hp > 200
  if active_character.id == 0x00 then
    if enemy_to_attack == nil then
      -- pass to selfie if we can't attack anything
      if game_context.characters_by_id[0x05].can_act and bot_context.characters_by_id[0x05].can_act and enemy_to_card ~= nil then
        pressAndRelease(bot_context, keys, 'Circle')
      else
        return
      end
    elseif attack_with_zell == false then
      if attack_with_shiva then
        -- select 'GF'
        if game_context.battle.is_main_menu_active then
          if game_context.battle.main_menu_index < 2 then
            pressAndRelease(bot_context, keys, 'Down')
          elseif game_context.battle.main_menu_index > 2 then
            pressAndRelease(bot_context, keys, 'Up')
          else
            pressAndRelease(bot_context, keys, 'Cross')
          end
        -- select 'Shiva'
        elseif game_context.battle.is_gf_menu_active then
          if mainmemory.read_u8(0x103338) ~= 0xE2 then
            pressAndRelease(bot_context, keys, 'Down')
          else
            pressAndRelease(bot_context, keys, 'Cross')
            bot_context.characters[game_context.battle.active_character].queued = true
          end
        end        
      else
        -- select 'attack'
        if game_context.battle.is_main_menu_active then
          if game_context.battle.main_menu_index < 0 then
            pressAndRelease(bot_context, keys, 'Down')
          elseif game_context.battle.main_menu_index > 0 then
            pressAndRelease(bot_context, keys, 'Up')
          else
            pressAndRelease(bot_context, keys, 'Cross')
          end
        -- select enemy
        elseif game_context.battle.cursor_location == 0x01 then
          --gui.text(0, 100, 'enemy to attk: ' .. enemy_to_attack)
          --gui.text(0, 115, ' target enemy: ' .. game_context.battle.target_enemy)
          if game_context.battle.target_enemy ~= enemy_to_attack then
            bot_context.card_attack_moves = bot_context.card_attack_moves or 0
            
            if bot_context.card_attack_moves < 50 then
              pressAndRelease(bot_context, keys, 'Left')
            else
              pressAndRelease(bot_context, keys, 'Up')
            end
            
            bot_context.card_attack_moves = bot_context.card_attack_moves + 1
          else
            pressAndRelease(bot_context, keys, 'Cross')
            bot_context.characters[game_context.battle.active_character].queued = true
            bot_context.card_attack_moves = nil
          end
        end
      end
    else
      if game_context.characters_by_id[third_character_id].can_act and bot_context.characters_by_id[third_character_id].can_act then
        pressAndRelease(bot_context, keys, 'Circle')
      end
    end
  end

  if active_character.id == 0x05 then
    if enemy_to_card == nil then
      -- pass to squall if we can't card anything
      if game_context.characters_by_id[0x00].can_act and bot_context.characters_by_id[0x00].can_act and enemy_to_attack ~= nil then
        pressAndRelease(bot_context, keys, 'Circle')
      else
        return
      end
    else
      -- select 'card'
      if game_context.battle.is_main_menu_active then
        if game_context.battle.main_menu_index < 3 then
          pressAndRelease(bot_context, keys, 'Down')
        elseif game_context.battle.main_menu_index > 3 then
          pressAndRelease(bot_context, keys, 'Up')
        else
          pressAndRelease(bot_context, keys, 'Cross')
        end
      -- select enemy
      elseif game_context.battle.cursor_location == 0x01 then
        --gui.text(0, 100, 'enemy to card: ' .. enemy_to_card)
        --gui.text(0, 115, ' target enemy: ' .. game_context.battle.target_enemy)
        if game_context.battle.target_enemy ~= enemy_to_card then
          bot_context.card_moves = bot_context.card_moves or 0
          
          if bot_context.card_moves < 50 then
            pressAndRelease(bot_context, keys, 'Left')
          else
            pressAndRelease(bot_context, keys, 'Up')
          end
          
          bot_context.card_moves = bot_context.card_moves + 1
        else
          pressAndRelease(bot_context, keys, 'Cross')
          bot_context.characters[game_context.battle.active_character].queued = true
          bot_context.card_moves = nil
        end
      end
    end
  end
end
