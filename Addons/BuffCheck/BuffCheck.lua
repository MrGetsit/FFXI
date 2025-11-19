_addon.author = 'Spikex'
_addon.version = '0.5'
_addon.name = 'Buff Check'
_addon.commands = { 'buffcheck', 'bc' }

config = require('config')
require('strings')
require('tables')
texts = require('texts')
config = require('config')
res = require('resources')

default_settings = {}
default_settings.text = {}
default_settings.text.font = 'Consolas' -- Monospace font
settings = config.load(default_settings)
buff_display = texts.new(settings)

tracked_buffs = {'Haste','Refresh','Phalanx','Enspell','BarElement','BarStatus','Gain','Storm','Food'}
BarElements = {'Barfire','Barblizzard','Baraero','Barstone','Barthunder','Barwater'}
BarStatuses = {'Barsleep','Barpoison','Barparalyze','Barblind','Barvirus','Barpetrify','Baramnesia'}
Enspells = {'Enfire','Enblizzard','Enaero','Enstone','Enthunder','Enwater'}

windower.register_event('load', 'login', function (new, old)
	if self then return end -- Already ran it
	for i = 0, 10, 1 do -- Don't continue until player is loaded in
		self = windower.ffxi.get_mob_by_target('me')
		if self then break end
		coroutine.sleep(1)
	end
	if not self then print('No self') return end
	job = windower.ffxi.get_player().main_job
	subjob = windower.ffxi.get_player().sub_job
	windower.send_ipc_message('buffcheck request_leader')
	generate_buff_list()
	
	while not current_leader do
		coroutine.sleep(1) 
	end
	missing_buff_list()
end)

windower.register_event('Gain buff', 'Lose buff', function (buff_id)
	if table.contains(watched_ids, buff_id) then
		missing_buff_list()
	end
end)

windower.register_event('Gain focus', 'Keyboard', function (new, old)
	if current_leader ~= self.name then
		update_leader(self.name)
	end
end)

windower.register_event('ipc message', function (msg)
	if not windower.ffxi.get_info().logged_in or not self then print('no self') return end
	
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
	watched_ids = {}
	search_for = {}
	for i, buff in pairs(tracked_buffs) do -- Gota build new table, setting missing = tracked keeps the same reference
		if buff == 'BarElement' then
			count = 0
			while count < 6 do
				print(BarElements[count + 1])
				table.insert(search_for, BarElements[count + 1])
				count = count + 1
			end
		elseif buff == 'BarStatus' then
			count = 0
			while count < 7 do
				print(BarStatuses[count + 1])
				table.insert(search_for, BarStatuses[count + 1])
				count = count + 1
			end
		elseif buff == 'Enspell' then
			count = 0
			while count < 6 do
				print(Enspells[count + 1])
				table.insert(search_for, Enspells[count + 1])
				count = count + 1
			end
		else
			table.insert(search_for, buff)
		end
	end
	for i, buff in pairs(search_for) do
		for i2, rbuff in pairs(res.buffs) do
			if buff == rbuff.en then
				table.insert(watched_buff_list, rbuff)
				table.insert(watched_ids, rbuff.id)
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
	if not buff_display or not party_buff_table then return end
	
	if current_leader == self.name then
		display_text = ''
		for i, value in pairs(party_buff_table) do
			for i2, v in pairs(party_buff_table[i]) do
				display_text = display_text .. 
				' | ' .. 
				v -- string.sub(v, 0, 5) 
			end
			display_text = display_text .. ' | \n' -- Add new line for each party member
		end
		buff_display:visible(true)
		buff_display:text(display_text)
	else
		buff_display:visible(false)
	end
end

function update_party_list(buff_table)
	if not buff_table then print('no table') return end
	
	if party_buff_table then
		for i, player_data in pairs(party_buff_table) do -- Look through party list
			if player_data[1] == buff_table[1] then -- Remove previous data if they were
				table.remove(party_buff_table, i)
			end
		end
		table.insert(party_buff_table, buff_table) -- Add current member data
	else -- Create party table
		party_buff_table = {}
		table.insert(party_buff_table, buff_table)
	end
	
	update_display()
end

function missing_buff_list()
	missing_buffs = {}
	for i, v in pairs(tracked_buffs) do -- Gota build new table, setting missing = tracked keeps the same reference
		table.insert(missing_buffs, v)
	end
	for index, buff in pairs(windower.ffxi.get_player().buffs) do -- Look through all player buffs
		local this_buff = string.sub(tostring(res.buffs:id(buff)), 2, -2) -- Remove { and } from string for comparison
		if table.contains(tracked_buffs, this_buff) then -- Found a buff that is on the watch list
			for i, v in pairs(missing_buffs) do -- Remove from missing buff list
				if v == this_buff then
					table.remove(missing_buffs, i)
				end
			end
		end
		if string.sub(this_buff, 0, 3) == 'Bar' then 
			if table.contains(BarElements, this_buff) then
				table.remove(missing_buffs, indexOf(missing_buffs, 'BarElement'))
			else
				table.remove(missing_buffs, indexOf(missing_buffs, 'BarStatus'))
			end
		end
		if job == 'RDM' or job == 'WHM' then
			if string.sub(this_buff, 5, -1) == 'Boost' then 
				table.remove(missing_buffs, indexOf(missing_buffs, 'Gain'))
			elseif string.sub(this_buff, 0, 2) == 'En' then 
				table.remove(missing_buffs, indexOf(missing_buffs, 'Enspell'))
			end
			if subjob == 'SCH' and string.sub(this_buff, #this_buff - 4) == 'storm' then 
				table.remove(missing_buffs, indexOf(missing_buffs, 'Storm'))
			end
		elseif job == 'SCH' then
			if string.sub(this_buff, 5, -1) == 'storm' then 
				table.remove(missing_buffs, indexOf(missing_buffs, 'Storm'))
			end
		elseif job == 'COR' then
			if string.find(this_buff, 'Roll') then number_of_rolls = number_of_rolls + 1 end
		elseif job == 'GEO' then
			if string.find(this_buff, 'Roll') then has_roll = true end
		end
	end
	table.sort(missing_buffs) -- Make them alphebetical
	table.insert(missing_buffs, 1, string.sub(self.name, 0, 3)..'_'..job ) -- Put name at start of the list
	windower.send_ipc_message('buffcheck update '..table_to_string(missing_buffs))
	update_party_list(missing_buffs)
end

function table_to_string(table_to_convert)
	local new_string = ''
	for i, v in pairs(table_to_convert) do
		new_string = new_string .. v .. '//'
	end
	return new_string
end

function string_to_table(string_to_convert)
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

function find_partial_match(search_table, partial_string, multiple)
	local count = 0
	for key, value in pairs(search_table) do
		if type(value) == "string" and string.find(value, partial_string) then
			return value
		end
	end
	return nil
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
	if action == 'test' then
		for i, v in pairs(tracked_buffs) do
			local printout = ''
			if type(v) == "string" then
				printout = printout .. v .. ' '
			else
				for i2, v2 in pairs(v) do
					printout = printout .. v2 .. ' '
				end
			end
			print(printout)
		end
	elseif action == 'test2' then
		print(tracked_buffs)
	end
end)