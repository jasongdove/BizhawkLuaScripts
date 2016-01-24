ExitMenuState = State:new()

function ExitMenuState:needToRun(game_context, bot_context, keys)
  -- must not be in battle
  if game_context.battle.is_in_battle then
    return false
  end
  
  return game_context.menu.is_in_menu
end

function ExitMenuState:writeText(game_context, bot_context)
  gui.text(0, 0, "exit menu")
end

function ExitMenuState:enter(game_context, bot_context, keys)
end

function ExitMenuState:run(game_context, bot_context, keys)
  pressAndRelease(bot_context, keys, 'Triangle')
end
