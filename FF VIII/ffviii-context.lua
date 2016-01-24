local readCharacterByte = function(character_index, offset)
  return mainmemory.read_u8(0x07873E + (character_index * 0x1D0) + offset)
end

local readCharacterWord = function(character_index, offset)
  return mainmemory.read_u16_le(0x07873E + (character_index * 0x1D0) + offset)
end

function updateGameContext(game_context)
  game_context.characters = {}
  
  -- read character data  
  for character_index = 0,2 do
    local character = {}
    
    character.exists = readCharacterByte(character_index, 0x1A5) ~= 0xFF
    character.id = readCharacterByte(character_index, 0x1A5)
    character.current_hp = readCharacterWord(character_index, 0x154)
    character.max_hp = readCharacterWord(character_index, 0x156)
    character.experience = mainmemory.read_u32_le(0x07873E + (character_index * 0x1D0) + 0x15A)
    character.level = readCharacterByte(character_index, 0x19A)
    
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
      
      command.id = readCharacterByte(character_index, (command_index * 0x04) + 0x00)
      
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
  end
  
  game_context.battle = {}
  game_context.battle.is_in_battle = mainmemory.read_u16_le(0x0ECB90) == 0x0040 and mainmemory.read_u16_le(0x0ECB92) == 0x0139 and mainmemory.read_u16_le(0x0ECB94) == 0xFF00
  game_context.battle.is_accepting_rewards = mainmemory.read_u16_le(0x0ECB90) == 0x0000 and mainmemory.read_u16_le(0x0ECB92) == 0x0000 and (mainmemory.read_u16_le(0x0ECB94) == 0xF070 or mainmemory.read_u16_le(0x0ECB94) == 0x0000)  
  
  if game_context.battle.is_in_battle then
    for character_index = 0,2 do
      game_context.characters[character_index].can_act = mainmemory.read_u16_le(0x0788A4 + (character_index * 0x1D0)) == 0x2EE0
    end
  
    game_context.battle.active_character = mainmemory.read_u8(0x10331C)
    game_context.battle.main_menu_index = mainmemory.read_u8(0x10331B)
    game_context.battle.cursor_location = mainmemory.read_u8(0x1032A0)
    game_context.battle.is_main_menu_active = mainmemory.read_u8(0x103312)
    game_context.battle.target_enemy = math.log(mainmemory.read_u8(0x103254) / 0x08, 0x02)
    game_context.battle.target_character = mainmemory.read_u8(0x103254) % 0x08
    game_context.battle.draw_magic_id = mainmemory.read_u8(0x1032AC)
    game_context.battle.draw_action = mainmemory.read_u8(0x1032A9)
  
    game_context.battle.enemies = {}
    
    for enemy_index = 0,2 do
      local enemy = {}
      
      enemy.is_alive = mainmemory.read_u8(0x0ED3D0 + (enemy_index * 0xD0) + 0x74) ~= 0x00
      
      enemy.magic = {}
      for magic_index = 0,3 do
        enemy.magic[magic_index] = {}
        enemy.magic[magic_index].id = mainmemory.read_u8(0x0EEA88 + (enemy_index * 0x47) + (magic_index * 0x04))
        enemy.magic[magic_index].is_unknown = mainmemory.read_u8(0x0EEA88 + (enemy_index * 0x47) + (magic_index * 0x04) + 0x01) == 0x08
      end
      
      game_context.battle.enemies[enemy_index] = enemy
    end
  end
  
end

-- this function should perform common aggregations on the game_context so they don't have to be
-- recalculated by each state. it should NOT directly indicate which states should run
function updateBotContext(config, game_context, bot_context)
  bot_context.reload_count = bot_context.reload_count or 0
  
  for character_index = 0,2 do
    bot_context.characters = bot_context.characters or {}
    bot_context.characters[character_index] = bot_context.characters[character_index] or {}
    bot_context.characters[character_index].can_act = true
    
    if game_context.battle.is_in_battle then
      bot_context.characters[character_index].queued_frames = bot_context.characters[character_index].queued_frames or 0
      
      if bot_context.characters[character_index].queued then
        bot_context.characters[character_index].queued_frames = bot_context.characters[character_index].queued_frames + 1
        
        if not game_context.characters[character_index].can_act then
          bot_context.characters[character_index].queued = false
          bot_context.characters[character_index].queued_frames = 0
        elseif bot_context.characters[character_index].queued_frames > 20 then
          bot_context.characters[character_index].can_act = false
        end 
      end
    end
  end
  
  return bot_context
end