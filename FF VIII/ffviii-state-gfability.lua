local _HP_J = 0x01
local _STR_J = 0x02
local _VIT_J = 0x03
local _MAG_J = 0x04
local _SPR_J = 0x05
local _HIT_J = 0x08
local _ELEM_ATK_J = 0x0A
local _ST_ATK_J = 0x0B
local _ELEM_DEF_J = 0x0C
local _ST_DEF_J = 0x0D
local _ELEM_DEFx2 = 0x0E
local _ST_DEF_Jx2 = 0x10
local _ABILITY_x3 = 0x12
local _MAGIC = 0x14
local _GF = 0x15
local _DRAW = 0x16
local _ITEM = 0x17
local _CARD = 0x19
local _DOOM = 0x1A
local _MAD_RUSH = 0x1B
local _DARKSIDE = 0x1E
local _HP_PLUS_20 = 0x27
local _HP_PLUS_40 = 0x28
local _HP_PLUS_80 = 0x29
local _STR_PLUS_20 = 0x2A
local _STR_PLUS_40 = 0x2B
local _VIT_PLUS_20 = 0x2D
local _VIT_PLUS_40 = 0x2E
local _MAG_PLUS_20 = 0x30
local _MAG_PLUS_40 = 0x31
local _SPR_PLUS_20 = 0x33
local _SPR_PLUS_40 = 0x34
local _MUG = 0x3A
local _MAG_BONUS = 0x44
local _STR_BONUS = 0x42
local _MOVE_FIND = 0x4F
local _ENC_HALF = 0x50
local _ENC_NONE = 0x51
local _SUM_MAG_PLUS_10 = 0x53
local _SUM_MAG_PLUS_20 = 0x54
local _SUM_MAG_PLUS_30 = 0x55
local _GF_HP_PLUS_10 = 0x57
local _GF_HP_PLUS_20 = 0x58
local _GF_HP_PLUS_30 = 0x59
local _BOOST = 0x5B
local _T_MAG_RF = 0x61
local _I_MAG_RF = 0x62
local _F_MAG_RF = 0x63
local _L_MAG_RF = 0x64
local _TIME_MAG_RF = 0x65
local _ST_MAG_RF = 0x66
local _ST_MED_RF = 0x6A
local _TOOL_RF = 0x6C
local _AMMO_RF = 0x6B
local _MID_MAG_RF = 0x70
local _CARD_MOD = 0x73

local gf_abilities = {}
gf_abilities['Quezacotl'] =
{
  [0] = _MAGIC,
  [1] = _GF,
  [2] = _DRAW,
  [3] = _ITEM,
  [4] = _CARD,
  [5] = _CARD_MOD,
  [6] = _T_MAG_RF,
  [7] = _BOOST,
  [8] = _MID_MAG_RF,
  [9] = _HP_J,
  [10] = _VIT_J,
  [11] = _MAG_PLUS_20,
  [12] = _MAG_PLUS_40,
  [13] = _ELEM_ATK_J,
  [14] = _ELEM_DEF_J,
  [15] = _SUM_MAG_PLUS_10,
  [16] = _SUM_MAG_PLUS_20,
  [17] = _GF_HP_PLUS_10,
  [18] = _GF_HP_PLUS_20,
  [19] = _ELEM_DEFx2,
  [20] = _SUM_MAG_PLUS_30,
  [21] = _MAG_J,
}

gf_abilities['Shiva'] =
{
  [0] = _MAGIC,
  [1] = _GF,
  [2] = _DRAW,
  [3] = _ITEM,
  [4] = _STR_J,
  [5] = _BOOST,
  [6] = _VIT_J,
  [7] = _I_MAG_RF,
  [8] = _ELEM_ATK_J,
  [9] = _DOOM,
  [10] = _VIT_PLUS_20,
  [11] = _VIT_PLUS_40,
  [12] = _SPR_PLUS_20,
  [13] = _SPR_PLUS_40,
  [14] = _ELEM_DEF_J,
  [15] = _SUM_MAG_PLUS_10,
  [16] = _SUM_MAG_PLUS_20,
  [17] = _GF_HP_PLUS_10,
  [18] = _GF_HP_PLUS_20,
  [19] = _ELEM_DEFx2,
  [20] = _SUM_MAG_PLUS_30,
  [21] = _SPR_J,
}

gf_abilities['Ifrit'] =
{
  [0] = _MAGIC,
  [1] = _GF,
  [2] = _DRAW,
  [3] = _ITEM,
  [4] = _BOOST,
  [5] = _HP_J,
  [6] = _STR_PLUS_20,
  [7] = _F_MAG_RF,
  [8] = _AMMO_RF,
  [9] = _MAD_RUSH,
  [10] = _ELEM_DEF_J,
  [11] = _ELEM_DEFx2,
  [12] = _STR_PLUS_40,
  [13] = _STR_BONUS,
  [14] = _SUM_MAG_PLUS_10,
  [15] = _SUM_MAG_PLUS_20,
  [16] = _GF_HP_PLUS_10,
  [17] = _GF_HP_PLUS_20,
  [18] = _SUM_MAG_PLUS_30,
  [19] = _GF_HP_PLUS_30,
  [20] = _STR_J,
  [21] = _ELEM_ATK_J,
}

