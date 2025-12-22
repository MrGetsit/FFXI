_addon.name = 'DebuffGrid'
_addon.author = 'Spikex'
_addon.version = '1.0'
_addon.commands = {'debuffgrid', 'dbg'}

config = require('config')
packets = require('packets')
res = require('resources')
images = require('images')

defaults = {}
defaults.pos = {}
defaults.pos.x = 100
defaults.pos.y = 100
defaults.icon_size = 32

settings = config.load(defaults)

-- Debuff grid layout (3 rows x 4 columns)
local debuff_grid = {
	{{'Dia', 'Bio'}, 'Frazzle', 'Addle', 'Distract'},
	{'Paralyze', 'Slow', 'Blind', 'Silence'},
	{{'Sleep', 'Break', 'Bind'}, 'Poison', 'Gravity', 'Inundation'}
}

-- Map debuff names to their spell IDs for icon lookup
local debuff_to_spell = {}
local debuff_to_effect = {}

-- Store active debuffs per enemy (persists across target changes)
local debuffed_mobs = {}
local current_target_id = nil

-- UI elements
local icon_grid = {}
local background = nil

-- Grid settings
local icon_spacing = 4
local border_size = 5
local grid_rows = 3
local grid_cols = 4

local inactive_alpha = 80  -- Semi-transparent when not active
local active_alpha = 255   -- Fully opaque when active

function initialize_debuff_mappings()
	-- Build mapping from debuff names to spell IDs and effect IDs
	for spell_id, spell in pairs(res.spells) do
		if spell.status then
			local name = spell.name
			if not debuff_to_spell[name] then
				debuff_to_spell[name] = spell_id
				debuff_to_effect[name] = spell.status
			end
		end
	end
	
	-- Handle special cases where we want specific versions
	-- Dia -> Dia (ID 23, Effect 134)
	-- debuff_to_spell['Dia'] = 23
	-- debuff_to_effect['Dia'] = 134
end

function create_ui()
	-- Calculate background size
	local bg_width = (settings.icon_size * grid_cols) + (icon_spacing * (grid_cols - 1)) + (border_size * 2)
	local bg_height = (settings.icon_size * grid_rows) + (icon_spacing * (grid_rows - 1)) + (border_size * 2)
	
	-- Create semi-transparent background
	background = images.new({
		color = {
			alpha = 64,
			red = 0,
			green = 0,
			blue = 0,
		},
		size = {
			width = bg_width,
			height = bg_height,
		},
		pos = {
			x = settings.pos.x,
			y = settings.pos.y,
		},
		draggable = true,
		visible = false,
	})
	
	-- Create icon grid
	for row = 1, grid_rows do
		icon_grid[row] = {}
		for col = 1, grid_cols do
			local debuff_entry = debuff_grid[row][col]
			local debuff_names = {}
			local is_multi = false
			
			-- Check if this is a multi-debuff slot
			if type(debuff_entry) == 'table' then
				debuff_names = debuff_entry
				is_multi = true
			else
				debuff_names = {debuff_entry}
			end
			
			-- Use the first debuff for initial icon
			local first_debuff = debuff_names[1]
			local spell_id = debuff_to_spell[first_debuff]
			
			if spell_id then
				local x_pos = settings.pos.x + border_size + ((col - 1) * (settings.icon_size + icon_spacing))
				local y_pos = settings.pos.y + border_size + ((row - 1) * (settings.icon_size + icon_spacing))
				
				local icon = images.new({
					texture = {
						path = windower.windower_path .. 'addons/DebuffGrid/icons/' .. spell_id .. '.png',
						fit = false,
					},
					size = {
						width = settings.icon_size,
						height = settings.icon_size,
					},
					pos = {
						x = x_pos,
						y = y_pos,
					},
					color = {
						alpha = inactive_alpha,
						red = 255,
						green = 255,
						blue = 255,
					},
					draggable = false,
					visible = false,
				})
				
				-- Build effect ID list for this slot
				local effect_ids = {}
				for _, debuff_name in ipairs(debuff_names) do
					local effect = debuff_to_effect[debuff_name]
					if type(effect) == 'table' then
						-- Handle multi-tier debuffs like Frazzle
						for _, eid in ipairs(effect) do
							effect_ids[eid] = debuff_name
						end
					else
						effect_ids[effect] = debuff_name
					end
				end
				
				icon_grid[row][col] = {
					icon = icon,
					debuff_names = debuff_names,
					effect_ids = effect_ids,  -- Maps effect_id -> debuff_name
					is_multi = is_multi,
					current_debuff = nil,  -- Track which debuff is currently active
				}
			end
		end
	end
