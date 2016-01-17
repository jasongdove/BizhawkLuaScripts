local config = dofile 'ffvii-config.lua'
dofile 'ffvii-util.lua'

StatsState = State:new()

function StatsState:needToRun(game_context, bot_context, keys)
  if game_context.battle.is_in_battle then return false end

  if not bot_context.should_use_stat_items then return false end

  for party_index = 0,2 do
    local character = game_context.party[party_index]
    if character.has_uncapped_strength
      or character.has_uncapped_vitality
      or character.has_uncapped_magic
      or character.has_uncapped_spirit
      or character.has_uncapped_dexterity
      or character.has_uncapped_luck then
      return true
    end
  end
  
  return false
end

function StatsState:writeText(game_context, bot_context)
  gui.text(0, 0, "upgrade stats")
end

function StatsState:run(game_context, bot_context, keys)
  local target_item_index = nil
  local target_party_index = nil

  -- check for uncapped strength  
  if target_item_index == nil or target_party_index == nil then
    for party_index = 0,2 do
      if game_context.party[party_index].has_uncapped_strength then
        target_item_index = game_context.items.power_source_index
        target_party_index = party_index
        break
      end
    end
  end

  -- check for uncapped vitality  
  if target_item_index == nil or target_party_index == nil then
    for party_index = 0,2 do
      if game_context.party[party_index].has_uncapped_vitality then
        target_item_index = game_context.items.guard_source_index
        target_party_index = party_index
        break
      end
    end
  end
  
  -- check for uncapped magic  
  if target_item_index == nil or target_party_index == nil then
    for party_index = 0,2 do
      if game_context.party[party_index].has_uncapped_magic then
        target_item_index = game_context.items.magic_source_index
        target_party_index = party_index
        break
      end
    end
  end
  
  -- check for uncapped spirit  
  if target_item_index == nil or target_party_index == nil then
    for party_index = 0,2 do
      if game_context.party[party_index].has_uncapped_spirit then
        target_item_index = game_context.items.mind_source_index
        target_party_index = party_index
        break
      end
    end
  end
  
  -- check for uncapped dexterity  
  if target_item_index == nil or target_party_index == nil then
    for party_index = 0,2 do
      if game_context.party[party_index].has_uncapped_dexterity then
        target_item_index = game_context.items.speed_source_index
        target_party_index = party_index
        break
      end
    end
  end
  
  -- check for uncapped luck  
  if target_item_index == nil or target_party_index == nil then
    for party_index = 0,2 do
      if game_context.party[party_index].has_uncapped_luck then
        target_item_index = game_context.items.luck_source_index
        target_party_index = party_index
        break
      end
    end
  end
  
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
    elseif game_context.menu.item_selected_character_index ~= target_party_index then
      pressAndRelease(bot_context, keys, "Down")
    else
      -- use the item
      pressAndRelease(bot_context, keys, "Circle")
    end
  end
end
