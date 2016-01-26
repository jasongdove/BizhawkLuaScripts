local function bitnumber(p)
  return 2 ^ (p - 1)  -- 1-based indexing
end

local function hasbit(x, p)
  return x % (p + p) >= p
end

local readCharacterByte = function(character_index, offset)
  return mainmemory.read_u8(0x078730 + (character_index * 0x1D0) + offset)
end

local readCharacterWord = function(character_index, offset)
  return mainmemory.read_u16_le(0x078730 + (character_index * 0x1D0) + offset)
end

function updateGameContext(game_context)
  game_context.characters = {}
  game_context.characters_by_id = {}
  
  -- read character data  
  for character_index = 0,2 do
    local character = {}
    
    character.exists = readCharacterByte(character_index, 0x1B3) ~= 0xFF
    character.id = readCharacterByte(character_index, 0x1B3)
    character.current_hp = readCharacterWord(character_index, 0x162)
    character.max_hp = readCharacterWord(character_index, 0x164)
    character.experience = mainmemory.read_u32_le(0x078730 + (character_index * 0x1D0) + 0x168)
    character.level = readCharacterByte(character_index, 0x1A8)
    character.gf_active = readCharacterByte(character_index, 0x0C) == 0x01
    
    character.magic = {}
    if character.exists then
      for magic_index = 0,31 do
        local magic = {}
        
        magic.id = mainmemory.read_u8(0x077818 + (character.id * 0x98) + (magic_index * 0x02) + 0x00)
        magic.quantity = mainmemory.read_u8(0x077818 + (character.id * 0x98) + (magic_index * 0x02) + 0x01)
        
        character.magic[magic_index] = magic
      end
    end
    
    character.commands = {}
    for command_index = 0,3 do
      local command = {}
      
      command.id = readCharacterByte(character_index, (command_index * 0x04) + 0x0E)
      
      if command.id == 0x06 then character.has_command_draw = true end
      character.commands[command_index] = command
    end
    
    -- str, other stats start at 0x139
    
