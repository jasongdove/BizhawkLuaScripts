IdleState = State:new()

function IdleState:needToRun(game_context, bot_context)
  return true
end

function IdleState:writeText(game_context, bot_context)
  gui.text(0, 0, "idle")
end

function IdleState:run(game_context, bot_context)
end
