local readCharacterByte = function(character_index, offset)
  return mainmemory.read_u8(0x09C738 + (character_index * 0x84) + offset)
end

local readCharacterWord = function(character_index, offset)
  return mainmemory.read_u16_le(0x09C738 + (character_index * 0x84) + offset)
end

function updateGameContext(game_context)
  game_context.is_in_overworld = mainmemory.read_u8(0x0E55FC) == 0x01

  game_context.menu = {}
  game_context.menu.is_in_menu = mainmemory.read_u8(0x062C27) == 0x01
  
  if game_context.menu.is_in_menu then
    game_context.menu.main_menu_index = mainmemory.read_u8(0x09A0D3)
    game_context.menu.is_selecting_character = mainmemory.read_u8(0x062F64) == 0x01
    game_context.menu.active_menu_page = mainmemory.read_u8(0x062DD4)
    game_context.menu.selected_character_index = mainmemory.read_u8(0x09A0E5)
    game_context.menu.magic_submenu = mainmemory.read_u8(0x1D2930)
    game_context.menu.magic_selected_character_index = mainmemory.read_u8(0x1D2A99)
    game_context.menu.is_accepting_xp = mainmemory.read_u8(0x062DDA) == 0x00
    game_context.menu.is_accepting_items = mainmemory.read_u8(0x0513B6) == 0x05
    game_context.menu.item_top_item = mainmemory.read_u8(0x1D3DF0)
    game_context.menu.item_selected_item = mainmemory.read_u8(0x1D3DF9)
    game_context.menu.item_submenu = mainmemory.read_u8(0x1D3E48)
  end

  game_context.characters = {}
  
  -- read character data  
  for character_index = 0,8 do
    local character = {}
    
    character.id = readCharacterByte(character_index, 0x00)
    character.level = readCharacterByte(character_index, 0x01)
    character.current_hp = readCharacterWord(character_index, 0x2C)
    character.max_hp = readCharacterWord(character_index, 0x38)
    character.current_mp = readCharacterWord(character_index, 0x30)
    character.max_mp = readCharacterWord(character_index, 0x3A)
    
    --console.writeline(character_index .. ": " .. character.id .. ", " .. character.level .. ", " .. character.current_hp .. "/" .. character.max_hp .. ", " .. character.current_mp .. "/" .. character.max_mp)
    
    --character.status = readCharacterByte(character_index, 0x14)
    
    game_context.characters[character.id] = character
  end
  
  game_context.party = {}
  game_context.party[0] = game_context.characters[mainmemory.read_u8(0x09CBDC)]
  game_context.party[1] = game_context.characters[mainmemory.read_u8(0x09CBDD)]
  game_context.party[2] = game_context.characters[mainmemory.read_u8(0x09CBDE)]
  
  -- read battle data
  game_context.battle = {}
  game_context.battle.is_in_battle = mainmemory.read_u16_le(0x051400) == 0x01
  
  if game_context.battle.is_in_battle then
    game_context.battle.active_menu = mainmemory.read_u8(0x0F3896)
    game_context.battle.is_waiting = game_context.battle.active_menu == 255
    game_context.battle.is_targeting = mainmemory.read_u8(0x0F311C) == 1
    game_context.battle.enemy_count = mainmemory.read_u16_le(0x0F7E04)
    
    game_context.battle.enemies = {}
    for enemy_index = 0,game_context.battle.enemy_count do
      local enemy = {}
      
      enemy.current_hp = mainmemory.read_u16_le(0x0F85AC + (enemy_index * 0x68))
      enemy.max_hp = mainmemory.read_u16_le(0x0F85B0 + (enemy_index * 0x68))
      
      game_context.battle.enemies[enemy_index] = enemy
    end
  end
end

-- this function should perform common aggregations on the game_context so they don't have to be
-- recalculated by each state. it should NOT directly indicate which states should run
function updateBotContext(config, game_context, bot_context)
  bot_context.has_uncapped_levels = false

  for character_index = 0,2 do
    local character = game_context.party[character_index]
    
    -- check for uncapped levels
    if character.level < config.TARGET_LEVEL then
      bot_context.has_uncapped_levels = true
    end
  end
  
  bot_context.reload_count = bot_context.reload_count or 0
  
  return bot_context
end