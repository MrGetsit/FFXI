_addon.name = 'QueueAction'
_addon.author = 'Spikex'
_addon.version = '1.05'
_addon.commands = {'QueueAction', 'qa'}

-- Changes
-- Added function to more quickly determine if action is for current player or not
-- Look abilities up in a small cached index instead of loading the full resource tables
-- Fixed bug where self target wasn't sent correctly
-- Added auto downgrade magic for threnody spells on cooldown
-- Added check if current target is dead to use backup target faster
-- Fixed backuptarget not working with variable being private or receiver having themself selected

require('tables')
require('strings')
require('sets')
packets = require('packets')

local BASE_RETRY_INTERVAL = { MA = 0.8, WS = 0.3, JA = 0.8 } -- Increased delay for magic to compensate for server round trip response
local MAX_ATTEMPTS = 20
local pending_action = nil -- { type, ability_id, ability_name, recast_id, target_id, attempts, last_sent }
local current_player = nil
local currently_casting = nil
local cast_start_time = false
local wait_on_tp = nil

ACTION_INFO = {
	WS = { confirm_category = 3 },
	MA = { confirm_category = 8 },	-- 4 for finish spellcast
	JA = { confirm_category = 6 }, -- 14 override for DNC abilities
}

-- Small name index (id, recast_id, tp_cost) so the full resource tables, which are several MB,
-- don't have to stay loaded. Built from the resources once, saved to data/cache.lua, and only
-- rebuilt if the file is missing/corrupt or we're asked for a name that isn't in it.
local cache_dir = windower.addon_path .. 'data/'
local cache_path = cache_dir .. 'cache.lua'
local cache = nil
local rebuilt_this_session = false

local function save_cache()
	windower.create_dir(cache_dir)
	local f = io.open(cache_path, 'w')
	if not f then print('QueueAction: Unable to write ability cache.') return end
	f:write('return {\n')
	for action_type, entries in pairs(cache) do
		f:write('\t', action_type, ' = {\n')
		for name, e in pairs(entries) do
			f:write(('\t\t[%q] = {id=%d,recast_id=%s,tp_cost=%s,en=%q},\n'):format(name, e.id, tostring(e.recast_id), tostring(e.tp_cost), e.en))
		end
		f:write('\t},\n')
	end
	f:write('}\n')
	f:close()
end

local function index_resource(resource_table, target)
	for _, entry in pairs(resource_table) do
		if type(entry) == 'table' and entry.en and entry.id then
			local key = entry.en:lower()
			local existing = target[key]
			if not existing or entry.id < existing.id then -- Duplicate names: keep the lowest id
				target[key] = { id = entry.id, recast_id = entry.recast_id, tp_cost = entry.tp_cost, en = entry.en }
			end
		end
	end
end

local function build_cache()
	local res = require('resources') -- Only loaded here: first run, corrupt file, or a name we don't know yet
	cache = { MA = {}, WS = {}, JA = {} }
	index_resource(res.spells, cache.MA)
	index_resource(res.weapon_skills, cache.WS)
	index_resource(res.job_abilities, cache.JA)
	save_cache()
	rebuilt_this_session = true
end

local function load_cache()
	local chunk = loadfile(cache_path)
	local ok, data = false, nil
	if chunk then ok, data = pcall(chunk) end
	if ok and type(data) == 'table' and data.MA and data.WS and data.JA then
		cache = data
	else
		build_cache()
	end
end

local function find_ability(action_type, name)
	if not cache then load_cache() end
	local key = name:lower()
	local by_name = cache[action_type]
	local entry = by_name and by_name[key]
	if not entry and by_name and not rebuilt_this_session then
		build_cache() -- Name missing: the game may have added something since the cache was built
		entry = cache[action_type][key]
	end
	return entry
end

windower.register_event('addon command', function(receiver, action_type, action, target)
	if not action then print('QueueAction: No valid QueueAction command found. qa [reciever] [action_type] [action] [target]') return end
	if not current_player then get_player_info() end
	
	-- Find characters between quotes, replace spaces with underscores, remove quotes
	if receiver ~= current_player.name then action = action:gsub(' ', '_') end
	local target_id = nil
	
	-- Skip IPC for current player
	if receiver == current_player.name then
		if target then
			if target == 'mytarget' or target == 'mt' or target == 'target' or target == 't' then
				target_id = windower.ffxi.get_mob_by_target('t')
			else
				target_id = windower.ffxi.get_mob_by_name(target)
			end	
		else 
			target_id = current_player
		end		
		
		if target_id then target_id = target_id.id else print('QueueAction: No target.') return end
		set_pending_action(action_type, action, target_id)
	return end
	
	-- Add target id if there is valid target
	local ipc_msg = 'qa ' .. receiver .. ' ' .. action_type .. ' ' .. action
	if target then
		-- Target what the sender has targeted
		if target:lower() == 'mytarget' or target:lower() == 'mt' then
			target_id = windower.ffxi.get_mob_by_target('t')
			if target_id then target_id = target_id.id else return end
			
		-- Target what the receiver has targeted, fall back to sender target if reciever has no target
		elseif target:lower() == 'target' or target:lower() == 't' then
			local t = windower.ffxi.get_mob_by_target('t')
			if t then
				target_id = 'get_target ' .. t.id
			else
				target_id = 'get_target'
			end			
		-- Target the receiver
		else
			target_id = windower.ffxi.get_mob_by_name(target).id
		end	
		ipc_msg = ipc_msg .. ' ' .. target_id
	end
	
	windower.send_ipc_message(ipc_msg)
end)

