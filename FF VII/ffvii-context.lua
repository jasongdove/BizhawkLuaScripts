local MATERIA_STEAL = 0x24
local MATERIA_MORPH = 0x28
local MATERIA_ENEMY_SKILL = 0x2C

local ITEM_TENT = 0x46
local ITEM_POWER_SOURCE = 0x47
local ITEM_GUARD_SOURCE = 0x48
local ITEM_MAGIC_SOURCE = 0x49
local ITEM_MIND_SOURCE = 0x4A
local ITEM_SPEED_SOURCE = 0x4B
local ITEM_LUCK_SOURCE = 0x4C

local readCharacterByte = function(character_index, offset)
  return mainmemory.read_u8(0x09C738 + (character_index * 0x84) + offset)
end

local readCharacterWord = function(character_index, offset)
  return mainmemory.read_u16_le(0x09C738 + (character_index * 0x84) + offset)
end

function updateGameContext(game_context)
  game_context.is_in_overworld = mainmemory.read_u8(0x0E55FC) == 0x01 or mainmemory.read_u8(0x0E55FC) == 248

  game_context.menu = {}
  game_context.menu.is_in_menu = mainmemory.read_u8(0x062C27) == 0x01
  
  if game_context.menu.is_in_menu then
    game_context.menu.main_menu_index = mainmemory.read_u8(0x09A0D3)
    game_context.menu.is_selecting_character = mainmemory.read_u8(0x062F64) == 0x01
    game_context.menu.active_menu_page = mainmemory.read_u8(0x062DD4)
    game_context.menu.selected_character_index = mainmemory.read_u8(0x09A0E5)
    game_context.menu.magic_submenu = mainmemory.read_u8(0x1D2930)
    game_context.menu.magic_spell_x = mainmemory.read_u8(0x1D2AAA)
    game_context.menu.magic_spell_y = mainmemory.read_u8(0x1D2AAB)
    game_context.menu.magic_selected_character_index = mainmemory.read_u8(0x1D2A99)
    game_context.menu.is_accepting_xp = mainmemory.read_u8(0x062DDA) == 0x00
    game_context.menu.is_accepting_items = mainmemory.read_u8(0x0513B6) == 0x05
    game_context.menu.item_top_item = mainmemory.read_u8(0x1D3DF0)
    game_context.menu.item_selected_item = mainmemory.read_u8(0x1D3DF9)
    game_context.menu.item_submenu = mainmemory.read_u8(0x1D3E48)
    game_context.menu.item_selected_character_index = mainmemory.read_u8(0x1D3E0B)
  end

  game_context.characters = {}
  
  -- read character data  
  for character_index = 0,8 do
    local character = {}
    
    character.id = readCharacterByte(character_index, 0x00)
    character.level = readCharacterByte(character_index, 0x01)

    character.strength = readCharacterByte(character_index, 0x02)
    character.vitality = readCharacterByte(character_index, 0x03)
    character.magic = readCharacterByte(character_index, 0x04)
    character.spirit = readCharacterByte(character_index, 0x05)
    character.dexterity = readCharacterByte(character_index, 0x06)
    character.luck = readCharacterByte(character_index, 0x07)

    character.strength_bonus = readCharacterByte(character_index, 0x08)
    character.vitality_bonus = readCharacterByte(character_index, 0x09)
    character.magic_bonus = readCharacterByte(character_index, 0x0A)
    character.spirit_bonus = readCharacterByte(character_index, 0x0B)
    character.dexterity_bonus = readCharacterByte(character_index, 0x0C)
    character.luck_bonus = readCharacterByte(character_index, 0x0D)
    
    character.limit_break = readCharacterByte(character_index, 0x0F) == 0xFF

    character.number_of_kills = readCharacterWord(character_index, 0x24)
    character.current_hp = readCharacterWord(character_index, 0x2C)
    character.max_hp = readCharacterWord(character_index, 0x38)
    character.current_mp = readCharacterWord(character_index, 0x30)
    character.max_mp = readCharacterWord(character_index, 0x3A)
    
    --console.writeline(character_index .. ": " .. character.id .. ", " .. character.level .. ", " .. character.current_hp .. "/" .. character.max_hp .. ", " .. character.current_mp .. "/" .. character.max_mp)
    
    --character.status = readCharacterByte(character_index, 0x14)
    
    for materia_index = 0,15 do
      local materia_id = mainmemory.read_u8(0x09C738 + (character_index * 0x84) + 0x40 + (materia_index * 4)) 
      if materia_id == MATERIA_STEAL then
        character.has_materia_steal = true
      end

      if materia_id == MATERIA_MORPH then
        character.has_materia_morph = true
      end

      if materia_id == MATERIA_ENEMY_SKILL then
        character.has_materia_enemy_skill = true
      end
    end
    
    game_context.characters[character.id] = character
  end
  
  game_context.party = {}
  game_context.party[0] = game_context.characters[mainmemory.read_u8(0x09CBDC)]
  game_context.party[1] = game_context.characters[mainmemory.read_u8(0x09CBDD)]
  game_context.party[2] = game_context.characters[mainmemory.read_u8(0x09CBDE)]
  
  local has_level_change = false
  game_context.party_levels = game_context.party_levels or { 0, 0, 0 }
  if game_context.party[0].level ~= game_context.party_levels[0] then
    game_context.party_levels[0] = game_context.party[0].level
    has_level_change = true
  end
  if game_context.party[1].level ~= game_context.party_levels[1] then
    game_context.party_levels[1] = game_context.party[1].level
    has_level_change = true
  end
  if game_context.party[2].level ~= game_context.party_levels[2] then
    game_context.party_levels[2] = game_context.party[2].level
    has_level_change = true
  end
  
  if has_level_change then
    console.writeline("levels: " .. game_context.party[0].level .. " / " .. game_context.party[1].level .. " / " .. game_context.party[2].level)
  end
  
  -- read battle data
  game_context.battle = {}
  game_context.battle.is_in_battle = (mainmemory.read_u16_le(0x051400) == 0x01) or (mainmemory.read_u16_le(0x051400) == 4308) -- 4308 == enemy skill menu
  
  if game_context.battle.is_in_battle then
    game_context.battle.active_character = mainmemory.read_u8(0x0F38A0)
    game_context.battle.active_menu = mainmemory.read_u8(0x0F3896)
    game_context.battle.is_waiting = game_context.battle.active_menu == 255
    game_context.battle.is_targeting = mainmemory.read_u8(0x0F311C) == 1
    game_context.battle.enemy_count = mainmemory.read_u16_le(0x0F7E04)
    
    game_context.party[0].main_menu_x = mainmemory.read_u8(0x0F90BE) 
    game_context.party[0].main_menu_y = mainmemory.read_u8(0x0F90BF)
    game_context.party[0].menu_enemy_skill_y = mainmemory.read_u8(0x0F9107)
    
    game_context.party[1].main_menu_x = mainmemory.read_u8(0x0F92FE) 
    game_context.party[1].main_menu_y = mainmemory.read_u8(0x0F92FF)
    game_context.party[1].menu_enemy_skill_y = mainmemory.read_u8(0x0F9347)

    game_context.party[2].main_menu_x = mainmemory.read_u8(0x0F953E) 
    game_context.party[2].main_menu_y = mainmemory.read_u8(0x0F953F)
    game_context.party[2].menu_enemy_skill_y = mainmemory.read_u8(0x0F9587)

    game_context.battle.enemies = {}
    for enemy_index = 0,game_context.battle.enemy_count do
      local enemy = {}
      
      enemy.current_hp = mainmemory.read_u16_le(0x0F85AC + (enemy_index * 0x68))
      enemy.max_hp = mainmemory.read_u16_le(0x0F85B0 + (enemy_index * 0x68))
      
      game_context.battle.enemies[enemy_index] = enemy
    end
  else
    game_context.items = {}
    
    for item_index = 0,319 do
      local item_id = mainmemory.read_u8(0x9CBE0 + item_index * 2)
      local item_quantity = bit.rshift(mainmemory.read_u8(0x9CBE1 + item_index * 2), 1)
      if item_id == ITEM_TENT then
        game_context.items.tent_index = item_index
        game_context.items.tent_quantity = item_quantity
      elseif item_id == ITEM_GUARD_SOURCE then
        game_context.items.guard_source_index = item_index
        game_context.items.guard_source_quantity = item_quantity
      elseif item_id == ITEM_POWER_SOURCE then
        game_context.items.power_source_index = item_index
        game_context.items.power_source_quantity = item_quantity
      elseif item_id == ITEM_MAGIC_SOURCE then
        game_context.items.magic_source_index = item_index
        game_context.items.magic_source_quantity = item_quantity
      elseif item_id == ITEM_MIND_SOURCE then
        game_context.items.mind_source_index = item_index
        game_context.items.mind_source_quantity = item_quantity
      elseif item_id == ITEM_SPEED_SOURCE then
        game_context.items.speed_source_index = item_index
        game_context.items.speed_source_quantity = item_quantity
      elseif item_id == ITEM_LUCK_SOURCE then
        game_context.items.luck_source_index = item_index
        game_context.items.luck_source_quantity = item_quantity
      end
    end
  end
