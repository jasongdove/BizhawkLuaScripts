local config = dofile 'ffvii-config.lua'
dofile 'ffvii-util.lua'

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
  if game_context.items.tent_index == nil or game_context.items.tent_quantity < 2 then
    -- TODO: ???
    return
  end
  
  local target_item_index = game_context.items.tent_index  
  local item_index = target_item_index - (game_context.menu.item_top_item or 0)
  
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
    if target_item_index < game_context.menu.item_top_item then
      pressAndRelease(bot_context, keys, "Up")
    elseif target_item_index > game_context.menu.item_top_item + 9 then
      pressAndRelease(bot_context, keys, "Down")
    elseif game_context.menu.item_selected_item < item_index then
      pressAndRelease(bot_context, keys, "Down")
    elseif game_context.menu.item_selected_item > item_index then
      pressAndRelease(bot_context, keys, "Up")
    elseif game_context.menu.item_top_item + item_index == target_item_index then
      pressAndRelease(bot_context, keys, "Circle")
    end
  elseif game_context.menu.active_menu_page == 1 and game_context.menu.item_submenu == 2 then
    -- if we just used a different item, back out
    if game_context.menu.item_selected_item ~= item_index then
      pressAndRelease(bot_context, keys, "Cross")
    else
      -- use the item
      pressAndRelease(bot_context, keys, "Circle")
    end
  end
end
