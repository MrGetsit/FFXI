_addon.name = 'QueueAction'
_addon.author = 'Spikex'
_addon.version = '1.02'
_addon.commands = {'QueueAction', 'qa'}

-- Changed target to target what the receiver has targeted
-- Added mytarget / mt to target what the sender has target
-- Added check if player is already casting, wait to queue until cast finishes
-- Changed target to fall back to senders target if receiver has no target
-- Removed delay for queue
-- Reject WS if tp below 800 to avoid accidental double tap
-- Added QueueAction: to error messages

require('tables')
require('strings')
require('sets')
packets = require('packets')
res = require('resources')

spells = res.spells
job_abilities = res.job_abilities
weapon_skills = res.weapon_skills

local BASE_RETRY_INTERVAL = 0.3
local MAX_ATTEMPTS = 20
local pending_action = nil -- { type, ability_id, ability_name, recast_id, target_id, attempts, last_sent }
local current_player = nil
local currently_casting = false
local cast_start_time = false
local wait_on_tp = nil

ACTION_INFO = {
	WS = { resources = weapon_skills,	confirm_category = 3 },
	MA = { resources = spells,			confirm_category = 8 },	-- 4 for finish spellcast
	JA = { resources = job_abilities,	confirm_category = 6 }, -- 14 override for DNC abilities
}

windower.register_event('addon command', function(receiver, action_type, action, target)
	if not action then print('QueueAction: No valid QueueAction command found. qa [reciever] [action_type] [action] [target]') return end
	if not current_player then get_player_info() end
	
	-- Find characters between quotes, replace spaces with underscores, remove quotes
	if receiver ~= current_player.name then action = action:gsub(' ', '_') end
	
	-- Add target id if there is valid target
	local target_id = nil
	local ipc_msg = 'qa ' .. receiver .. ' ' .. action_type .. ' ' .. action
	if target then
		-- Target what the sender has targeted
		if target:lower() == 'mytarget' or target:lower() == 'mt' then
			target_id = windower.ffxi.get_mob_by_target('t')
			if target_id then target_id = target_id.id else return end
			
		-- Target what the receiver has targeted, fall back to sender target if reciever has no target
		elseif target:lower() == 'target' or target:lower() == 't' then
			target_id = windower.ffxi.get_mob_by_target('t')
			if target_id then target_id = target_id.id else return end
			if target_id then
				target_id = 'get_target ' .. target_id
			else
				target_id = 'get_target 0'
			end			
		-- Target the receiver
		else
			target_id = windower.ffxi.get_mob_by_name(target).id
		end	
		ipc_msg = ipc_msg .. ' ' .. target_id
	end
	
	-- Skip IPC for current player
	if receiver == current_player.name then
		if not target then 
			target_id = current_player.id 
		else
			target_id = windower.ffxi.get_mob_by_target('t').id
		end
		
		set_pending_action(action_type, action, target_id)
		
	else
		windower.send_ipc_message(ipc_msg)
	end
end)

windower.register_event('ipc message', function(msg)
	if not windower.ffxi.get_info().logged_in then return end
	current_player = windower.ffxi.get_player()
	if not current_player then return end
	
	local args = T(msg:split(' '))
	if args[1] ~= 'qa' then return end -- Not for this addon
	local receiver = args[2]
	if not receiver or receiver:lower() ~= current_player.name:lower() then return end	
	local ipc_action_type = args[3]
	local ipc_action = args[4]:gsub('_', ' ')
	if args[5] then 
		if args[5] == 'get_target' then 
			local new_target = windower.ffxi.get_mob_by_target('t')
			local backup_target = windower.ffxi.get_mob_by_id(args[6])
			if new_target then
				ipc_target_id = new_target.id
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
	
	--print(ipc_action_type .. ' ' .. ipc_action .. ' ' .. ipc_target_id)	
	clear_pending_action()
	set_pending_action(ipc_action_type, ipc_action, ipc_target_id)
end)