end

-- this function should perform common aggregations on the game_context so they don't have to be
-- recalculated by each state. it should NOT directly indicate which states should run
function updateBotContext(config, game_context, bot_context)
  bot_context.has_uncapped_levels = false

  local stat_item_high = 90
  local stat_item_low = 10
  
  if game_context.battle.is_in_battle then
    game_context.should_use_stat_items = false
  else
    if not bot_context.should_use_stat_items then
      if (game_context.items.power_source_index ~= nil and game_context.items.power_source_quantity >= stat_item_high)
        or (game_context.items.guard_source_index ~= nil and game_context.items.guard_source_quantity >= stat_item_high)
        or (game_context.items.magic_source_index ~= nil and game_context.items.magic_source_quantity >= stat_item_high)
        or (game_context.items.mind_source_index ~= nil and game_context.items.mind_source_quantity >= stat_item_high)
        or (game_context.items.speed_source_index ~= nil and game_context.items.speed_source_quantity >= stat_item_high)
        or (game_context.items.luck_source_index ~= nil and game_context.items.luck_source_quantity >= stat_item_high) then
        bot_context.should_use_stat_items = true
        console.writeline('using stat items')
      end
    else
      if (game_context.items.power_source_index ~= nil and game_context.items.power_source_quantity <= stat_item_low)
        and (game_context.items.guard_source_index ~= nil and game_context.items.guard_source_quantity <= stat_item_low)
        and (game_context.items.magic_source_index ~= nil and game_context.items.magic_source_quantity <= stat_item_low)
        and (game_context.items.mind_source_index ~= nil and game_context.items.mind_source_quantity <= stat_item_low)
        and (game_context.items.speed_source_index ~= nil and game_context.items.speed_source_quantity <= stat_item_low)
        and (game_context.items.luck_source_index ~= nil and game_context.items.luck_source_quantity <= stat_item_low) then
        bot_context.should_use_stat_items = false
      end
    end
  end
  
  for character_index = 0,2 do
    local character = game_context.party[character_index]
    
    -- check for uncapped levels
    if character.level < config.TARGET_LEVEL then
      bot_context.has_uncapped_levels = true
    end
     
    if not game_context.battle.is_in_battle then
      if bot_context.should_use_stat_items then
        if game_context.items.power_source_index ~= nil and game_context.items.power_source_quantity > stat_item_low then
          if character.strength + character.strength_bonus < 255 then
            character.has_uncapped_strength = true
          end
        end
        
        if game_context.items.guard_source_index ~= nil and game_context.items.guard_source_quantity > stat_item_low then
          if character.vitality + character.vitality_bonus < 255 then
            character.has_uncapped_vitality = true
          end
        end

        if game_context.items.magic_source_index ~= nil and game_context.items.magic_source_quantity > stat_item_low then
          if character.magic + character.magic_bonus < 255 then
            character.has_uncapped_magic = true
          end
        end

        if game_context.items.mind_source_index ~= nil and game_context.items.mind_source_quantity > stat_item_low then
          if character.spirit + character.spirit_bonus < 255 then
            character.has_uncapped_spirit = true
          end
        end

        if game_context.items.speed_source_index ~= nil and game_context.items.speed_source_quantity > stat_item_low then
          if character.dexterity + character.dexterity_bonus < 255 then
            character.has_uncapped_dexterity = true
          end
        end

        if game_context.items.luck_source_index ~= nil and game_context.items.luck_source_quantity > stat_item_low then
          if character.luck + character.luck_bonus < 255 then
            character.has_uncapped_luck = true
          end
        end
      end
    end
  end
  
  bot_context.reload_count = bot_context.reload_count or 0
  
  return bot_context
end