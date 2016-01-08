dofile 'ffvii-util.lua'

FindBattleState = State:new()

function FindBattleState:needToRun(game_context, bot_context, keys)
  return bot_context.has_uncapped_levels and (game_context.is_in_overworld or game_context.menu.is_in_menu)
end

function FindBattleState:writeText(game_context, bot_context)
  gui.text(0, 0, "find battle")
end

function FindBattleState:run(game_context, bot_context, keys)
  if bot_context.running_away == true then
    bot_context.running_away = false
    bot_context.is_save_required = true
  end

  if game_context.menu.is_in_menu then
    pressAndRelease(bot_context, keys, "Cross")
  else  
    bot_context.left_right_countdown = bot_context.left_right_countdown or 20

    if bot_context.left_right_countdown == 0 then
      if bot_context.tapping_left then
        bot_context.tapping_left = false
        bot_context.tapping_right = true
      else
        bot_context.tapping_left = true
        bot_context.tapping_right = false
      end
      
      bot_context.left_right_countdown = 20
    end
    
    if bot_context.tapping_left then
      keys.Left = true
    else
      keys.Right = true
    end

    bot_context.left_right_countdown = bot_context.left_right_countdown - 1
  end
end
