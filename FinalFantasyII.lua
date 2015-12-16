local function text(x,y,str)
	if (x > 0 and x < 255 and y > 0 and y < 240) then
		gui.text(x,y,str)
	end
end

local function bit(p)
  return 2 ^ (p - 1)  -- 1-based indexing
end

local function hasbit(x, p)
  return x % (p + p) >= p       
end

local function getgamecontext(game_context)
	game_context.is_in_battle = memory.readbyte(0x002E) == 0xB8
	game_context.is_in_overworld = not hasbit(memory.readbyte(0x002D), bit(1)) and not game_context.is_in_battle
	game_context.is_something_happening = memory.readbyte(0x0034) ~= 0x00
	game_context.overworld_x = memory.readbyte(0x0027)
	game_context.active_character = memory.readbyte(0x0012)
	game_context.cursor_location = memory.readbyte(0x000B)
	game_context.target_character = memory.readbyte(0x000C)
	game_context.target_enemy = memory.readbyte(0x000D)
	game_context.menu_x = memory.readbyte(0x0053)
	game_context.menu_y = memory.readbyte(0x0054)
	game_context.is_magic_menu_open = memory.readbyte(0x7CBA) == 0x01
end

local function findbattle(game_context, bot_context)
	text(2, 10, "find a battle")
	local keys = {}
	
	if not game_context.is_something_happening then
		if game_context.overworld_x == bot_context.previous_overworld_x then
			if bot_context.is_headed_left then
				keys.left = nil
			else
				keys.right = nil
			end
			
			bot_context.is_headed_left = not bot_context.is_headed_left
		end
	
		if bot_context.is_headed_left then
			keys.left = 1
		else
			keys.right = 1
		end
		
		joypad.set(1, keys)
		bot_context.previous_overworld_x = game_context.overworld_x
	end
end

local function winbattle(game_context, bot_context)
	text(2, 10, "win a battle")
	local keys = {}
	
	if not game_context.is_something_happening and game_context.overworld_x == 2 then
		if not bot_context.is_save_required then
			-- if we have a save queued, undo the last action
			keys.B = 1
			bot_context.is_save_required = true
		else
			-- auto-attack to kill all enemies
			keys.A = 1
		end
		
		joypad.set(1, keys)
	end
end

local function savegame(game_context, bot_context)
	text(2, 10, "saving...")
	
	if not game_context.is_something_happening then
		--FCEU.print("saving....")
		savestate.save(bot_context.save_state)
		
		bot_context.is_save_required = false
	end
end

local function getbotcontext(game_context, bot_context)
	bot_context.magic_to_level = nil
	bot_context.should_finish_battle = false
	
	local max_spell_level = 5

	-- check for capped magic (queued in a battle)
	if game_context.is_in_battle then
		for character_index = 0,2 do
			for spell_index = 0,15 do
				if memory.readbyte(0x6100 + (character_index * 0x0040) + 0x0030 + spell_index) ~= 0x00 then
					local spell_level = memory.readbyte(0x6200 + (character_index * 0x0040) + 0x0010 + (spell_index * 2)) + 1
					local spell_skill = memory.readbyte(0x6200 + (character_index * 0x0040) + 0x0010 + (spell_index * 2) + 1)
					local spell_skill_queue = memory.readbyte(0x7CF7 + (character_index * 0x0010) + spell_index) 
					
					if spell_level < max_spell_level and spell_skill + spell_skill_queue == 100 then
						bot_context.should_finish_battle = true
						break
					end
				end
			end
			
			if bot_context.should_finish_battle then break end
		end
	end

	if not bot_context.should_finish_battle then
		for character_index = 0,2 do
			for spell_index = 0,15 do
				if memory.readbyte(0x6100 + (character_index * 0x0040) + 0x0030 + spell_index) ~= 0x00 then
					local spell_level = memory.readbyte(0x6200 + (character_index * 0x0040) + 0x0010 + (spell_index * 2)) + 1
					local spell_skill = memory.readbyte(0x6200 + (character_index * 0x0040) + 0x0010 + (spell_index * 2) + 1)
					local spell_skill_queue = memory.readbyte(0x7CF7 + (character_index * 0x0010) + spell_index) 
					
					if spell_level < max_spell_level and spell_skill + spell_skill_queue < 100 then
						bot_context.magic_to_level = {}
						bot_context.magic_to_level.character_index = character_index
						bot_context.magic_to_level.spell_index = spell_index
						bot_context.magic_to_level.spell_level = spell_level
						bot_context.magic_to_level.spell_skill = spell_skill
						bot_context.magic_to_level.spell_skill_queue = spell_skill_queue
						break
					end
				end
			end
			
			if bot_context.magic_to_level ~= nil then break end
		end
	end
	
	return bot_context