end
function update_icon_positions()
	for row = 1, grid_rows do
		for col = 1, grid_cols do
			if icon_grid[row] and icon_grid[row][col] then
				local x_pos = settings.pos.x + border_size + ((col - 1) * (settings.icon_size + icon_spacing))
				local y_pos = settings.pos.y + border_size + ((row - 1) * (settings.icon_size + icon_spacing))
				icon_grid[row][col].icon:pos(x_pos, y_pos)
			end
		end
	end
	
	if background then
		background:pos(settings.pos.x, settings.pos.y)
	end
end

function rebuild_ui()
	-- Destroy existing UI
	if background then
		background:destroy()
	end
	
	for row = 1, grid_rows do
		for col = 1, grid_cols do
			if icon_grid[row] and icon_grid[row][col] then
				icon_grid[row][col].icon:destroy()
			end
		end
	end
	
	icon_grid = {}
	
	-- Recreate with new settings
	create_ui()
	update_display()
end
function update_display()
	local target = windower.ffxi.get_mob_by_target('t')
	
	-- Hide if no valid enemy target
	if not target or not target.valid_target or target.id == 0 or not (target.claim_id ~= 0 or target.spawn_type == 16) then
		hide_grid()
		current_target_id = nil
		return
	end
	
	-- Update current target
	current_target_id = target.id
	
	-- Show grid
	show_grid()
	
	-- Get active debuffs for this target
	local active_debuffs = debuffed_mobs[current_target_id] or {}
	
	-- Update icon transparency and texture based on active debuffs
	for row = 1, grid_rows do
		for col = 1, grid_cols do
			if icon_grid[row] and icon_grid[row][col] then
				local data = icon_grid[row][col]
				local is_active = false
				local active_debuff_name = nil
				local most_recent_time = 0
				
				-- Check which debuff (if any) is active for this slot
				-- For multi-debuff slots, find the most recently applied one
				for effect_id, debuff_name in pairs(data.effect_ids) do
					if active_debuffs[effect_id] then
						is_active = true
						local debuff_time = active_debuffs[effect_id].time
						
						-- Use the most recently applied debuff
						if debuff_time > most_recent_time then
							most_recent_time = debuff_time
							active_debuff_name = debuff_name
						end
					end
				end
				
				-- Update icon if the active debuff changed
				if data.is_multi and active_debuff_name ~= data.current_debuff then
					data.current_debuff = active_debuff_name
					
					if active_debuff_name then
						local new_spell_id = debuff_to_spell[active_debuff_name]
						local new_path = windower.windower_path .. 'addons/DebuffGrid/icons/' .. new_spell_id .. '.png'
						data.icon:path(new_path)
					else
						-- Reset to first debuff in the list when none are active
						local default_spell_id = debuff_to_spell[data.debuff_names[1]]
						local default_path = windower.windower_path .. 'addons/DebuffGrid/icons/' .. default_spell_id .. '.png'
						data.icon:path(default_path)
					end
				end
				
				data.icon:alpha(is_active and active_alpha or inactive_alpha)
			end
		end
	end
end

function show_grid()
	if background then
		background:show()
	end
	
	for row = 1, grid_rows do
		for col = 1, grid_cols do
			if icon_grid[row] and icon_grid[row][col] then
				icon_grid[row][col].icon:show()
			end
		end
	end
end

function hide_grid()
	if background then
		background:hide()
	end
	
	for row = 1, grid_rows do
		for col = 1, grid_cols do
			if icon_grid[row] and icon_grid[row][col] then
				icon_grid[row][col].icon:hide()
			end
		end
	end
end

function apply_debuff(target_id, effect_id, spell_id)
	if not debuffed_mobs[target_id] then
		debuffed_mobs[target_id] = {}
	end
	
	debuffed_mobs[target_id][effect_id] = {
		spell_id = spell_id,
		time = os.clock()  -- This is already being tracked
	}
	
	-- Update display if this is the current target
	if target_id == current_target_id then
		update_display()
	end
end

