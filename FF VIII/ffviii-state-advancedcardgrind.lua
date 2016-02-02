AdvancedCardGrindState = State:new()

local CHARACTER_QUISTIS = 0x03

function AdvancedCardGrindState:needToRun(game_context, bot_context)
  -- must be in battle
  if not game_context.battle.is_in_battle then
    return false
  end
  
  local character_has_card = false
  for character_index = 0,2 do
    local character = game_context.characters[character_index]
    
    -- we shouldn't grind while there's magic to draw
    local bot_context_character = bot_context.characters[character_index]
    if character.current_hp > 0 and bot_context_character.can_draw then
      return false
    end

    character_has_card = character_has_card or character.has_command_card
  end
  
  -- quistis must be in the party
  if game_context.characters[0].id ~= CHARACTER_QUISTIS and game_context.characters[1].id ~= CHARACTER_QUISTIS and game_context.characters[2].id ~= CHARACTER_QUISTIS then
    return false
  end
  
  -- someone must have the card command
  if not character_has_card then
    return false
  end
  
  -- TODO: quistis must have the magic missile command

  -- all enemies must either be a card or alive
  for enemy_index = 0,3 do
    local enemy = game_context.battle.enemies[enemy_index]
    if enemy.exists and not enemy.is_card and not enemy.is_alive then
      return false
    end
  end

  local all_enemies_are_cards = true  
  for enemy_index = 0,3 do
    local enemy = game_context.battle.enemies[enemy_index]
    if enemy.exists and not enemy.is_card then
      all_enemies_are_cards = false
      break
    end
  end

  return not all_enemies_are_cards
end

function AdvancedCardGrindState:writeText(game_context, bot_context)
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

function AdvancedCardGrindState:run(game_context, bot_context, keys)
  -- if active character == selfie then card
  -- if active character == squall then attack while enemy hp > x
  local active_character = game_context.characters[game_context.battle.active_character]
  if active_character == nil then
    return
  end
  
  local enemy_to_attack = nil
  for enemy_index = 0,3 do
    local enemy = game_context.battle.enemies[enemy_index]
    if enemy.exists and not enemy.is_card and enemy.current_hp / enemy.max_hp > 0.1 then
      enemy_to_attack = enemy_index
      break
    end
  end
  
  local enemy_to_card = nil
  for enemy_index = 0,3 do
    local enemy = game_context.battle.enemies[enemy_index]
    if enemy.exists and not enemy.is_card then
      if enemy.current_hp / enemy.max_hp <= 0.5 then
        enemy_to_card = enemy_index
        break
      end
    end
  end
  
  local should_quistis_card = active_character.id == CHARACTER_QUISTIS and active_character.has_command_card and enemy_to_attack == nil
  
  if (active_character.has_command_card or should_quistis_card) and enemy_to_card ~= nil then
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

  if enemy_to_attack ~= nil and active_character.id ~= CHARACTER_QUISTIS then
    if game_context.characters_by_id[CHARACTER_QUISTIS].can_act and bot_context.characters_by_id[CHARACTER_QUISTIS].can_act then
      pressAndRelease(bot_context, keys, 'Circle')
    end
  elseif enemy_to_card ~= nil and not active_character.has_command_card then
    for character_index = 0,2 do
      if game_context.characters[character_index].has_command_card and game_context.characters[character_index].can_act and bot_context.characters[character_index].can_act then
        pressAndRelease(bot_context, keys, 'Circle')
      end
    end
  end
  
  local is_blue_magic_menu_active = mainmemory.read_u8(0x103339) == 0x18 or mainmemory.read_u8(0x103339) == 0x19

  if active_character.id == CHARACTER_QUISTIS then
    if enemy_to_attack == nil then
      for character_index = 0,2 do
        if game_context.characters[character_index].id ~= CHARACTER_QUISTIS and game_context.characters[character_index].can_act and bot_context.characters[character_index].can_act then
          pressAndRelease(bot_context, keys, 'Circle')
        end
      end
    else
      -- pass if limit break isn't active
      if not game_context.battle.is_limit_break then
        pressAndRelease(bot_context, keys, 'Circle')
      else
        -- select 'blue magic'
        if game_context.battle.is_main_menu_active then
          -- DC0F == 'attack'
          if game_context.battle.menu_id == 0xDD2B then
            pressAndRelease(bot_context, keys, 'Cross')
          elseif game_context.battle.menu_id == 0xDC0F then
            keys.Right = true
          else
            pressAndRelease(bot_context, keys, 'Down')
          end
        -- select 'micro missiles'
        elseif is_blue_magic_menu_active then
          if game_context.battle.menu_id == 0x1901 then
            pressAndRelease(bot_context, keys, 'Cross')
          else
            local index = game_context.battle.blue_magic_index
            bot_context.blue_magic_index = bot_context.blue_magic_index or
            {
              [0] = false,
              [1] = false,
              [2] = false,
              [3] = false,
            }
            if bot_context.blue_magic_index[0] and bot_context.blue_magic_index[1] and bot_context.blue_magic_index[2] and bot_context.blue_magic_index[3] then
              if index ~= 0 then
                pressAndRelease(bot_context, keys, 'Down')
              else
                bot_context.blue_magic_index = nil
                pressAndRelease(bot_context, keys, 'Right')
              end
            else
              bot_context.blue_magic_index[index] = true
              pressAndRelease(bot_context, keys, 'Down')
            end
          end
        -- select enemy
        elseif game_context.battle.menu_id == 0x3070 or game_context.battle.menu_id == 0x3090 or game_context.battle.menu_id == 0x30B0 then
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
    end
  end
end
