AcceptBattleRewardsState = State:new()

function AcceptBattleRewardsState:needToRun(game_context, bot_context)
  return game_context.battle.is_accepting_rewards and not game_context.battle.is_in_battle
end

function AcceptBattleRewardsState:writeText(game_context, bot_context)
  gui.text(0, 0, "accept battle rewards")
end

function AcceptBattleRewardsState:run(game_context, bot_context, keys)
  bot_context.is_save_required = true
  pressAndRelease(bot_context, keys, "Cross")
end
