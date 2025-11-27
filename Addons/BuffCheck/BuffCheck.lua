_addon.author = 'Spikex'
_addon.version = '0.6'
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

BarElements = S{'Barfire','Barblizzard','Baraero','Barstone','Barthunder','Barwater'}
BarStatuses = S{'Barsleep','Barpoison','Barparalyze','Barblind','Barvirus','Barpetrify','Baramnesia'}
Enspells = S{'Enfire','Enblizzard','Enaero','Enstone','Enthunder','Enwater'}

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
	settings.jobs[fulljob] = S{'Food', 'Phalanx','Haste'}
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
	if not windower.ffxi.get_info().logged_in or not self then return end
	
	ipc_message = msg:split(' ')
	if ipc_message[1] ~= 'buffcheck' then return end
	local command = ipc_message[2]
	local arg = ipc_message[3]
	
	if command == 'change_leader' then
		update_leader(arg)
		
	elseif command == 'request_leader' then
		if current_leader == self.name then 
			windower.send_ipc_message('buffcheck change_leader '..current_leader)
		end
		
	elseif command == 'update' then
		update_party_list(string_to_table(arg))
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
	update_display()
	if current_leader == self.name then
		windower.send_ipc_message('buffcheck change_leader '..current_leader)
	end
end

function update_display()
	--print('update_display called')
	--print('current_leader:', current_leader)
	--print('self.name:', self and self.name or 'nil')
	
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
	
	--print('Number of party members:', table.length(party_missing_buffs))
	
	-- Sort party members by name for consistent display
	local sorted_members = {}
	for player_name, missing_buffs in pairs(party_missing_buffs) do
		--print('Player:', player_name, 'Missing buffs:', #missing_buffs)
		table.insert(sorted_members, {name = player_name, buffs = missing_buffs})
	end
	table.sort(sorted_members, function(a, b) return a.name < b.name end)
	
	--print('Creating display for', #sorted_members, 'members')
	
	-- Display each party member's missing buffs
	for row_index, member_data in ipairs(sorted_members) do
		local y_pos = settings.pos.y + ((row_index - 1) * row_height)
		
		--print('Row', row_index, ':', member_data.name, 'at y:', y_pos)
		
		-- Create player name text - pass text as first argument, settings as second
		local name_text = texts.new(member_data.name:sub(1, 5), {
			pos = {x = settings.pos.x, y = y_pos},
			text = {size = 20, font = 'Consolas'},
			flags = {draggable = false},
		})
		name_text:show()
		table.insert(name_texts, name_text)
		--print('  Created name text')
		
		-- Display missing buff icons
		for icon_index, buff_data in ipairs(member_data.buffs) do
			local x_pos = settings.pos.x + name_width + ((icon_index - 1) * (icon_size + icon_spacing))
			local icon_path = windower.windower_path .. 'addons/BuffCheck/icons/' .. buff_data.id .. '.png'
			
			--print('  Icon', icon_index, ':', buff_data.name, 'id:', buff_data.id, 'at x:', x_pos)
			--print('  Path:', icon_path)
			
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
	
	--print('Display update complete')
end

function update_party_list(buff_table)
	--print('update_party_list called')
	--print('buff_table length:', buff_table and #buff_table or 'nil')
	
	if not buff_table or #buff_table == 0 then 
		--print('Empty buff_table, returning')
		return 
	end
	
	local player_name = buff_table[1]  -- First entry is player name (includes job)
	--print('Player name from table:', player_name)
	
	-- Extract just the name part (before underscore)
	local display_name = player_name:match("^(.+)_") or player_name
	--print('Display name:', display_name)
	
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
	print(table_to_string(missing_buffs))
	windower.send_ipc_message('buffcheck update '..table_to_string(missing_buffs))
	update_party_list(missing_buffs)
end

function table_to_string(table_to_convert)
	if type(table_to_convert) ~= 'table' then print('table_to_string requires table') return end
	local new_string = ''
	for i, v in pairs(table_to_convert) do
		new_string = new_string .. v .. '//'
	end
	return new_string
end

function string_to_table(string_to_convert)
	if type(string_to_convert) ~= 'string' then print('string_to_table requires string') return end
	local result = {}
	local from = 1
	local delim_from, delim_to = string.find(string_to_convert, '//', from)
	
	while delim_from do
		table.insert(result, string.sub(string_to_convert, from, delim_from - 1))
		from = delim_to + 1
		delim_from, delim_to = string.find(string_to_convert, '//', from)
	end
	
	table.insert(result, string.sub(string_to_convert, from))
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