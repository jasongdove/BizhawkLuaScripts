local config = dofile 'ffvii-config.lua'
dofile 'ffvii-util.lua'

local MATERIA_REVIVE = 0x37

local function getCharacterWithRevive(game_context)
  for party_index = 0,2 do
    local character_index = game_context.party[party_index].id
    for materia_index = 0,15 do
      if mainmemory.read_u8(0x09C738 + (character_index * 0x84) + 0x40 + (materia_index * 4)) == MATERIA_REVIVE then
        if game_context.party[party_index].current_hp > 0 then
          return party_index
        end
      end
    end
  end
  
  return nil
end

ReviveCharacterState = State:new()

function ReviveCharacterState:needToRun(game_context, bot_context, keys)
  bot_context.party_member_to_revive = nil
  
  if game_context.battle.is_in_battle then return false end

  for party_index = 0,2 do
    local character = game_context.party[party_index]
    if character.current_hp == 0 then
      -- make sure we have someone who can cast revive
      local p = getCharacterWithRevive(game_context)
      if p ~= nil then
        bot_context.party_member_to_revive = party_index
        return true
      end
    end
  end
  
  return false
end

function ReviveCharacterState:writeText(game_context, bot_context)
  gui.text(0, 0, "revive character")
end

function ReviveCharacterState:run(game_context, bot_context, keys)
  -- a party member needs to have the "RESTORE" materia, otherwise we can't do anything
  local p = getCharacterWithRevive(game_context)
  if p == nil or game_context.party[p].current_mp < 5 then
    -- TODO: travel to town and buy items ??
    return
  end

  if not game_context.menu.is_in_menu then
    pressAndRelease(bot_context, keys, "Triangle")
  elseif game_context.menu.main_menu_index < 1 then
    pressAndRelease(bot_context, keys, "Down")
  elseif game_context.menu.main_menu_index > 1 then
    pressAndRelease(bot_context, keys, "Up")
  elseif game_context.menu.active_menu_page == 0 and not game_context.menu.is_selecting_character then
    pressAndRelease(bot_context, keys, "Circle")
  elseif game_context.menu.is_selecting_character and game_context.menu.selected_character_index < p then
    pressAndRelease(bot_context, keys, "Down")
  elseif game_context.menu.is_selecting_character and game_context.menu.selected_character_index > p then
    pressAndRelease(bot_context, keys, "Up")
  elseif game_context.menu.is_selecting_character and game_context.menu.selected_character_index == p then
    pressAndRelease(bot_context, keys, "Circle")
  elseif game_context.menu.active_menu_page == 2 and game_context.menu.magic_submenu == 0 then
    pressAndRelease(bot_context, keys, "Circle")
  elseif game_context.menu.active_menu_page == 2 and game_context.menu.magic_submenu == 2 then
    -- life is the first item, just press circle
    pressAndRelease(bot_context, keys, "Circle")
  elseif game_context.menu.active_menu_page == 2 and game_context.menu.magic_submenu == 1 then
    if game_context.menu.magic_selected_character_index < bot_context.party_member_to_revive then
      pressAndRelease(bot_context, keys, "Down")
    elseif game_context.menu.magic_selected_character_index > bot_context.party_member_to_revive then
      pressAndRelease(bot_context, keys, "Up")
    else
      pressAndRelease(bot_context, keys, "Circle")
    end
  end
end
