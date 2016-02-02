IdleState = State:new()

function IdleState:needToRun(game_context, bot_context, keys)
  return true
end

function IdleState:writeText(game_context, bot_context)
  gui.text(0, 0, "idle")
end

function IdleState:run(game_context, bot_context, keys)
  if bot_context.has_bot_done_stuff then
    --client.pause()
    bot_context.has_bot_done_stuff = false
  end
end