end

local function levelmagic(game_context, bot_context)
	text(2, 10, "level magic c" .. bot_context.magic_to_level.character_index .. " s" .. bot_context.magic_to_level.spell_index .. " " .. bot_context.magic_to_level.spell_level .. "-" .. string.format("%02d", bot_context.magic_to_level.spell_skill) .. "+" .. string.format("%02d", bot_context.magic_to_level.spell_skill_queue))

	if not game_context.is_something_happening and game_context.overworld_x == 2 then
		local keys = {}
		
		if game_context.active_character > bot_context.magic_to_level.character_index then
			-- cancel actions to select character
			keys.B = 1
		elseif game_context.active_character < bot_context.magic_to_level.character_index then
			-- auto attack to select character
			keys.A = 1
		elseif game_context.cursor_location == bot_context.magic_to_level.character_index * 8 + 1 and not game_context.is_magic_menu_open then
			-- select 'magic' menu item
			if game_context.menu_y == 0 then keys.down = 1
			elseif game_context.menu_y == 1 then keys.down = 1
			elseif game_context.menu_y == 2 then keys.A = 1
			elseif game_context.menu_y == 3 then keys.up = 1
			end
		elseif game_context.cursor_location == bot_context.magic_to_level.character_index * 8 + 1 and game_context.is_magic_menu_open then
			-- select the spell to level
			local target_row = math.floor(bot_context.magic_to_level.spell_index / 4)
			local target_column = math.fmod(bot_context.magic_to_level.spell_index, 4)
			
			if target_row < game_context.menu_y then keys.up = 1
			elseif target_row > game_context.menu_y then keys.down = 1
			elseif target_column < game_context.menu_x then keys.left = 1
			elseif target_column > game_context.menu_x then keys.right = 1
			else keys.A = 1
			end
		elseif game_context.cursor_location == 0 then
			if game_context.target_character ~= 132 then keys.up = 1
			else keys.A = 1
			end
		elseif game_context.cursor_location == 255 then
			if game_context.target_enemy ~= 136 then keys.up = 1
			else keys.A = 1
			end
		end
		
		joypad.set(1, keys)
	end
end

do
	local bot_context = {}
	local game_context = {}
	
	bot_context.save_state = savestate.object(4)
	FCEU.speedmode("turbo")
	--bot_context.is_save_required = true
	
	while true do
		getgamecontext(game_context)
		getbotcontext(game_context, bot_context)
	
		if game_context.is_in_overworld and bot_context.is_save_required then
			savegame(game_context, bot_context)
		elseif game_context.is_in_overworld and bot_context.magic_to_level ~= nil then
			findbattle(game_context, bot_context)
		elseif game_context.is_in_battle and bot_context.magic_to_level ~= nil then
			levelmagic(game_context, bot_context)
		elseif game_context.is_in_battle and bot_context.should_finish_battle then
			winbattle(game_context, bot_context)
		else
			text(2, 10, "nothing to do...")
		end
		
		FCEU.frameadvance()
	end
end