gf_abilities['Siren'] =
{
  [0] = _MAGIC,
  [1] = _GF,
  [2] = _DRAW,
  [3] = _ITEM,
  [4] = _BOOST,
  [5] = _MAG_J,
  [6] = _ST_ATK_J,
  [7] = _ST_DEF_J,
  [8] = _ST_DEF_Jx2,
  [9] = _SUM_MAG_PLUS_10,
  [10] = _GF_HP_PLUS_10,
  [11] = _L_MAG_RF,
  [12] = _ST_MED_RF,
  [13] = _TOOL_RF,
  [14] = _MOVE_FIND,
  [15] = _MAG_PLUS_20,
  [16] = _MAG_PLUS_40,
  [17] = _SUM_MAG_PLUS_20,
  [18] = _GF_HP_PLUS_20,
  [19] = _SUM_MAG_PLUS_30,
  [20] = _MAG_BONUS,
  --TODO: [21] = _TREATMENT,
  [21] = _MAG_BONUS,
}

gf_abilities['Diablos'] =
{
  [0] = _MAGIC,
  [1] = _GF,
  [2] = _DRAW,
  [3] = _ITEM,
  [4] = _MAG_J,
  [5] = _ABILITY_x3,
  [6] = _ENC_HALF,
  [7] = _HP_J,
  [8] = _TIME_MAG_RF,
  [9] = _ST_MAG_RF,
  [10] = _ENC_NONE,
  [11] = _MUG,
  [12] = _HIT_J,
  [13] = _DARKSIDE,
  [14] = _HP_PLUS_20,
  [15] = _HP_PLUS_40,
  [16] = _MAG_PLUS_20,
  [17] = _MAG_PLUS_40,
  [18] = _GF_HP_PLUS_10,
  [19] = _GF_HP_PLUS_20,
  [20] = _GF_HP_PLUS_30,
  [21] = _HP_PLUS_80,
}

local gf_learn_map =
{
  [_HP_J] = 0x0AE1,
  [_STR_J] = 0x0AF1,
  [_VIT_J] = 0x0B06,
  [_MAG_J] = 0x0B1D,
  [_SPR_J] = 0x0B2E,
  [_HIT_J] = 0x0B69,
  [_ELEM_ATK_J] = 0x0B94,
  [_ELEM_DEF_J] = 0x0BC7,
  [_ELEM_DEFx2] = 0x0BF8,
  [_ABILITY_x3] = 0x0C67,
  [_MAGIC] = 0x0CA2,
  [_GF] = 0x0CAE,
  [_DRAW] = 0x0CBB,
  [_ITEM] = 0x0CCB,
  [_CARD] = 0x0CE7,
  [_DOOM] = 0x0CF6,
  [_MAD_RUSH] = 0x0D0A,
  [_DARKSIDE] = 0x0D4D,
  [_HP_PLUS_20] = 0x0E07,
  [_HP_PLUS_40] = 0x0E1A,
  [_HP_PLUS_80] = 0x0E2D,
  [_STR_PLUS_20] = 0x0E41,
  [_STR_PLUS_40] = 0x0E56,
  [_VIT_PLUS_20] = 0x0E80,
  [_VIT_PLUS_40] = 0x0E96,
  [_MAG_PLUS_20] = 0x0EC2,
  [_MAG_PLUS_40] = 0x0EDE,
  [_SPR_PLUS_20] = 0x0F16,
  [_SPR_PLUS_40] = 0x0F2B,
  [_MUG] = 0x0FAC,
  [_STR_BONUS] = 0x10D2,
  [_MAG_BONUS] = 0x1115,
  [_MOVE_FIND] = 0x12CA,
  [_ENC_HALF] = 0x12ED,
  [_ENC_NONE] = 0x130E,
  [_SUM_MAG_PLUS_10] = 0x134B,
  [_SUM_MAG_PLUS_20] = 0x136A,
  [_SUM_MAG_PLUS_30] = 0x1389,
  [_GF_HP_PLUS_10] = 0x13C5,
  [_GF_HP_PLUS_20] = 0x13DD,
  [_GF_HP_PLUS_30] = 0x13F5,
  [_BOOST] = 0x1422,
  [_T_MAG_RF] = 0x14D9,
  [_I_MAG_RF] = 0x1502,
  [_F_MAG_RF] = 0x1527,
  [_L_MAG_RF] = 0x1547,
  [_TIME_MAG_RF] = 0x1574,
  [_ST_MAG_RF] = 0x159B,
  [_ST_MED_RF] = 0x1639,
  [_AMMO_RF] = 0x1664,
  [_TOOL_RF] = 0x1686,
  [_MID_MAG_RF] = 0x1741,
  [_CARD_MOD] = 0x17AC,
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
    
      if abilities ~= nil then
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
          else
            client.pause()
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
