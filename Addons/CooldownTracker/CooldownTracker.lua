_addon.name = 'CooldownTracker'
_addon.author = 'Spikex'
_addon.version = '1.2'
_addon.commands = {'cooldown', 'cd'}

config = require('config')
packets = require('packets')
res = require('resources')
texts = require('texts')
require('sets')

defaults = {}
defaults.pos = {}
defaults.pos.x = 100
defaults.pos.y = 100
defaults.text = {}
defaults.text.size = 12
defaults.text.font = 'Consolas'
defaults.padding = 8
defaults.filter = S{}  -- Abilities to track
defaults.visible = true

settings = config.load(defaults)

-- Display window
show_display = true

-- Colors cycled through for each character, in order of first appearance
local color_palette = {
	{255, 255, 255}, -- white
	{255, 215,   0}, -- gold
	{102, 204, 255}, -- light blue
	{153, 255, 153}, -- light green
	{255, 153, 204}, -- pink
	{255, 153,  51}, -- orange
	{204, 153, 255}, -- purple
	{255, 102, 102}, -- red
}

-- Persistent char_name -> color_palette index, assigned on first sighting
local char_colors = {}
local next_color_index = 1

-- One text box per character: char_name -> text object
local char_boxes = {}

-- Deep-copies a settings table so each character's text box can move/resize
-- independently without disturbing the saved user settings
local function deep_copy(orig)
	if type(orig) ~= 'table' then
		return orig
	end
	local copy = {}
	for k, v in pairs(orig) do
		copy[k] = deep_copy(v)
	end
	return copy
end

