-- Final Fantasy VIII Bot
local config = require 'ffviii-config'
dofile 'ffviii-util.lua'
dofile 'ffviii-context.lua'

-- state engine/states
dofile 'ffviii-state-engine.lua'
dofile 'ffviii-state-idle.lua'
dofile 'ffviii-state-draw.lua'
dofile 'ffviii-state-runaway.lua'
dofile 'ffviii-state-acceptbattlerewards.lua'
dofile 'ffviii-state-save.lua'
dofile 'ffviii-state-reload.lua'
dofile 'ffviii-state-healcharacter.lua'
dofile 'ffviii-state-gfability.lua'
dofile 'ffviii-state-exitmenu.lua'
dofile 'ffviii-state-seifergrind.lua'
dofile 'ffviii-state-seiferfindbattle.lua'
dofile 'ffviii-state-traincardgrind.lua'
dofile 'ffviii-state-trainfindbattle.lua'
dofile 'ffviii-state-rosettarng.lua'
dofile 'ffviii-state-advancedcardgrind.lua'
dofile 'ffviii-state-levelupenemy.lua'

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
    
    --{ 1, SeiferFindBattleState:new() },
    { 1, TrainFindBattleState:new() },
    
    { 2, ExitMenuState:new() },
    { 3, GfAbilityState:new() },
    
    --{ 5, SeiferGrindState:new() },
    --{ 5, TrainCardGrindState:new() },
    { 4, RunAwayState:new() },
    
    --{ 5, AdvancedCardGrindState:new() },
    { 6, DrawState:new() },
    { 7, LevelUpEnemyState:new() },

    { 8, SaveGameState:new() },
    { 9, HealCharacterState:new() },
    { 10, AcceptBattleRewardsState:new() },
    
    --{ 11, RosettaRngState:new() },
    
    { 100, ReloadGameState:new() },
  })
  
  if config.USE_TURBO then
    client.speedmode(1600)
    client.SetSoundOn(false)
    emu.minimizeframeskip(false)
  end
  
  local should_continue = true
  local run_bot = false
  
  while should_continue do
    local pressed_keys = joypad.get(1)
    
    if pressed_keys.L1 and pressed_keys.Square then
      run_bot = false
    elseif pressed_keys.R1 and pressed_keys.Square then
      run_bot = true
    end
  
    if run_bot then    
      -- if pressed_keys.Square then
      --   should_continue = false
      --   client.speedmode(100)
      --   client.SetSoundOn(true)
      --   emu.minimizeframeskip(true)
      -- end
      
      local keys = {}

      updateGameContext(game_context)
      updateBotContext(config, game_context, bot_context)
      
      state_engine:run(game_context, bot_context, keys)
      
      joypad.set(keys, 1)
    end
  
    emu.frameadvance()
  end
end
