ReloadGameState = State:new()

function ReloadGameState:needToRun(game_context, bot_context)
  if game_context.battle.is_in_battle then return false end

  for party_index = 0,2 do
    local character = game_context.party[party_index]
    if character.current_hp == 0 then
      console.writeline('need to reload')
      return true
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
  bot_context.reload_count = bot_context.reload_count + 1
  bot_context.find_battle_count = 0
end
