RosettaRngState = State:new()

function RosettaRngState:needToRun(game_context, bot_context)
  if game_context.battle.is_in_battle then
    return false
  end
  
  bot_context.rng1 = mainmemory.read_u8(0x0562D4)
  bot_context.rng2 = mainmemory.read_u8(0x0562D5)
  bot_context.rng3 = mainmemory.read_u8(0x0562D6)
  bot_context.rng4 = mainmemory.read_u8(0x0562D7)
  
  --return bot_context.rng1 ~= 187 or bot_context.rng2 ~= 144 or bot_context.rng3 ~= 41 or bot_context.rng4 ~= 89
  return bot_context.rng1 ~= 216 or bot_context.rng2 ~= 201 or bot_context.rng3 ~= 109 or bot_context.rng4 ~= 12
end

function RosettaRngState:writeText(game_context, bot_context)
  gui.text(0, 0, "rosetta rng")
  gui.text(0, 15, 'rng1: ' .. bot_context.rng1)
  gui.text(0, 30, 'rng2: ' .. bot_context.rng2)
  gui.text(0, 45, 'rng3: ' .. bot_context.rng3)
  gui.text(0, 60, 'rng4: ' .. bot_context.rng4)
end

function RosettaRngState:run(game_context, bot_context, keys)
  local is_menu_open = mainmemory.read_u8(0x06A4BE) ~= 0x06
  local menu_index = mainmemory.read_u8(0x08301B)
  
  if not is_menu_open then
    pressAndRelease(bot_context, keys, 'Square')
  elseif menu_index ~= 2 then
    pressAndRelease(bot_context, keys, 'Down')
  else
    pressAndRelease(bot_context, keys, 'Cross')
  end
end
