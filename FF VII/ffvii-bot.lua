-- Final Fantasy VII Bot
local config = require 'ffvii-config'
dofile 'ffvii-util.lua'
dofile 'ffvii-context.lua'

-- state engine/states
dofile 'ffvii-state-engine.lua'
dofile 'ffvii-state-idle.lua'
dofile 'ffvii-state-findbattle.lua'
dofile 'ffvii-state-winbattle.lua'
dofile 'ffvii-state-acceptbattlerewards.lua'
dofile 'ffvii-state-healcharacter.lua'
dofile 'ffvii-state-save.lua'
dofile 'ffvii-state-reload.lua'
dofile 'ffvii-state-revivecharacter.lua'
dofile 'ffvii-state-tent.lua'

do
  local clear_keys = {}
  clear_keys.Circle = false
  clear_keys.Cross = false
  clear_keys.Triangle = false
  clear_keys.Square = false
  clear_keys.Up = false
  clear_keys.Left = false
  clear_keys.Down = false
  clear_keys.Right = false
  joypad.set(clear_keys, 1)

  local bot_context = {}
  local game_context = {}
  
  local state_engine = StateEngine:new({
    { 0, IdleState:new() },
    { 1, FindBattleState:new() },
    { 2, WinBattleState:new() },
    { 3, SaveGameState:new() },
    { 4, HealCharacterState:new() },
    { 5, TentState:new() },
    { 6, ReloadGameState:new() },
    { 7, ReviveCharacterState:new() },
    { 8, AcceptBattleRewardsState:new() },
  })
  
  if config.USE_TURBO then
    client.speedmode(1600)
    client.SetSoundOn(false)
    emu.minimizeframeskip(false)
  end
  
  local should_continue = true
  
  while should_continue do
    local pressed_keys = joypad.get(1)
    if pressed_keys.Square then
      should_continue = false
      client.speedmode(100)
      client.SetSoundOn(true)
      emu.minimizeframeskip(true)
    end
    
    local keys = {}
    
    updateGameContext(game_context)
    updateBotContext(config, game_context, bot_context)
    
    state_engine:run(game_context, bot_context, keys)
    
    joypad.set(keys, 1)
  
    emu.frameadvance()
  end
end