--     if character.exists then
--       console.writeline('character ' .. character_index)
--       
--       local draw_text = 'false'
--       local exists_text = 'false'
--       if character.has_command_draw then draw_text = 'true' end
--       if character.exists then exists_text = 'true' end
-- 
--       console.writeline('      id: ' .. character.id)      
--       console.writeline('  cur hp: ' .. character.current_hp)
--       console.writeline('  max hp: ' .. character.max_hp)
--       console.writeline('     lvl: ' .. character.level)
--       console.writeline('      xp: ' .. character.experience)
--       console.writeline('    draw: ' .. draw_text)
--     end
    
    --console.writeline(character_index .. ": " .. character.id .. ", " .. character.level .. ", " .. character.current_hp .. "/" .. character.max_hp .. ", " .. character.current_mp .. "/" .. character.max_mp)
    
    --character.status = readCharacterByte(character_index, 0x14)
    game_context.characters[character_index] = character
    game_context.characters_by_id[character.id] = character
  end
  
  game_context.menu = {}
  game_context.menu.is_in_menu = mainmemory.read_u16_le(0x1FA5D0) == 0x2458 and mainmemory.read_u16_le(0x1FA5D2) == 0x801F
  
  if game_context.menu.is_in_menu then
    game_context.menu.main_menu_index = mainmemory.read_u8(0x1FA608)
    game_context.menu.active_menu = mainmemory.read_u8(0x1FA60A)
    
    if game_context.menu.active_menu == 0x04 then
      game_context.menu.gf = {}
      game_context.menu.gf.id = mainmemory.read_u8(0x1FA675)

      game_context.menu.gf.active_menu = mainmemory.read_u8(0x1FA670)
      game_context.menu.gf.is_selection_menu_active = game_context.menu.gf.active_menu == 0x00
      game_context.menu.gf.is_status_menu_active = game_context.menu.gf.active_menu == 0x01
      game_context.menu.gf.is_learn_menu_active = game_context.menu.gf.active_menu == 0x02
     
      game_context.menu.gf.learn_menu_page = mainmemory.read_u8(0x1FA676)
      game_context.menu.gf.learn_menu_index_page_1 = mainmemory.read_u8(0x1FA679)
      game_context.menu.gf.learn_menu_index_page_2 = mainmemory.read_u8(0x1FA67A)
      game_context.menu.gf.learn_menu_ability = mainmemory.read_u16_le(0x1FA660)
    end
  end
  
  game_context.battle = {}
  game_context.battle.is_in_battle = mainmemory.read_u16_le(0x0ECB90) == 0x0040 and mainmemory.read_u16_le(0x0ECB92) == 0x0139 and mainmemory.read_u16_le(0x0ECB94) == 0xFF00
  game_context.battle.is_accepting_rewards = mainmemory.read_u8(0x0771D4) == 0x02 -- mainmemory.read_u16_le(0x0ECB90) == 0x0000 and mainmemory.read_u16_le(0x0ECB92) == 0x0000 and (mainmemory.read_u16_le(0x0ECB94) == 0xF070 or mainmemory.read_u16_le(0x0ECB94) == 0x0000)
  
  if game_context.battle.is_in_battle then
    for character_index = 0,2 do
      game_context.characters[character_index].can_act = mainmemory.read_u16_le(0x0788A4 + (character_index * 0x1D0)) == 0x2EE0 and not game_context.characters[character_index].gf_active
    end
  
    game_context.battle.active_character = mainmemory.read_u8(0x10331C)
    game_context.battle.main_menu_index = mainmemory.read_u8(0x10331B)
    game_context.battle.cursor_location = mainmemory.read_u8(0x1032A0)
    game_context.battle.is_main_menu_active = game_context.battle.cursor_location == 0x00
      or game_context.battle.cursor_location == 0x04
      or game_context.battle.cursor_location == 0x05
      or game_context.battle.cursor_location == 0x07
      or game_context.battle.cursor_location == 0x22
      or game_context.battle.cursor_location == 0x2A
      or game_context.battle.cursor_location == 0x88
      or game_context.battle.cursor_location == 0xC8
    game_context.battle.is_gf_menu_active = mainmemory.read_u8(0x103300) == 0xBC
    
    local enemy_flag = mainmemory.read_u8(0x103254)
    if enemy_flag == 8 then
      game_context.battle.target_enemy = 0
    elseif enemy_flag == 16 then
      game_context.battle.target_enemy = 1
    elseif enemy_flag == 32 then
      game_context.battle.target_enemy = 2
    end
    
    local character_flag = mainmemory.read_u8(0x103254)
    if character_flag == 1 then
      game_context.battle.target_character = 0
    elseif character_flag == 2 then
      game_context.battle.target_character = 1
    elseif character_flag == 4 then
      game_context.battle.target_character = 2
    end
    
    game_context.battle.draw_magic_id = mainmemory.read_u8(0x1032AC)
    game_context.battle.draw_action = mainmemory.read_u8(0x1032A9)
    game_context.battle.is_limit_break = mainmemory.read_u8(0x103329) == 0x5A and mainmemory.read_u8(0x10332A) == 0x4A
  
    game_context.battle.enemies = {}
    
    for enemy_index = 0,3 do
      local enemy = {}
      
      enemy.current_hp = mainmemory.read_u16_le(0x0ED3D0 + (enemy_index * 0xD0) + 0x10)
      enemy.max_hp = mainmemory.read_u16_le(0x0ED3D0 + (enemy_index * 0xD0) + 0x14)
      enemy.exists = enemy.max_hp > 0
      enemy.is_alive = enemy.current_hp > 0 -- mainmemory.read_u8(0x0ED3D0 + (enemy_index * 0xD0) + 0x74) ~= 0x00
      enemy.is_card = mainmemory.read_u8(0x0ED3D0 + (enemy_index * 0xD0) + 0x02) == 0x01
      
      enemy.magic = {}
      for magic_index = 0,3 do
        enemy.magic[magic_index] = {}
        enemy.magic[magic_index].id = mainmemory.read_u8(0x0EEA88 + (enemy_index * 0x47) + (magic_index * 0x04))
        enemy.magic[magic_index].is_unknown = mainmemory.read_u8(0x0EEA88 + (enemy_index * 0x47) + (magic_index * 0x04) + 0x01) == 0x08
      end
      
      game_context.battle.enemies[enemy_index] = enemy
    end
  else
    game_context.gfs = {}
    
    for gf_index = 0,15 do
      local gf = {}
      
      gf.id = gf_index
      gf.name = ''
      for gf_name_index = 0,11 do
        local char = mainmemory.read_u8(0x0773C8 + (gf_index * 0x44) + gf_name_index)
        if char > 0 then
          if char >= 0x45 and char <= 0x5E then
            gf.name = gf.name .. string.char(char - 0x04)
          elseif char >= 0x5F and char <= 0x78 then
            gf.name = gf.name .. string.char(char + 0x02)
          end
        end
      end
      
      gf.xp = mainmemory.read_u16_le(0x0773C8 + (gf_index * 0x44) + 0xC)
      gf.is_active = mainmemory.read_u8(0x0773C8 + (gf_index * 0x44) + 0x11) == 0x01
      
      if gf.is_active then
        --console.writeline(gf.name)
        --console.writeline('      xp: ' .. gf.xp)
        
        gf.abilities = {}
        for ability_flag_index = 0,14 do
          local ability_flags = mainmemory.read_u8(0x0773C8 + (gf_index * 0x44) + 0x14 + ability_flag_index)
          for f = 0,7 do
            local ability_id = ability_flag_index * 8 + f
            gf.abilities[ability_id] = { completed = hasbit(ability_flags, bitnumber(f + 1)) }
          end
        end
        
        gf.active_ability = mainmemory.read_u8(0x0773C8 + (gf_index * 0x44) + 0x40)
      end
      
      game_context.gfs[gf_index] = gf
    end
  end
  