-- Returns the {r, g, b} color assigned to a character, assigning a new one
-- from the palette (cycling) the first time a character is seen
local function get_char_color(char_name)
	if not char_colors[char_name] then
		char_colors[char_name] = ((next_color_index - 1) % #color_palette) + 1
		next_color_index = next_color_index + 1
	end
	return color_palette[char_colors[char_name]]
end

-- Returns the text box for a character, creating it (with its assigned
-- color, and no background of its own) if it doesn't exist yet
local function get_char_box(char_name)
	local box = char_boxes[char_name]
	if not box then
		local box_settings = deep_copy(settings)
		box = texts.new('${content}', box_settings)
		box:bg_visible(false) -- individual boxes rely on the shared container's background
		local color = get_char_color(char_name)
		box:color(color[1], color[2], color[3])
		char_boxes[char_name] = box
	end
	return box
end

-- Single shared background box drawn behind all the character boxes. Its
-- own text is invisible (alpha 0); only its background rectangle is seen,
-- sized to fit whatever content is currently being displayed. Created here,
-- eagerly, so it is always the first text object the addon makes -- Windower
-- draws text objects in creation order, so this guarantees it stays behind
-- every character box (which are only created later, on demand).
local container_box = texts.new('${content}', deep_copy(settings))
container_box:alpha(0)
container_box:bg_visible(true)

-- Store cooldowns per character: [char_name][ability_name] = {ready_time}
local cooldowns = {}

-- Current character name (the one with focus)
local current_char = nil
local current_leader = nil

-- Last update time for efficient updating
local last_update = 0
local update_interval = 1  -- Update every 1 second

function initialize()
	local player = windower.ffxi.get_player()
	if player then
		current_char = player.name
		if not cooldowns[current_char] then
			cooldowns[current_char] = {}
		end
		windower.send_ipc_message('cooldown request_leader')
		
		-- Refresh cooldowns after a short delay to ensure player data is loaded
		coroutine.schedule(refresh_cooldowns, 1)
	end
end

-- Update the display with current cooldowns, one color-coded text box per character
function update_display()
	if not current_char or current_char ~= current_leader or not settings.visible then
		for _, box in pairs(char_boxes) do
			box.content = ''
			box:hide()
		end
		if container_box then
			container_box.content = ''
			container_box:hide()
		end
		return
	end
	
	local current_time = os.clock()
	
	-- Collect cooldowns grouped by character, removing expired ones
	local char_content = {}   -- char_name -> formatted content string
	local char_line_count = {} -- char_name -> number of ability lines
	local char_names = {}      -- ordered list of characters with active cooldowns
	
	for char_name, char_cooldowns in pairs(cooldowns) do
		local abilities = {}
		
		for ability_name, data in pairs(char_cooldowns) do
			local remaining = math.max(0, data.ready_time - current_time)
			
			if remaining > 0 then
				table.insert(abilities, {name = ability_name, remaining = remaining})
			else
				-- Remove expired cooldowns
				char_cooldowns[ability_name] = nil
			end
		end
		
		-- Clean up empty character entries
		if not next(char_cooldowns) then
			cooldowns[char_name] = nil
		elseif #abilities > 0 then
			-- Sort this character's abilities alphabetically
			table.sort(abilities, function(a, b) return a.name < b.name end)
			
			local lines = {}
			for _, ability in ipairs(abilities) do
				-- Fixed width: 6 chars for character, 12 for ability, rest for timer
				local char_str = string.format('%-6s', char_name:sub(1, 6))
				local ability_str = string.format('%-12s', ability.name:sub(1, 12))
				local time_str = format_time(ability.remaining)
				
				table.insert(lines, char_str .. ' ' .. ability_str .. ' ' .. time_str)
			end
			
			char_content[char_name] = table.concat(lines, '\n')
			char_line_count[char_name] = #abilities
			table.insert(char_names, char_name)
		end
	end
	
	-- Sort characters alphabetically for a stable stacking order
	table.sort(char_names)
	
	if #char_names == 0 then
		if container_box then
			container_box.content = ''
			container_box:hide()
		end
		return
	end
	
	-- Position and populate one box per character, stacked vertically
	local base_x, base_y = settings.pos.x, settings.pos.y
	local line_height = settings.text.size + 4
	local y_offset = base_y
	local used = S{}
	local all_lines = {}
	
	for _, char_name in ipairs(char_names) do
		local box = get_char_box(char_name)
		box:pos(base_x, y_offset)
		box.content = char_content[char_name]
		box:show()
		used:add(char_name)
		table.insert(all_lines, char_content[char_name])
		
		y_offset = y_offset + (char_line_count[char_name] * line_height) + settings.padding
	end
	
	-- Hide any character boxes no longer needed
	for char_name, box in pairs(char_boxes) do
		if not used:contains(char_name) then
			box.content = ''
			box:hide()
		end
	end
	
	-- Size and show the shared background behind the whole stack. Its content
	-- mirrors all the lines combined so its background auto-sizes to match,
	-- but its text stays invisible (alpha 0) so only the color-coded boxes
	-- drawn on top of it are actually read.
	local bg_box = container_box
	bg_box:pos(base_x, base_y)
	bg_box.content = table.concat(all_lines, '\n')
	bg_box:show()
end

-- Format seconds into MM:SS
function format_time(seconds)
	local mins = math.floor(seconds / 60)
	local secs = math.floor(seconds % 60)
	return string.format('%02d:%02d', mins, secs)
end

-- Scan all current ability and spell recasts and add them to tracking
function refresh_cooldowns()
	if not current_char then
		print('CooldownTracker: Character not loaded yet')
		return
	end
	
	local player = windower.ffxi.get_player()
	if not player then return end
	
	local added_count = 0
	
	-- Scan ability recasts
	local ability_recasts = windower.ffxi.get_ability_recasts()
	local job_abilities_list = windower.ffxi.get_abilities().job_abilities or {}

	if ability_recasts then
		for recast_id, recast_time in pairs(ability_recasts) do
			if recast_time > 5 then -- Only track if more than 5 seconds
				-- First, find which abilities the player actually has with this recast
				for _, ability_id in ipairs(job_abilities_list) do
					-- Look up the ability details in resources
					local ability = res.job_abilities[ability_id]
					
					if ability and ability.recast_id == recast_id then
						-- Check filter
						if settings.filter:empty() or not settings.filter:contains(ability.name) then
							if not cooldowns[current_char] then
								cooldowns[current_char] = {}
							end
							
							cooldowns[current_char][ability.name] = {
								ready_time = os.clock() + recast_time
							}
							
							-- Send IPC message to other characters
							local message = string.format('cooldown add %s~%s~%.2f', 
								current_char:gsub(' ', '_'), 
								ability.name:gsub(' ', '_'), 
								recast_time)
							windower.send_ipc_message(message)
							
							added_count = added_count + 1
							break -- Only add once per recast_id
						end
					end
				end
			end
		end
	end
	
	-- Scan spell recasts
	local spell_recasts = windower.ffxi.get_spell_recasts()
	if spell_recasts then
		for recast_id, recast_time_ms in pairs(spell_recasts) do
			local recast_time = math.floor(recast_time_ms / 60) -- Convert to seconds
			
			if recast_time > 5 then -- Only track if more than 5 seconds
				-- Find spells with this recast_id
				for id, spell in pairs(res.spells) do
					if spell.recast_id == recast_id and spell.type ~= 'Trust' then
						-- Check filter
						if settings.filter:empty() or not settings.filter:contains(spell.name) then
							-- Check if player knows this spell
							local known_spells = windower.ffxi.get_spells()
							if known_spells[id] then
								if not cooldowns[current_char] then
									cooldowns[current_char] = {}
								end
								
								cooldowns[current_char][spell.name] = {
									ready_time = os.clock() + recast_time
								}
								
								-- Send IPC message to other characters
								local message = string.format('cooldown add %s~%s~%.2f', 
									current_char:gsub(' ', '_'), 
									spell.name:gsub(' ', '_'), 
									recast_time)
								windower.send_ipc_message(message)
								
								added_count = added_count + 1
								break -- Only add once per recast_id
							end
						end
					end
				end
			end
		end
	end
	
	update_display()
	--print('CooldownTracker: Refreshed cooldowns, found ' .. added_count .. ' active cooldowns')
end

-- Add a cooldown for tracking
function add_cooldown(char_name, ability_name, recast_seconds)
	if not cooldowns[char_name] then
		cooldowns[char_name] = {}
	end
	
	cooldowns[char_name][ability_name] = {
		ready_time = os.clock() + recast_seconds
	}
	
	-- Send IPC message to other characters
	local message = string.format('cooldown add %s~%s~%.2f', 
		char_name:gsub(' ', '_'), 
		ability_name:gsub(' ', '_'), 
		recast_seconds)
	windower.send_ipc_message(message)
	
	update_display()
end

function update_leader(new_leader)
	if not current_char then return end
	current_leader = new_leader
	if current_char == new_leader then
		windower.send_ipc_message('cooldown '..current_leader)
	end
	if detect_leader then -- Only run until a leader is found
		windower.unregister_event(detect_leader)
		detect_leader = nil
	end
end

detect_leader = windower.register_event('keyboard', function(msg)
	update_leader(current_char)
end)

-- Handle IPC messages from other characters
windower.register_event('ipc message', function(msg)
	local parts = msg:split(' ')
	if parts[1] ~= 'cooldown' then return end
	
	local command = parts[2]
	
	if command == 'add' then
		local data = parts[3]:split('~')
		local char_name = data[1]:gsub('_', ' ')
		local ability_name = data[2]:gsub('_', ' ')
		local recast_seconds = tonumber(data[3])
		
		if not cooldowns[char_name] then
			cooldowns[char_name] = {}
		end
		
		cooldowns[char_name][ability_name] = {
			ready_time = os.clock() + recast_seconds
		}
		
		update_display()
	elseif command == 'request_leader' then
		if current_char == current_leader then
			update_leader(current_char)
		end
	else
		update_leader(command)
	end
end)

-- Handle incoming action packets
windower.register_event('action', function(act)
	if not current_char then return end
	
	local actor = windower.ffxi.get_mob_by_id(act.actor_id)
	if not actor or not actor.name then return end
	
	local char_name = actor.name
	
	-- Only process actions from the current character (the one we're controlling)
	if char_name ~= current_char then return end
	
	-- Category 6 = Job Abilities, Category 7 = Weapon Skills, Category 14 = Unblinkable JA, Category 15 = Scholar Stratagems
	if S{6, 7, 14, 15}:contains(act.category) then
		local ability = res.job_abilities[act.param]
		
		if ability and ability.recast_id then
			local ability_name = ability.name
			
			-- Check filter
			if settings.filter:empty() or not settings.filter:contains(ability_name) then
				coroutine.sleep(0.5)  -- Wait for recast to update
				local recast_id = ability.recast_id
				local recast_time = windower.ffxi.get_ability_recasts()[recast_id]
				
				if recast_time and recast_time > 5 then
					add_cooldown(char_name, ability_name, recast_time)
				end
			end
		end
		
	-- Category 4 = Magic
	elseif act.category == 4 then
		local spell = res.spells[act.param]
		
		if not spell or spell.type == 'Trust' then return end
		
		if spell.recast_id then
			local spell_name = spell.name
			
			-- Check filter
			if settings.filter:empty() or not settings.filter:contains(spell_name) then
				coroutine.sleep(0.5)  -- Wait for recast to update
				local recast_id = spell.recast_id
				local recast_time = math.floor(windower.ffxi.get_spell_recasts()[recast_id] / 60)
				
				if recast_time and recast_time > 5 then
					add_cooldown(char_name, spell_name, recast_time)
				end
			end
		end
	end
end)

-- Efficient timer update using prerender
windower.register_event('prerender', function()
	local current_time = os.clock()
	if current_time - last_update >= update_interval then
		last_update = current_time
		update_display()
	end
end)

-- Track which character has focus
windower.register_event('gain focus', function()
	if current_leader ~= current_char then
		update_leader(current_char)
	end
end)

-- Initialize on load/login
windower.register_event('load', 'login', function()
	initialize()
end)

-- Update character name on zone change
windower.register_event('zone change', function()
	initialize()
end)

-- Handle logout
windower.register_event('logout', function()
	current_char = nil
end)

-- Commands
windower.register_event('addon command', function(command, ...)
	command = command and command:lower() or 'help'
	local args = {...}
	
	if command == 'pos' or command == 'position' then
		if args[1] and args[2] then
			settings.pos.x = tonumber(args[1])
			settings.pos.y = tonumber(args[2])
			update_display()
			config.save(settings)
			print('CooldownTracker: Position set to', settings.pos.x, settings.pos.y)
		else
			print('CooldownTracker: Usage: //cd pos <x> <y>')
		end
		
	elseif command == 'size' or command == 'fontsize' then
		if args[1] then
			settings.text.size = tonumber(args[1])
			config.save(settings)
			print('CooldownTracker: Font size set to', settings.text.size)
			print('CooldownTracker: Reload addon to apply: //lua r cooldown')
		else
			print('CooldownTracker: Current font size:', settings.text.size)
			print('CooldownTracker: Usage: //cd size <number>')
		end
		
	elseif command == 'add' or command == 'a' then
		local name = table.concat(args, ' ')
		if name == '' then
			print('CooldownTracker: Usage: //cd add <ability/spell name>')
			return
		end
		
		-- Try to find in job abilities
		local found = false
		for id, ability in pairs(res.job_abilities) do
			if ability.name:lower() == name:lower() then
				settings.filter:add(ability.name)
				print('CooldownTracker: Added to filter:', ability.name)
				found = true
				break
			end
		end
		
		-- Try to find in spells if not found
		if not found then
			for id, spell in pairs(res.spells) do
				if spell.name:lower() == name:lower() then
					settings.filter:add(spell.name)
					print('CooldownTracker: Added to filter:', spell.name)
					found = true
					break
				end
			end
		end
		
		if not found then
			print('CooldownTracker: Ability/Spell not found:', name)
		else
			config.save(settings)
		end
		
	elseif command == 'remove' or command == 'r' then
		local name = table.concat(args, ' ')
		if name == '' then
			print('CooldownTracker: Usage: //cd remove <ability/spell name>')
			return
		end
		
		-- Try to find exact match in filter
		local removed = false
		for entry in settings.filter:it() do
			if entry:lower() == name:lower() then
				settings.filter:remove(entry)
				print('CooldownTracker: Removed from filter:', entry)
				removed = true
				config.save(settings)
				break
			end
		end
		
		if not removed then
			print('CooldownTracker: Not found in filter:', name)
		end
		
	elseif command == 'list' then
		if settings.filter:empty() then
			print('CooldownTracker: Filter is empty (tracking all abilities)')
		else
			print('CooldownTracker: Filtered abilities:')
			local sorted = {}
			for entry in settings.filter:it() do
				table.insert(sorted, entry)
			end
			table.sort(sorted)
			for _, entry in ipairs(sorted) do
				print('  ' .. entry)
			end
		end
		
	elseif command == 'clear' then
		settings.filter:clear()
		config.save(settings)
		print('CooldownTracker: Filter cleared (now tracking all abilities)')
		
	elseif command == 'refresh' or command == 'scan' then
		refresh_cooldowns()
		
	elseif command == 'clearcd' then
		cooldowns = {}
		if current_char then
			cooldowns[current_char] = {}
		end
		update_display()
		print('CooldownTracker: All cooldowns cleared')
		
	elseif command == 'toggle' or command == 't' then
		settings.visible = not settings.visible
		config.save(settings)
		update_display()
		
	else
		print('CooldownTracker v' .. _addon.version)
		print('Commands:')
		print('  //cd pos <x> <y> - Set display position')
		print('  //cd size <number> - Set font size')
		print('  //cd add <name> - Add ability/spell to filter')
		print('  //cd remove <name> - Remove ability/spell from filter')
		print('  //cd list - Show filtered abilities')
		print('  //cd clear - Clear filter (track all abilities)')
		print('  //cd refresh - Scan and add all current cooldowns')
		print('  //cd clearcd - Clear all current cooldowns')
		print('')
		print('Note: Empty filter = track all abilities')
	end
end)

-- Initial setup
initialize()