function remove_debuff(target_id, effect_id)
	if debuffed_mobs[target_id] then
		debuffed_mobs[target_id][effect_id] = nil
		
		-- Clean up empty mob entries
		if not next(debuffed_mobs[target_id]) then
			debuffed_mobs[target_id] = nil
		end
	end
	
	-- Update display if this is the current target
	if target_id == current_target_id then
		update_display()
	end
end

-- Handle incoming action packets
windower.register_event('incoming chunk', function(id, data)
	if id == 0x028 then
		local act = windower.packets.parse_action(data)
		
		-- Category 4 = Magic
		if act.category == 4 then
			-- Damaging spells (messages 2, 252)
			if S{2, 252}:contains(act.targets[1].actions[1].message) then
				local target_id = act.targets[1].id
				local spell_id = act.param
				local spell = res.spells[spell_id]
				
				if spell and spell.status then
					apply_debuff(target_id, spell.status, spell_id)
				end
				
			-- Non-damaging spells (messages 236, 237, 268, 271)
			elseif S{236, 237, 268, 271}:contains(act.targets[1].actions[1].message) then
				local target_id = act.targets[1].id
				local effect_id = act.targets[1].actions[1].param
				local spell_id = act.param
				local spell = res.spells[spell_id]
				
				if spell and spell.status and spell.status == effect_id then
					apply_debuff(target_id, effect_id, spell_id)
				end
			end
		end
		
	elseif id == 0x029 then
		-- Action message packet
		local target_id = data:unpack('I', 0x09)
		local param_1 = data:unpack('I', 0x0D)
		local message_id = data:unpack('H', 0x19) % 32768
		
		-- Debuff wore off (messages 64, 204, 206, 350, 531)
		if S{64, 204, 206, 350, 531}:contains(message_id) then
			remove_debuff(target_id, param_1)
			
		-- Target died (messages 6, 20, 113, 406, 605, 646)
		elseif S{6, 20, 113, 406, 605, 646}:contains(message_id) then
			debuffed_mobs[target_id] = nil
			
			if target_id == current_target_id then
				update_display()
			end
		end
	end
end)

-- Update display regularly and handle dragging
local last_bg_x, last_bg_y = nil, nil
windower.register_event('prerender', function()
	-- Check if background was dragged
	if background then
		local bg_x, bg_y = background:pos()
		if last_bg_x ~= bg_x or last_bg_y ~= bg_y then
			settings.pos.x = bg_x
			settings.pos.y = bg_y
			config.save(settings)
			update_icon_positions()
			last_bg_x = bg_x
			last_bg_y = bg_y
		end
	end
	
	update_display()
end)

-- Initialize on load/login
windower.register_event('load', 'login', function()
	initialize_debuff_mappings()
	create_ui()
	last_bg_x = settings.pos.x
	last_bg_y = settings.pos.y
end)

-- Clear on logout/zone
windower.register_event('logout', 'zone change', function()
	debuffed_mobs = {}
	current_target_id = nil
	hide_grid()
end)

-- Addon commands
windower.register_event('addon command', function(command, ...)
	command = command and command:lower() or 'help'
	
	if command == 'pos' or command == 'position' then
		local args = {...}
		if args[1] and args[2] then
			settings.pos.x = tonumber(args[1])
			settings.pos.y = tonumber(args[2])
			config.save(settings)
			update_icon_positions()
			print('DebuffGrid: Position set to', settings.pos.x, settings.pos.y)
		else
			print('DebuffGrid: Usage: //dbg pos <x> <y>')
		end
		
	elseif command == 'size' then
		local args = {...}
		if args[1] then
			settings.icon_size = tonumber(args[1])
			config.save(settings)
			rebuild_ui()
			print('DebuffGrid: Icon size set to', settings.icon_size)
		else
			print('DebuffGrid: Current icon size:', settings.icon_size)
			print('DebuffGrid: Usage: //dbg size <pixels>')
		end
		
	elseif command == 'reload' then
		windower.send_command('lua r debuffgrid')
		
	else
		print('DebuffGrid v' .. _addon.version)
		print('  //dbg pos <x> <y> - Set position')
		print('  //dbg size <pixels> - Set icon size (default: 32)')
	end
end)

-- Cleanup on unload
windower.register_event('unload', function()
	if background then
		background:destroy()
	end
	
	for row = 1, grid_rows do
		for col = 1, grid_cols do
			if icon_grid[row] and icon_grid[row][col] then
				icon_grid[row][col].icon:destroy()
			end
		end
	end
end)