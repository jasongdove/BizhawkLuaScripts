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

  -- don't run away if all enemies are cards
  return not all_cards
end

function RunAwayState:writeText(game_context, bot_context)
  gui.text(0, 0, "run away")
end

function RunAwayState:run(game_context, bot_context, keys)
  keys.L2 = true
  keys.R2 = true
  -- client.pause()
end
