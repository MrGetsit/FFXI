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
	MA = { category = 0x03, resources = spells,			method = 'recast',	confirm_category = 4 },
	WS = { category = 0x07, resources = weapon_skills,	method = 'tp',		confirm_category = 3 },
	JA = { category = 0x09, resources = job_abilities,	method = 'recast',	confirm_category = 6 },
}

windower.register_event('addon command', function(command, ...)
	if not command then
		print('QueueAction commands:')
		print('qa [Receiver] [Action Type: JA, MA, WS] "[Action]" [Target: T for selected target, blank for current/self]')
		print('qa Spikex WS "Savage Blade"')
		print('qa Spikex MA "Sleep II" T')
	end
	
	-- qa Spikex MA "Sleep II" T
	local args = T{...}
	if #args == 0 then
		print('//qa [Receiver] [Action Type: JA, MA, WS] "[Action]" [Target: T for selected target, blank for current/self]')
		return
	end
	-- Find characters between quotes, replace spaces with underscores, remove quotes
	command = command:gsub('"([^"]*)"', function(inner) return inner:gsub(' ', '_') end)
	-- qa Spikex MA Sleep_II T
	
	-- Add target id if there is valid target
	if command:sub(-2) == ' T' or command:sub(-1) == ' t' then
		local valid_target = windower.ffxi.get_mob_by_target('t')
		if valid_target then 
			command = command .. valid_target.id
			-- qa Spikex MA Sleep_II 45786
		end
	end
	
	windower.send_ipc_message(command)
end)

windower.register_event('ipc message', function(msg)
	print(msg)
	local args = T(msg:split(' '))
	if args[1] ~= 'qa' then return end -- Not for this addon
	if not windower.ffxi.get_info().logged_in then return end
	local player = windower.ffxi.get_player()
	if not player then return end
	
	local receiver = args[2]
	if not receiver or receiver:lower() ~= player.name:lower() then return end
	
	local ipc_action_type = args[3]
	local ipc_action = T(args[4]:split('_'))
	local ipc_name = '"' .. ipc_action .. '"'
	if command[2] then action_type = command[2] end
	if args[5] then 
		ipc_target_id = args[5]
	else
		ipc_target_id = player.id
	end
	
	queue_action(ipc_action_type, ipc_name, ipc_target_id)
end)

windower.register_event('prerender', function()
	if not pending_action then return end
	
	if os.clock() - pending_action.last_sent < pending_action.retry_interval then return end
	if pending_action.attempts >= MAX_ATTEMPTS then
		print('QueueAction: gave up on '..pending_action.ability_name..' after '..MAX_ATTEMPTS..' attempts')
		pending_action = nil
		return
	end	
	
	print('checking for '..pending_action.ability_name)
	local self_mob = windower.ffxi.get_mob_by_target('me')
	if not self_mob then return end
	if self_mob.hpp == 0 then pending_action = nil return end -- Dead, give up
	
	if action_confirmed(pending_action, self_mob) then
		pending_action = nil
	else
		send_pending_action(pending_action)
	end
end)

function queue_action(action_type, name, target_id)
	local current_action = ACTION_INFO[action_type]
	local ability = current_action.resources:with('en', name)
	if not ability then
		print('QueueAction: unknown '..action_type..': '..name)
		return
	end
	
	pending_action = {
		type = action_type,
		ability_id = ability.id,
		ability_name = ability.en,
		recast_id = ability.recast_id,
		target_id = target_id,
		retry_interval = BASE_RETRY_INTERVAL,
		attempts = 0,
		last_sent = 0, -- Forces an immediate first send on the next prerender tick
	}
end

function send_pending_action(action)
	local target = windower.ffxi.get_mob_by_id(action.target_id)
	if not target then
		print('QueueAction: target no longer exists, dropping queued action ('..action.ability_name..')')
		pending_action = nil
		return
	end
	
	print('"'..action.ability_name..'" '..action.target_id)
	windower.send_command('"'..action.ability_name..'" '..action.target_id)
	
	action.attempts = action.attempts + 1
	action.last_sent = os.clock()
end

function action_confirmed(action, self_mob)
	local current_action = ACTION_INFO[action.type]
	
	if current_action.method == 'recast' then
		local current = current_recast(action)
		return current ~= nil and current > 3
	elseif current_action.method == 'tp' then
		return self_mob.tp < 1000
	end
	
	return false
end

function current_recast(action)
	local recasts
	if action.type == 'MA' then
		recasts = windower.ffxi.get_spell_recasts()
	else
		recasts = windower.ffxi.get_ability_recasts()
	end
	if not recasts then return nil end
	
	local value = recasts[action.recast_id]
	if not value then return nil end
	if action.type == 'MA' then value = math.floor(value / 60) end
	return value
end

windower.register_event('action', function(act)
	if not pending_action then return end
	
	local self_mob = windower.ffxi.get_mob_by_target('me')
	if not self_mob or act.actor_id ~= self_mob.id then return end
	
	local current_action = ACTION_INFO[pending_action.type]
	if act.category == current_action.confirm_category then
		pending_action.last_sent = os.clock()
	end
end)