WinBattleState = State:new()

function WinBattleState:needToRun(game_context, bot_context)
  --emu.print(game_context.battle.cursor_position)
  return not game_context.is_in_overworld and game_context.battle.is_in_battle
end

function WinBattleState:writeText(game_context, bot_context)
  gui.text(0, 0, "win battle")
  
  for enemy_index = 0,game_context.battle.enemy_count-1 do
    if game_context.battle.enemies[enemy_index].current_hp > 0 then
      gui.text(0, 30 + (enemy_index * 45), "enemy " .. enemy_index)
      gui.text(0, 45 + (enemy_index * 45), "hp: " .. game_context.battle.enemies[enemy_index].current_hp .. "/" .. game_context.battle.enemies[enemy_index].max_hp)
    end
  end
  
  for party_index = 0,2 do
    gui.text(48, 435 + (party_index * 45), game_context.party[party_index].level)
  end
end

function WinBattleState:run(game_context, bot_context, keys)
  if bot_context.reload_count == 3 then
    keys.L1 = true
    keys.R1 = true
    bot_context.running_away = true
  else
    keys.Circle = true
  end
end