end

-- this function should perform common aggregations on the game_context so they don't have to be
-- recalculated by each state. it should NOT directly indicate which states should run
function updateBotContext(config, game_context, bot_context)
  bot_context.reload_count = bot_context.reload_count or 0
  
  for character_index = 0,2 do
    bot_context.characters = bot_context.characters or {}
    bot_context.characters_by_id = bot_context.characters_by_id or {}
    bot_context.characters[character_index] = bot_context.characters[character_index] or {}
    bot_context_character = bot_context.characters[character_index]
    bot_context_character.can_act = true
    
    if game_context.battle.is_in_battle then
      bot_context_character.queued_frames = bot_context_character.queued_frames or 0
      
      if bot_context_character.queued then
        bot_context_character.queued_frames = bot_context_character.queued_frames + 1
        
        if not game_context.characters[character_index].can_act then
          bot_context_character.queued = false
          bot_context_character.queued_frames = 0
        elseif bot_context_character.queued_frames > 20 then
          bot_context_character.can_act = false
        end 
      end
      
      local character = game_context.characters[character_index]
      bot_context.characters_by_id[character.id] = bot_context_character
      bot_context_character.can_draw = false
    
      if character.exists and character.has_command_draw then
        -- enemy must have magic that this player does not have capped
        for enemy_index = 0,3 do
          if game_context.battle.enemies[enemy_index].is_alive then
            for enemy_magic_index = 0,3 do
              local magic_id = game_context.battle.enemies[enemy_index].magic[enemy_magic_index].id
              
              if game_context.battle.enemies[enemy_index].magic[enemy_magic_index].is_unknown then
                bot_context_character.can_draw = true
                break
              end
              
              local has_magic = false
              if magic_id > 0 then
                for character_magic_index = 0,31 do
                  if character.magic[character_magic_index] ~= nil then
                    if character.magic[character_magic_index].id == magic_id then
                      has_magic = true
                      if character.magic[character_magic_index].quantity < 100 then
                        bot_context_character.can_draw = true
                        break
                      end
                    end
                  end
                end

                -- if we didn't find the magic, check if we have room to draw a new magic
                if not has_magic and not character.can_draw then
                  for character_magic_index = 0,31 do
                    if character.magic[character_magic_index] ~= nil then
                      if character.magic[character_magic_index].id == 0x00 then
                        bot_context_character.can_draw = true
                        break
                      end
                    end
                  end
                end  
                
                if bot_context_character.can_draw then break end
              end
            end
            
            if bot_context_character.can_draw then break end
          end
        end
      end
    end
  end
  
  return bot_context
end