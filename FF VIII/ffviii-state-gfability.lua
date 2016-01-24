local gf_abilities = {}
gf_abilities['Quezacotl'] = { [0] = 0x19 }
gf_abilities['Shiva'] = { [0] = 0x02, [1] = 0x5B }
gf_abilities['Ifrit'] = { [0] = 0x5B }

local gf_learn_map =
{
  [0x01] = 0x0AE1,
  [0x02] = 0x0AF1,
  [0x03] = 0x0B06,
  [0x04] = 0x0B1D,
  [0x05] = 0x0B2E,
  [0x14] = 0x0CA2,
  [0x15] = 0x0CAE,
  [0x16] = 0x0CBB,
  [0x17] = 0x0CCB,
  [0x19] = 0x0CE7,
  [0x30] = 0x0EC2,
  [0x33] = 0x0F16,
  [0x53] = 0x134B,
  [0x57] = 0x13C5,
  [0x5B] = 0x1422,
  [0x61] = 0x14D9,
  [0x62] = 0x1502,
}

GfAbilityState = State:new()

function GfAbilityState:needToRun(game_context, bot_context, keys)
  -- must not be in battle
  if game_context.battle.is_in_battle then
    bot_context.gf = nil
    return false
  end
  
  for gf_index = 0,15 do
    local gf = game_context.gfs[gf_index]
    if gf ~= nil and gf.is_active then
      local abilities = gf_abilities[gf.name]
    
      for ability_index = 0,21 do
        local ability = abilities[ability_index]
        if ability ~= nil then
          if gf.active_ability == ability then
            break
          end
          
          -- check the GF has completed this ability, or is actively learning it
          if not (gf.abilities[ability].completed or gf.active_ability == ability) then
            bot_context.gf = bot_context.gf or {}
            
            -- reset menu if gf_to_change changes
            if bot_context.gf.gf_to_change ~= nil and bot_context.gf.gf_to_change ~= gf_index then
              bot_context.menu.need_to_reset = true
              bot_context.menu.need_to_reset_learn = true
            end
            
            bot_context.gf.gf_to_change = gf_index
            bot_context.gf.ability_to_learn = ability 
            return true
          end
        end
      end
    end
  end
  
  bot_context.gf = nil
  return false
end

function GfAbilityState:writeText(game_context, bot_context)
  gui.text(0, 0, "gf ability")
end

function GfAbilityState:enter(game_context, bot_context, keys)
  bot_context.menu = bot_context.menu or {}
  bot_context.menu.need_to_reset = true
  bot_context.menu.need_to_reset_learn = true
end

function GfAbilityState:run(game_context, bot_context, keys)
  -- get back to the main menu if we're entering this state
  if bot_context.menu.need_to_reset then
    if not game_context.menu.is_in_menu then
      pressAndRelease(bot_context, keys, 'Circle')
    else
      if game_context.menu.active_menu ~= 0xFF then
        pressAndRelease(bot_context, keys, 'Triangle')
      end
    end
    
    if game_context.menu.is_in_menu and game_context.menu.active_menu == 0xFF then
      bot_context.menu.need_to_reset = false
    end
    
    return
  end
  
  if not game_context.menu.is_in_menu then
    pressAndRelease(bot_context, keys, 'Circle')
  elseif game_context.menu.active_menu == 0xFF then
    if game_context.menu.main_menu_index ~= 0x04 then
      pressAndRelease(bot_context, keys, 'Down')
    else
      pressAndRelease(bot_context, keys, 'Cross')
    end
  elseif game_context.menu.active_menu == 0x04 then
    if game_context.menu.gf.is_selection_menu_active then
      if game_context.menu.gf.id ~= bot_context.gf.gf_to_change then
        if game_context.menu.gf.id <= 7 and bot_context.gf.gf_to_change > 7 then
          pressAndRelease(bot_context, keys, 'Down')
        else
          pressAndRelease(bot_context, keys, 'Right')
        end
      else
        pressAndRelease(bot_context, keys, 'Cross')
      end
    elseif game_context.menu.gf.is_status_menu_active then
      pressAndRelease(bot_context, keys, 'Cross')
    elseif game_context.menu.gf.is_learn_menu_active then
      if bot_context.menu.need_to_reset_learn then
        if game_context.menu.gf.learn_menu_page ~= 0 then
          pressAndRelease(bot_context, keys, 'Left')
        elseif game_context.menu.gf.learn_menu_index_page_1 ~= 0 then
          pressAndRelease(bot_context, keys, 'Up')
        else
          bot_context.menu.need_to_reset_learn = false
        end
          
        return
      end
      
      if game_context.menu.gf.learn_menu_ability ~= gf_learn_map[bot_context.gf.ability_to_learn] then
        if game_context.menu.gf.learn_menu_page == 0 then
          if game_context.menu.gf.learn_menu_index_page_1 < 0x0A then
            pressAndRelease(bot_context, keys, 'Down')
          else
            pressAndRelease(bot_context, keys, 'Right')
          end
        else
          pressAndRelease(bot_context, keys, 'Up')
        end
      else
        pressAndRelease(bot_context, keys, 'Cross')
      end
    end
  end
end
