local config = dofile 'ffvii-config.lua'
dofile 'ffvii-util.lua'

local ITEM_TENT = 0x46

TentState = State:new()

function TentState:needToRun(game_context, bot_context, keys)
  if game_context.battle.is_in_battle then return false end

  for party_index = 0,2 do
    if game_context.party[party_index].current_mp < config.MP_FLOOR then
      return true
    end
  end
  
  return false
end

function TentState:writeText(game_context, bot_context)
  gui.text(0, 0, "pitch a tent")
end

function TentState:run(game_context, bot_context, keys)
  local tent_item_index = nil
  for item_index = 0,319 do
    if mainmemory.read_u8(0x9CBE0 + item_index * 2) == ITEM_TENT then
      tent_item_index = item_index
      break
    end
  end
  
  if tent_item_index == nil then
    -- TODO: ???
    return
  end
  
  if not game_context.menu.is_in_menu then
    pressAndRelease(bot_context, keys, "Triangle")
  elseif game_context.menu.active_menu_page == 2 then
    pressAndRelease(bot_context, keys, "Cross")  
  elseif game_context.menu.main_menu_index < 0 then
    pressAndRelease(bot_context, keys, "Down")
  elseif game_context.menu.main_menu_index > 0 then
    pressAndRelease(bot_context, keys, "Up")
  elseif game_context.menu.active_menu_page == 0 then
    pressAndRelease(bot_context, keys, "Circle")
  elseif game_context.menu.active_menu_page == 1 and game_context.menu.item_submenu == 0 then
    pressAndRelease(bot_context, keys, "Circle")
  elseif game_context.menu.active_menu_page == 1 and game_context.menu.item_submenu == 1 then
    -- TODO: scroll down to find "tent"
    local top_index = 0
    local item_index = tent_item_index
    if tent_item_index > 9 then
      top_index = tent_item_index - 9
      item_index = tent_item_index - top_index
    end
    
    if game_context.menu.item_top_item < top_index then
      pressAndRelease(bot_context, keys, "Down")
    elseif game_context.menu.item_selected_item < item_index then
      pressAndRelease(bot_context, keys, "Down")
    else
      pressAndRelease(bot_context, keys, "Circle")
    end
  elseif game_context.menu.active_menu_page == 1 and game_context.menu.item_submenu == 2 then
    -- use the tent
    pressAndRelease(bot_context, keys, "Circle")
  end
end