windower.register_event('ipc message', function(msg)
	if msg:sub(1, 3) ~= 'qa ' then return end -- Not for this addon
	if not windower.ffxi.get_info().logged_in then return end
	current_player = windower.ffxi.get_player()
	if not current_player then return end
	
	local args = T(msg:split(' '))
	local receiver = args[2]
	if not receiver or receiver:lower() ~= current_player.name:lower() then return end	
	local ipc_action_type = args[3]
	local ipc_action = args[4]:gsub('_', ' ')
	local ipc_target_id
	if args[5] then 
		if args[5] == 'get_target' then 
			local new_target = windower.ffxi.get_mob_by_target('t')
			local backup_target = args[6] and windower.ffxi.get_mob_by_id(tonumber(args[6]))
			
			if new_target then	
				if backup_target and 
				(new_target.name == current_player.name or -- Receiver has themself selected
				new_target.hpp <= 0) then -- Reveiver's target is dead
					ipc_target_id = backup_target.id
				else
					ipc_target_id = new_target.id
				end
			-- Try using senders target instead of receiver
			elseif backup_target then
				ipc_target_id = backup_target.id
			else
				print('QueueAction: No current target.')
				return
			end
		else
			ipc_target_id = tonumber(args[5])
		end
	else
		ipc_target_id = current_player.id
	end
	
	clear_pending_action()
	set_pending_action(ipc_action_type, ipc_action, ipc_target_id)
end)

function set_pending_action(action_type, action_name, target_id)
	local incoming_action = ACTION_INFO[action_type]
	local ability = find_ability(action_type, action_name)
	if not ability then
		print('QueueAction: unknown '..action_type..': '..action_name)
		return
	end
	
	local retry_interval = BASE_RETRY_INTERVAL[action_type] or 0.3
	-- Make recast longer for corsair shot abilities as they have no animation time and can be spammed before response message is sent
	if action_type == 'JA' and ability.recast_id == 195 then retry_interval = 1.0 end
	
	-- Check ability current recast time
	local cooldown = 0
	if action_type == 'MA' then
		cooldown = windower.ffxi.get_spell_recasts()[ability.recast_id] or 0
		if cooldown ~= 0 then
			-- Auto downgrade Threnody songs if on cooldown
			if action_name:contains('Threnody II') then 
				local downgrade = find_ability(action_type, action_name:gsub(' II', ''))
				local down_cd = windower.ffxi.get_spell_recasts()[downgrade.recast_id]
				if down_cd == 0 then
					ability = downgrade
					cooldown = down_cd
				end
			end
			cooldown = math.floor(cooldown / 60)
		end
		
	elseif action_type == 'JA' then
		cooldown = windower.ffxi.get_ability_recasts()[ability.recast_id] or 0
		-- Corsair shot has multiple charges
		if ability.recast_id == 195 then cooldown = cooldown - 40 end
	end
	
	local start_time
	-- Delay first attempt if ability was on cooldown
	if cooldown > 0 and cooldown <= 10 then 
		print('QueueAction: ' .. ability.en .. ' queued, waiting on cooldown.')
		start_time = os.clock() + cooldown + 0.1
	elseif cooldown > 10 then
		print('QueueAction: ' .. ability.en .. ' on cooldown ' .. cooldown .. ' canceling.')
		return 
	else
		start_time = os.clock() - retry_interval -- Already eligible - don't delay the first real attempt
	end
	
	-- Check if ability needs more TP to use
	if action_type ~= 'MA' then
		local cur_tp = windower.ffxi.get_player().vitals.tp
		wait_on_tp = nil
		if action_type == 'WS' then
			if cur_tp < 600 then
				return
			elseif cur_tp < 1000 then
				wait_on_tp = 1000
			end
		elseif action_type == 'JA' and ability.tp_cost then
			if cur_tp < ability.tp_cost then
				wait_on_tp = ability.tp_cost
			end
		end
	end	
	
	pending_action = {
		type = action_type,
		ability_id = ability.id,
		ability_name = ability.en,
		tp_cost = ability.tp_cost,
		target_id = target_id,
		confirm_category = incoming_action.confirm_category,
		retry_interval = retry_interval,
		attempts = 0,
		last_sent = start_time,
	}
	
	-- Change category for DNC abilities
	if ability.tp_cost and ability.tp_cost > 0 then pending_action.confirm_category = 14 end