function set_pending_action(action_type, action_name, target_id)
	local incoming_action = ACTION_INFO[action_type]
	local ability = incoming_action.resources:with('en', action_name)
	if not ability then
		print('QueueAction: unknown '..action_type..': '..action_name)
		return
	end
	
	-- Check ability current recast time
	local cooldown = 0
	if action_type == 'MA' then
		cooldown = windower.ffxi.get_spell_recasts()[ability.recast_id] or 0
		cooldown = math.floor(cooldown / 60)
	elseif action_type == 'JA' then
		cooldown = windower.ffxi.get_ability_recasts()[ability.recast_id] or 0
	end
	
	-- Delay first attempt if ability was on cooldown
	if cooldown > 0 and cooldown <= 10 then 
		print('QueueAction: ' .. ability.en .. ' queued, waiting on cooldown.')
		start_time = os.clock() + cooldown + 0.1
	elseif cooldown > 10 then
		print('QueueAction: ' .. ability.en .. ' on cooldown ' .. cooldown .. ' canceling.')
		return 
	else
		start_time = os.clock()
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
		retry_interval = BASE_RETRY_INTERVAL,
		attempts = 0,
		last_sent = start_time,
	}
	
	-- Change category for DNC abilities
	if ability.tp_cost and ability.tp_cost > 0 then pending_action.confirm_category = 14 end
	
	-- Make recast longer for corsair shot abilities as they have no animation time and can be spammed before response message is sent
	if pending_action.type == 'JA' and ability.recast_id == 195 then print ('adjust for lightshot') pending_action.retry_interval = 1.0 end
end

function send_pending_action(action)
	local target = windower.ffxi.get_mob_by_id(action.target_id)
	if not target or target.hpp <= 0 then
		print('QueueAction: target no longer exists, dropping queued action ('..action.ability_name..')')
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
		if action.target_id == current_player.id then
			--print(action.type .. ' "' .. action.ability_name .. '"') 
			windower.send_command(action.type .. ' "' .. action.ability_name .. '"')
		else
			--print(action.type .. ' "' .. action.ability_name .. '" ' .. action.target_id) 
			windower.send_command(action.type .. ' "' .. action.ability_name .. '" ' .. action.target_id)
		end
	end
	
	action.attempts = action.attempts + 1
	action.last_sent = os.clock()
end

function clear_pending_action()
	currently_casting = false
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
	
	-- Make sure player is logged in and alive
	local self = windower.ffxi.get_player()
	if not self or self.vitals.hpp <= 0 then return end
	
	-- Check if we have enough TP if using TP ability
	if wait_on_tp and self.vitals.tp >= wait_on_tp then	wait_on_tp = nil end
	
	-- Check if casting has timed out
	if currently_casting and cast_start_time and os.clock() - cast_start_time > 8 then
		currently_casting = false
		cast_start_time = nil
	end

	if wait_on_tp or currently_casting or os.clock() - pending_action.last_sent < pending_action.retry_interval then return end
	
	if pending_action.attempts >= MAX_ATTEMPTS then
		print('QueueAction: gave up on '..pending_action.ability_name..' after '..MAX_ATTEMPTS..' attempts')
		clear_pending_action()
		return
	end
	
	send_pending_action(pending_action)
end)

windower.register_event('incoming chunk', function(id, data)
	if not pending_action then return
		
	elseif id == 0x028 then -- Player action
		local packet = packets.parse('incoming', data)
		if packet.Actor ~= current_player.id then return end
		
		if packet['Category'] == 4 or -- Finished casting
		packet['Target 1 Action 1 Message'] == 0 and currently_casting then -- Interrupted casting
			currently_casting = false
			cast_start_time = nil
			
		elseif packet['Category'] == 8 then -- Started casting
			currently_casting = true
			cast_start_time = os.clock()
		end
		
		-- Check if player ability went through
		if packet['Category'] == pending_action.confirm_category then
			-- Spell matches
			if packet['Target 1 Action 1 Param'] == pending_action.ability_id or 
			-- Ability / Weaponskill Match
			packet['Param'] == pending_action.ability_id or 
			-- Double up doesn't have a unique ID, uses rolls IDs instead
			pending_action.ability_name == 'Double-Up' and packet['Param'] >= 97 and packet['Param'] <= 123 then
				print(pending_action.ability_name .. ' cast successful!')
				clear_pending_action()
			else
				pending_action.last_sent = os.clock()
			end
		end
	
	-- Secondary check for rolls or other actions that can't be reused even when avaliable
	elseif id == 0x029 then
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