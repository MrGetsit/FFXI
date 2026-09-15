_addon.name = 'QueueAction'
_addon.author = 'Spikex'
_addon.version = '1.0'
_addon.commands = {'QueueAction', 'qa'}

require('tables')
require('strings')
require('sets')
packets = require('packets')
res = require('resources')

spells = res.spells
job_abilities = res.job_abilities
weapon_skills = res.weapon_skills

BASE_RETRY_INTERVAL = 0.5
MAX_ATTEMPTS = 20
pending_action = nil -- { type, ability_id, ability_name, recast_id, target_id, attempts, last_sent }

ACTION_INFO = {
	WS = { resources = weapon_skills,	confirm_category = 3 },
	MA = { resources = spells,			confirm_category = 4 },
	JA = { resources = job_abilities,	confirm_category = 6 },
}

windower.register_event('addon command', function(receiver, action_type, action, target)
	if not action then print('No valid QueueAction command found. qa [reciever] [action_type] [action] [target]') return end
	
	-- Find characters between quotes, replace spaces with underscores, remove quotes
	action = action:gsub(' ', '_')
	
	-- Add target id if there is valid target
	local valid_target = nil
	if target then
		if target:lower() == 'target' or target:lower() == 't' then
			valid_target = windower.ffxi.get_mob_by_target('t')
		else
			valid_target = windower.ffxi.get_mob_by_name(target)
		end		
	end
	if valid_target then 
		command = 'qa ' .. receiver .. ' ' .. action_type .. ' ' .. action .. ' ' .. valid_target.id
	else
		command = 'qa ' .. receiver .. ' ' .. action_type .. ' ' .. action
	end
	windower.send_ipc_message(command)
end)

windower.register_event('ipc message', function(msg)
	if not windower.ffxi.get_info().logged_in then return end
	local player = windower.ffxi.get_player()
	if not player then return end
	
	local args = T(msg:split(' '))
	if args[1] ~= 'qa' then return end -- Not for this addon	
	local receiver = args[2]
	if not receiver or receiver:lower() ~= player.name:lower() then return end	
	local ipc_action_type = args[3]
	local ipc_action = args[4]:gsub('_', ' ')
	if args[5] then 
		ipc_target_id = tonumber(args[5])
	else
		ipc_target_id = player.id
	end
	
	print(ipc_action_type .. ' ' .. ipc_action .. ' ' .. ipc_target_id)	
	pending_action = nil 
	queue_action(ipc_action_type, ipc_action, ipc_target_id, player)
end)

function queue_action(action_type, action_name, target_id, player)
	local incoming_action = ACTION_INFO[action_type]
	local ability = incoming_action.resources:with('en', action_name)
	if not ability then
		print('QueueAction: unknown '..action_type..': '..action_name)
		return
	end
	
	start_time = 0
	if action_type == 'WS' then 
		if player.vitals.tp < 800 then
			print(ability.en .. ' canceled. Not enough TP.')
			return
		end
	else
		cooldown = 0
		if action_type == 'MA' then
			cooldown = windower.ffxi.get_spell_recasts()[ability.recast_id] or 0
			cooldown = math.floor(cooldown / 60)
		else
			cooldown = windower.ffxi.get_ability_recasts()[ability.recast_id] or 0
		end
		if cooldown > 1 and cooldown <= 10 then 
			print(ability.en .. ' queued, waiting on cooldown.')
			start_time = os.clock() + cooldown + 0.1
		elseif cooldown > 10 then
			print(ability.en .. ' on cooldown ' .. cooldown .. ' canceling.')
			return 
		end
	end
	
	pending_action = {
		type = action_type,
		ability_id = ability.id,
		ability_name = ability.en,
		recast_id = ability.recast_id,
		target_id = target_id,
		confirm_category = incoming_action.confirm_category,
		retry_interval = BASE_RETRY_INTERVAL,
		attempts = 0,
		last_sent = start_time,
	}
end

function send_pending_action(action)
	local target = windower.ffxi.get_mob_by_id(action.target_id)
	if not target then
		print('QueueAction: target no longer exists, dropping queued action ('..action.ability_name..')')
		pending_action = nil
		return
	end	
	-- local debug_msg = 'Trying to use: '..action.ability_name..' on: '..action.target_id
	-- if action.recast_id then debug_msg = debug_msg .. ' ' ..action.recast_id end
	-- print(debug_msg)
	windower.send_command('"'..action.ability_name..'" '..action.target_id)
	
	action.attempts = action.attempts + 1
	action.last_sent = os.clock()
end

windower.register_event('prerender', function()
	if not pending_action or not windower.ffxi.get_mob_by_target('me') then return end
	if os.clock() - pending_action.last_sent < pending_action.retry_interval then return end
	
	if pending_action.attempts >= MAX_ATTEMPTS then
		print('QueueAction: gave up on '..pending_action.ability_name..' after '..MAX_ATTEMPTS..' attempts')
		pending_action = nil
		return
	end
	
	send_pending_action(pending_action)
end)

windower.register_event('action', function(act)
	--if act.actor_id == windower.ffxi.get_mob_by_target('me').id then tprint(act) end
	if not pending_action or not windower.ffxi.get_mob_by_target('me') then return end
	
	--print(act.category .. ' ' .. act.param .. ' ' .. pending_action.confirm_category .. ' ' .. pending_action.ability_id)
	if act.category == pending_action.confirm_category then
		if act.param == pending_action.ability_id then
			print(pending_action.ability_name .. ' cast successful!')
			pending_action = nil
		else
			pending_action.last_sent = os.clock()
		end
	end
end)

function tprint(tbl, indent)
	if not indent then indent = 0 end
	local spaces = string.rep("  ", indent) -- Use two spaces for indentation

	for k, v in pairs(tbl) do
		local key_str
		if type(k) == "number" then
			key_str = "[" .. k .. "]"
		else
			key_str = "['" .. k .. "']"
		end

		if type(v) == "table" then
		   print(2, spaces .. key_str .. " = {") 
			tprint(v, indent + 1)
		   print(2, spaces .. "}")
		else
			local value_str = tostring(v)
			if type(v) == "string" then
				value_str = "'" .. value_str .. "'"
			end
			print(2, spaces .. key_str .. " = " .. value_str .. ",")
		end
	end
end