end

function send_pending_action(action)
	local target = windower.ffxi.get_mob_by_id(action.target_id)
	if not target or target.hpp <= 0 then
		--print('QueueAction: target no longer exists, dropping queued action ('..action.ability_name..')')
		clear_pending_action()
		return
	end
	
	local skip_attempt = false
	
	if currently_casting then
		skip_attempt = true
		
	elseif action.type ~= 'MA' then 
		local cur_tp = windower.ffxi.get_player().vitals.tp
		if action.type == 'WS' and cur_tp < 1000 then
			skip_attempt = true
		elseif action.type == 'JA' and cur_tp < action.tp_cost then
			skip_attempt = true
		end
	end
	
	if not skip_attempt then 
		windower.send_command(action.type .. ' "' .. action.ability_name .. '" ' .. action.target_id)
	end
	
	action.attempts = action.attempts + 1
	action.last_sent = os.clock()
end

function clear_pending_action()
	currently_casting = nil
	cast_start_time = nil
	wait_on_tp = nil
	pending_action = nil
end

function get_player_info()
	current_player = nil
	while not current_player do
		current_player = windower.ffxi.get_player()		
		coroutine.sleep(2)
	end
end

windower.register_event('prerender', function()
	if not pending_action then return end
	
	-- Check if casting has timed out
	if currently_casting and cast_start_time and os.clock() - cast_start_time > 8 then
		currently_casting = nil
		cast_start_time = nil
	end
	
	if currently_casting then return end
	
	-- Make sure player is logged in and alive
	local self = windower.ffxi.get_player()
	if not self or self.vitals.hpp <= 0 then return end
	
	-- Check if we have enough TP if using TP ability
	if wait_on_tp and self.vitals.tp >= wait_on_tp then	wait_on_tp = nil end
		
	if wait_on_tp or currently_casting or os.clock() - pending_action.last_sent < pending_action.retry_interval then return end
	
	if pending_action.attempts >= MAX_ATTEMPTS then
		print('QueueAction: gave up on '..pending_action.ability_name..' after '..MAX_ATTEMPTS..' attempts')
		clear_pending_action()
		return
	end
	--print('casting attempt '..pending_action.attempts)
	send_pending_action(pending_action)
end)

local function raw_actor_id(data) -- Faster way to determine if data is for current player
	local b1, b2, b3, b4 = data:byte(6, 9)
	return b1 + b2 * 256 + b3 * 65536 + b4 * 16777216
end

windower.register_event('incoming chunk', function(id, data)
	if id == 0x028 then -- Player action
		if not current_player or raw_actor_id(data) ~= current_player.id then return end
		local packet = packets.parse('incoming', data)
		
		-- Update players casting status
		local cast_complete = false		
		if currently_casting and packet['Category'] == 4 then -- Finished casting
			if packet['Param'] == currently_casting then 
				currently_casting = nil
				cast_start_time = nil
				cast_complete = true
			end
			
		elseif packet['Category'] == 8 then -- Started casting
			if packet['Target 1 Action 1 Message'] == 0 then
				if packet['Target 1 Action 1 Param'] == currently_casting then -- Interrupted casting
					currently_casting = nil
					cast_start_time = nil
					cast_complete = true
				end
			else
				currently_casting = packet['Target 1 Action 1 Param']
				cast_start_time = os.clock()
			end
		end
		
		-- There seemes to be about a 3 second delay after a cast finishes/interrupts before another can start
		if pending_action then 
			if cast_complete then pending_action.last_sent = os.clock() + 3 end
		else return end
		
		-- Check if player ability went through
		if packet['Category'] == pending_action.confirm_category then
			-- Spell matches
			if packet['Target 1 Action 1 Param'] == pending_action.ability_id or 
			-- Ability / Weaponskill Match
			packet['Param'] == pending_action.ability_id or 
			-- Double up doesn't have a unique ID, uses rolls IDs instead
			pending_action.ability_name == 'Double-Up' and packet['Param'] >= 97 and packet['Param'] <= 123 then
				--print(pending_action.ability_name .. ' cast successful!')
				clear_pending_action()
			else
				pending_action.last_sent = os.clock()
			end
		end
	
	-- Secondary check for rolls or other actions that can't be reused even when avaliable
	elseif pending_action and id == 0x029 then
		local packet = packets.parse('incoming', data)
		if packet.Actor ~= current_player.id then return end
		
		-- print(packet['Param 1'].. ' ' .. packet['Param 2'].. ' ' ..pending_action.ability_id)
		if packet['Param 1'] == pending_action.ability_id then
			print('QueueAction: Unable to use: '..pending_action.ability_name)
			clear_pending_action()
		end
	end
end)

windower.register_event('load', 'login', 'zone change', function (new, old)
	get_player_info()
end)