local MIN_LEVEL = 44

LevelUpEnemyState = State:new()

function LevelUpEnemyState:needToRun(game_context, bot_context)
  -- must be in battle
  if not game_context.battle.is_in_battle then
    return false
  end
  
  local character_has_lvlup = false
  for character_index = 0,2 do
    local character = game_context.characters[character_index]
    character_has_lvlup = character_has_lvlup or character.has_command_lvlup
  end
  
  -- someone must have the level up command
  if not character_has_lvlup then
    return false
  end
  
  -- all enemies must either be a card or alive
  local has_low_level_enemy = false
  local has_high_level_enemy = false
  for enemy_index = 0,3 do
    local enemy = game_context.battle.enemies[enemy_index]
    --console.writeline('enemy level: ' .. enemy.level)
    if enemy.exists and enemy.is_card == false and enemy.is_alive == false then
      return false
    end
    
    if enemy.exists and enemy.is_card == false and enemy.is_alive and enemy.level < MIN_LEVEL then
      has_low_level_enemy = true
    end
    
    if enemy.exists and enemy.is_card == false and enemy.is_alive and enemy.level >= MIN_LEVEL then
      has_high_level_enemy = true
    end
  end
  
  -- level up one, get rid of one, etc
  if has_high_level_enemy then return false end

  local all_enemies_are_cards = true  
  for enemy_index = 0,3 do
    local enemy = game_context.battle.enemies[enemy_index]
    if enemy.exists and not enemy.is_card then
      all_enemies_are_cards = false
      break
    end
  end
  
  return all_enemies_are_cards == false and has_low_level_enemy
end

function LevelUpEnemyState:writeText(game_context, bot_context)
  local y_offset = 30

  gui.text(0, y_offset + 0, "level up")
  
  for enemy_index = 0,3 do
    local enemy = game_context.battle.enemies[enemy_index]
    
    if enemy.exists then
      local message = '' .. enemy_index .. ': ' .. enemy.level
      if enemy.is_card then
        message = '' .. enemy_index .. ': CARD'
      elseif not enemy.is_alive then
        message = '' .. enemy_index .. ': DEAD'
      end
      gui.text(0, y_offset + 15 + (enemy_index * 15), message) 
    end
  end
end

function LevelUpEnemyState:run(game_context, bot_context, keys)
  local character_with_lvlup = nil
  for character_index = 0,2 do
    if game_context.characters[character_index].has_command_lvlup then
      character_with_lvlup = character_index
      break
    end
  end
  
  if character_with_lvlup == nil then return end
  
  -- pass the turn if the active character doesn't have the level up command, but a character who does can act
  if game_context.battle.active_character ~= character_with_lvlup then
    if game_context.characters[character_with_lvlup].can_act and bot_context.characters[character_with_lvlup].can_act then
      pressAndRelease(bot_context, keys, 'Circle')
    end
    return
  end
  
  local enemy_to_level = nil
  for enemy_index = 0,3 do
    local enemy = game_context.battle.enemies[enemy_index]
    if enemy.exists and not enemy.is_card and enemy.is_alive and enemy.level < MIN_LEVEL then
      enemy_to_level = enemy_index
      break
    end
  end
  
  if enemy_to_level == nil then return end
  
  -- select 'level up'
  if game_context.battle.is_main_menu_active then
    -- DF2B == 'level up'
    if game_context.battle.menu_id == 0xDF2B then
      pressAndRelease(bot_context, keys, 'Cross')
    else
      pressAndRelease(bot_context, keys, 'Down')
    end
  -- select enemy
  elseif game_context.battle.menu_id == 0x3070 or game_context.battle.menu_id == 0x3090 or game_context.battle.menu_id == 0x30B0 then
    if game_context.battle.target_enemy ~= enemy_to_level then
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
