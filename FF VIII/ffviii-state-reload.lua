ReloadGameState = State:new()

function ReloadGameState:needToRun(game_context, bot_context)
  if game_context.battle.is_in_battle then
    -- all enemies must either be a card or alive
    for enemy_index = 0,2 do
      local enemy = game_context.battle.enemies[enemy_index]
      if enemy.exists and not enemy.is_card and not enemy.is_alive then
        return true
      end
    end
  else
    -- TODO: check xp levels
    if game_context.characters_by_id[0x00] ~= nil then
      if game_context.characters_by_id[0x00].experience > 6500 then
        return true
      end
    end
  end
  
  return false
end

function ReloadGameState:writeText(game_context, bot_context)
  gui.text(0, 0, "reload game")
end

function ReloadGameState:run(game_context, bot_context)
  savestate.loadslot(9)
  bot_context.is_save_required = false
  bot_context.reload_count = (bot_context.reload_count or 0) + 1
  if (bot_context.reload_count or 0) == 5 then
    console.writeline('STUCK!')
    client.pause()
  end
  --console.writeline('saved')
end
