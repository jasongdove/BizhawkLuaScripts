WinBattleState = State:new()

function WinBattleState:needToRun(game_context, bot_context)
  --emu.print(game_context.battle.cursor_position)
  return not game_context.is_in_overworld and game_context.battle.is_in_battle
end

function WinBattleState:writeText(game_context, bot_context)
  gui.text(0, 0, "win battle")
  
  for enemy_index = 0,game_context.battle.enemy_count-1 do
    if game_context.battle.enemies[enemy_index].current_hp > 0 then
      gui.text(0, 30 + (enemy_index * 45), "enemy " .. enemy_index)
      gui.text(0, 45 + (enemy_index * 45), "hp: " .. game_context.battle.enemies[enemy_index].current_hp .. "/" .. game_context.battle.enemies[enemy_index].max_hp)
    end
  end
  
  for party_index = 0,2 do
    gui.text(48, 435 + (party_index * 45), game_context.party[party_index].level)
  end
end

function WinBattleState:run(game_context, bot_context, keys)
  if bot_context.reload_count == 3 then
    keys.L1 = true
    keys.R1 = true
    bot_context.running_away = true
  else
    local character = game_context.party[game_context.battle.active_character]
    
    -- use limit break if it's up
    if character.limit_break and character.id ~= 0x02 then
      if game_context.battle.active_menu == 1 then
        if character.main_menu_y ~= 0 then
          pressAndRelease(bot_context, keys, "Up")
        elseif character.main_menu_x ~= 0 then
          pressAndRelease(bot_context, keys, "Right")
        else
          pressAndRelease(bot_context, keys, "Circle")
        end
      else
        pressAndRelease(bot_context, keys, "Circle")
      end 
    -- select "magic hammer" as appropriate (NOT Yuffie)
    elseif character.current_mp < 900 and character.has_materia_enemy_skill and character.id ~= 0x05 then
      if game_context.battle.active_menu == 1 then
        if character.main_menu_y ~= 0 then
          pressAndRelease(bot_context, keys, "Up")
        elseif character.main_menu_x < 1 then
          pressAndRelease(bot_context, keys, "Right")
        else
          pressAndRelease(bot_context, keys, "Circle")
        end
      elseif game_context.battle.active_menu == 4 then
        if character.menu_enemy_skill_y < 1 then
          pressAndRelease(bot_context, keys, "Down")
        else
          pressAndRelease(bot_context, keys, "Circle")
        end
      else
        pressAndRelease(bot_context, keys, "Circle")
      end
    -- select "morph" as appropriate
    elseif character.has_materia_morph then
      if game_context.battle.active_menu == 1 then
        if character.main_menu_y ~= 1 then
          pressAndRelease(bot_context, keys, "Up")
        elseif character.main_menu_x < 1 then
          pressAndRelease(bot_context, keys, "Right")
        else
          pressAndRelease(bot_context, keys, "Circle")
        end
      else
        pressAndRelease(bot_context, keys, "Circle")
      end
    -- select "mug" as appropriate
    elseif character.has_materia_steal then
      if game_context.battle.active_menu == 1 then
        if character.main_menu_y > 0 then
          pressAndRelease(bot_context, keys, "Up")
        elseif character.main_menu_x < 1 then
          pressAndRelease(bot_context, keys, "Right")
        else
          pressAndRelease(bot_context, keys, "Circle")
        end
      else
        pressAndRelease(bot_context, keys, "Circle")
      end 
    else
      pressAndRelease(bot_context, keys, "Circle")
    end
  end
end
