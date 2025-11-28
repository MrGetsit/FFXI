_addon.author = 'Spikex'
_addon.version = '0.8'
_addon.name = 'Buff Check'
_addon.commands = { 'buffcheck', 'bc' }

config = require('config')
require('strings')
images = require('images')
texts = require('texts')
res = require('resources')

defaults = {} 
defaults.pos = {}
defaults.pos.x = 10
defaults.pos.y = 100
defaults.jobs = {}

settings = config.load(defaults)

-- Register a callback to convert string jobs to Sets after config loads
config.register(settings, function(settings)
	-- Convert all job entries in both global and character-specific settings
	if settings.jobs then
		for job_key, job_buffs in pairs(settings.jobs) do
			if type(job_buffs) == 'string' then
				settings.jobs[job_key] = S(job_buffs:split(','))
			end
		end
	end
end)

local job, subjob, fulljob
local watched_buff_list = {}
local watched_ids = S{}
local party_missing_buffs = {} -- Stores missing buffs per party member
local buff_icons = {} -- Stores icon objects
local name_texts = {} -- Stores name text objects

local icon_size = 32
local icon_spacing = -5
local name_width = 80 -- Space for player name
local row_height = 32

function first_time_setup()
	print('BuffCheck: First time setup for '..fulljob)
	settings.jobs[fulljob] = S{'Food','Phalanx','Haste','Protect','Shell'}
	RefreshJobs = S{'RDM','WHM','BLM','SMN','PLD','RUN','BLU','GEO','SCH'}
	if RefreshJobs:contains(job) then
		settings.jobs[fulljob] = settings.jobs[fulljob] + S{'Refresh'}
	end
	if job == 'COR' then
		settings.jobs[fulljob] = settings.jobs[fulljob] + S{'Samurai Roll', 'Chaos Roll'}
	end
	if job == 'GEO' then
		settings.jobs[fulljob] = settings.jobs[fulljob] + S{'Colure Active'}
	end
	if job == 'MNK' then
		settings.jobs[fulljob] = settings.jobs[fulljob] + S{'Impetus'}
	end
	if job == 'DNC' or sub == 'DNC' then
		settings.jobs[fulljob] = settings.jobs[fulljob] + S{'Haste Samba'}
	end
	
	config.save(settings, 'all')  -- Always save to global to prevent character-specific overrides
end

windower.register_event('load', 'login', function (new, old)
	if self then return end
	for i = 0, 30, 1 do
		self = windower.ffxi.get_mob_by_target('me')
		if self then break end
		coroutine.sleep(2)
	end
	if not self then windower.send_command('lua unload buffcheck') return end
	
	job = windower.ffxi.get_player().main_job
	subjob = windower.ffxi.get_player().sub_job
	fulljob = string.lower(job..'_'..subjob)
	list_name = string.sub(self.name, 0, 3) .. '_' .. job
	
	if not settings.jobs[fulljob] or settings.jobs[fulljob]:empty() then
		first_time_setup()
		config.save(settings, 'all')  -- Save to global
	end
	
	windower.send_ipc_message('buffcheck request_leader')
	generate_buff_list()
	
	while not current_leader do
		coroutine.sleep(1) 
	end
	missing_buff_list()
end)

windower.register_event('Gain buff', 'Lose buff', function (buff_id)
	if watched_ids:contains(buff_id) then
		missing_buff_list()
	end
end)

windower.register_event('Gain focus', 'Keyboard', function (new, old)
	if current_leader ~= self.name then
		update_leader(self.name)
	end
end)

windower.register_event('ipc message', function (msg)
	if not windower.ffxi.get_info().logged_in or not self then 
		print('BuffCheck IPC: Not logged in or no self')
		return 
	end
	
	print('BuffCheck IPC received:', msg)
	
	ipc_message = msg:split(' ')
	if ipc_message[1] ~= 'buffcheck' then return end
	
	local command = ipc_message[2]
	local arg = ipc_message[3]
	
	print('  Command:', command, 'Arg:', arg and arg:sub(1, 20) or 'nil')
	
	if command == 'change_leader' then
		print('  Changing leader to:', arg)
		update_leader(arg)
		
	elseif command == 'request_leader' then
		print('  Leader request received. Current leader:', current_leader, 'Self:', self.name)
		if current_leader == self.name then 
			print('  Broadcasting leader status')
			windower.send_ipc_message('buffcheck change_leader '..current_leader)
		end
		
	elseif command == 'update' then
		print('  Update command received')
		local buff_table = string_to_table(arg)
		if buff_table then
			print('  Parsed table, length:', #buff_table, 'First entry:', buff_table[1])
			update_party_list(buff_table)
		else
			print('  ERROR: Failed to parse buff table')
		end
	end
end)

function generate_buff_list()
	watched_buff_list = {}
	watched_ids = S{} 
	search_for = {}
	
	for buff in settings.jobs[fulljob]:it() do
		if buff == 'BarElement' then
			for element in BarElements:it() do
				table.insert(search_for, element)
			end
		elseif buff == 'BarStatus' then
			for status in BarStatuses:it() do
				table.insert(search_for, status)
			end
		elseif buff == 'Enspell' then
			for enspell in Enspells:it() do
				table.insert(search_for, enspell)
			end
		else
			table.insert(search_for, buff)
		end
	end
	
	for i, buff in pairs(search_for) do
		for i2, rbuff in pairs(res.buffs) do
			if buff == rbuff.en then
				table.insert(watched_buff_list, rbuff)
				watched_ids:add(rbuff.id)
			end
		end
	end
end

function update_leader(new_leader)
	current_leader = new_leader
	
	-- If we just became leader, don't clear party data - we want to keep what others sent us
	-- If we're not the leader anymore, clear our display but keep the data for when we might need to send it
	if current_leader ~= self.name then
		-- Clear display but keep our own data in party_missing_buffs
		for _, text_obj in pairs(name_texts) do
			text_obj:destroy()
		end
		name_texts = {}
		
		for _, icon in pairs(buff_icons) do
			icon:destroy()
		end
		buff_icons = {}
	else
		-- We became leader - update display with all existing data
		update_display()
		windower.send_ipc_message('buffcheck change_leader '..current_leader)
	end
end

function update_display()	
	-- Clear existing icons and text
	for _, text_obj in pairs(name_texts) do
		text_obj:destroy()
	end
	name_texts = {}
	
	for _, icon in pairs(buff_icons) do
		icon:destroy()
	end
	buff_icons = {}
	
	if current_leader ~= self.name then
		--print('Not leader, hiding display')
		return
	end
	
	print('Number of party members:', table.length(party_missing_buffs))
	for name, buffs in pairs(party_missing_buffs) do
		print('  ' .. name .. ':', #buffs, 'missing buffs')
	end
	
	-- Sort party members by name for consistent display
	local sorted_members = {}
	for player_name, missing_buffs in pairs(party_missing_buffs) do
		table.insert(sorted_members, {name = player_name, buffs = missing_buffs})
	end
	table.sort(sorted_members, function(a, b) return a.name < b.name end)
	
	-- Display each party member's missing buffs
	for row_index, member_data in ipairs(sorted_members) do
		local y_pos = settings.pos.y + ((row_index - 1) * row_height)		
		-- print('Row', row_index, ':', member_data.name, 'at y:', y_pos, 'buffs:', #member_data.buffs)		
		-- Create player name text - pass text as first argument, settings as second
		local name_text = texts.new(member_data.name:sub(1, 5), {
			pos = {x = settings.pos.x, y = y_pos},
			text = {size = 20, font = 'Consolas'},
			flags = {draggable = false},
		})
		name_text:show()
		table.insert(name_texts, name_text)
		-- Display missing buff icons
		for icon_index, buff_data in ipairs(member_data.buffs) do
			local x_pos = settings.pos.x + name_width + ((icon_index - 1) * (icon_size + icon_spacing))
			local icon_path = windower.windower_path .. 'addons/BuffCheck/icons/' .. buff_data.id .. '.png'
			--print('  Icon', icon_index, ':', buff_data.name, 'id:', buff_data.id, 'at x:', x_pos)
			local icon = images.new({
				texture = {
					path = icon_path,
					fit = true,
				},
				size = {
					width = icon_size,
					height = icon_size,
				},
				pos = {
					x = x_pos,
					y = y_pos,
				},
				draggable = false,
				visible = true,
			})
			icon:show()
			table.insert(buff_icons, icon)
		end
	end
end

function update_party_list(buff_table)
	print('update_party_list called on', self.name)
	print('  Current leader:', current_leader)
	print('  buff_table type:', type(buff_table))
	
	if not buff_table or #buff_table == 0 then 
		print('  Empty buff_table, returning')
		return 
	end
	
	print('  buff_table length:', #buff_table)
	local player_name = buff_table[1]
	print('  Player name from table:', player_name)
	if not buff_table or #buff_table == 0 then 
		--print('Empty buff_table, returning')
		return 
	end
	
	local player_name = buff_table[1]  -- First entry is player name (includes job)
	local display_name = player_name:match("^(.+)_") or player_name
	local missing_buffs = {}
	
	-- Convert buff names to buff IDs
	for i = 2, #buff_table do
		local buff_name = buff_table[i]
		for id, buff in pairs(res.buffs) do
			if buff.en == buff_name then
				table.insert(missing_buffs, {name = buff_name, id = id})
				--print('  Found buff:', buff_name, 'id:', id)
				break
			end
		end
	end
	--print('Total missing buffs for', display_name, ':', #missing_buffs)	
	party_missing_buffs[display_name] = missing_buffs
	update_display()
end

function missing_buff_list()
	missing_buffs = {}
	for buff in settings.jobs[fulljob]:it() do
		table.insert(missing_buffs, buff)
	end
	
	for index, buff_id in pairs(windower.ffxi.get_player().buffs) do
		local this_buff = res.buffs[buff_id].en
		if settings.jobs[fulljob]:contains(this_buff) then
			for i, v in pairs(missing_buffs) do
				if v == this_buff then
					table.remove(missing_buffs, i)
					break
				end
			end
		end
	end
	table.sort(missing_buffs)
	
	table.insert(missing_buffs, 1, string.sub(self.name, 0, 8)..'_'..job)
	
	-- Always send update via IPC, regardless of leader status
	local message = 'buffcheck update '..table_to_string(missing_buffs)
	print('BuffCheck: Sending IPC message from', self.name)
	print('  Message length:', #message)
	print('  First 50 chars:', message:sub(1, 50))
	windower.send_ipc_message(message)
	
	-- Update our own data in the party list
	update_party_list(missing_buffs)
end

function table_to_string(table_to_convert)
	if type(table_to_convert) ~= 'table' then print('table_to_string requires table') return end
	local new_string = ''
	for i, v in pairs(table_to_convert) do
		local encoded_v = v:gsub(' ', '|')
		new_string = new_string .. encoded_v .. '//'
	end
	return new_string
end

function string_to_table(string_to_convert)
	if type(string_to_convert) ~= 'string' then print('string_to_table requires string') return end
	local result = {}
	local from = 1
	local delim_from, delim_to = string.find(string_to_convert, '//', from)
	
	while delim_from do
		local value = string.sub(string_to_convert, from, delim_from - 1)
		value = value:gsub('|', ' ')
		table.insert(result, value)
		from = delim_to + 1
		delim_from, delim_to = string.find(string_to_convert, '//', from)
	end
	
	local last_value = string.sub(string_to_convert, from)
	last_value = last_value:gsub('|', ' ')
	table.insert(result, last_value)
	return result
end

function indexOf(array, value)
	for i, v in ipairs(array) do
		if v == value then
			return i
		end
	end
	return nil
end

windower.register_event('addon command', function(action, arg1, arg2)
	if action == 'position' or action == 'pos' then
		if not arg1 or not arg2 then print('BuffCheck: Position needs x and y. //bc pos 100 100') return end
		settings.pos.x = arg1
		settings.pos.y = arg2
	else
		local find_me = next(res.buffs:en(action))
		if not find_me then print('Buffcheck: Can\'t find buff named: '..action) return end
		
		if settings.jobs[fulljob]:contains(action) then
			--print('Removing '..action..' from tracked buffs.')
			settings.jobs[fulljob] = settings.jobs[fulljob] - S{action}
		else
			--print('Adding '..action..' to tracked buffs.')
			settings.jobs[fulljob] = settings.jobs[fulljob] + S{action}
		end
	end
	
	config.save(settings, 'all')  -- Always save to global to prevent character-specific overrides
	generate_buff_list()
	missing_buff_list()
end)

windower.register_event('unload', function()
	for _, text_obj in pairs(name_texts) do
		text_obj:destroy()
	end
	for _, icon in pairs(buff_icons) do
		icon:destroy()
	end
end)