_addon.author = 'Spikex'
_addon.version = '0.6.5'
_addon.commands = { 'multibox', 'mb' }
config = require('config')
require('sets')
require('strings')
require('tables')
require('logger')
texts = require('texts')
config = require('config')
res = require('resources')
packets = require('packets')

current_state = 'stop' -- follow: follows leader, stop: stops following, advance: engage and follow enemy, retreat: engage and stay out of range
current_target = nil
last_checked_distance = nil
latest_position = nil -- XY Coordinate, Next place to move after current waypoint is reached
current_waypoint = nil -- XY Coordinate, Follower waypoint that doesn't update until reached to prevent missing a moving waypoint
retreat_range = 12
max_range =  15
is_following = false
current_leader = nil
is_leader = false
moving = false
self = nil
zone = nil
key_press_time = 0.5
interacting = false
zoning = false
check = 0
double_tap = false
casting = false -- Works but is messed up by sendtargets packet interception

track_spell = true
track_ability = true
filter_ability = false
tracked_abilities = S{
	'Roll',
	'Double-Up',
	'Blaze of Glory',
	'Radial Arcana',
	'Berserk',
	'Sneak Attack',
	'Trick Attack',
	'Sentinel',
}
 
default_settings = {}
 
settings = config.load(default_settings)
t = texts.new(settings)

function update_display()
	-- t:text(followers[1])
	-- t:visible(true)
end

windower.register_event('ipc message', function (msg)
    if not windower.ffxi.get_info().logged_in then return end
	zone = windower.ffxi.get_info().zone
	
	ipc_message = msg:split(' ')
	if ipc_message[1] ~= 'multibox' then return end
	if ipc_message[3] ~= tostring(zone) then return end
	local command = ipc_message[2]
	local arg1 = ipc_message[4]
	local arg2 = ipc_message[5]
	local arg3 = ipc_message[6]
	
	if command == 'pos_update' then 
		latest_position = { x = arg1, y = arg2 }
		
    elseif command == 'change_leader' then 
		update_leader(arg1)
		
    elseif command == 'request_leader' then 
		if is_leader and self then update_leader(self.name) end
		
	elseif command == 'key_press' then 
		try_key_press(arg1)
		
	elseif command == 'interact' then
		if arg1 and not trying_to_interact then interact_with_target(windower.ffxi.get_mob_by_id(arg1)) return end
		
	else
		change_state(command, arg1, arg2, arg3)
	end
end)

function change_state(new_state, arg1, arg2, arg3)
	--print(new_state..' changed')
	if new_state == 'zoning' then
		if zoning then return end -- Already trying to zone
		zoning = true
		current_state = 'zoning' 
		update_display()
		if is_following then
			if is_leader then
				windower.send_ipc_message('multibox zoning '..zone)
			else 
				if not windower.ffxi.get_info().logged_in or not windower.ffxi.get_mob_by_target('me') then return end -- Sending run command in loading screen crashes game
				windower.ffxi.run(true) -- Run forward for a few seconds to get across zone line
				current_leader = nil
				interrupt = false
				coroutine.sleep(4)
				if interrupt then print('zoning interrupt') return end
				if windower.ffxi.get_info().logged_in and windower.ffxi.get_mob_by_target('me') then change_state('stop') end -- Haven't zoned, stop moving
			end 
		end return
	end
	self = windower.ffxi.get_mob_by_target('me')
	if not self then print('no me') return end
	if not zone then zone = windower.ffxi.get_info().zone end
	if not current_leader then windower.send_ipc_message('multibox request_leader '..zone) end
	interrupt = true
	
	if new_state == 'follow' then
		stop_engage = true
		is_following = true
		if is_leader then
			latest_position = {x = self.x, y = self.y} -- Set position ahead of time so new pos is current pos on first call
			if double_tap then
				windower.add_to_chat(160, 'Move followers to current position.')
				windower.send_ipc_message('multibox follow '..zone..' '..latest_position.x..' '..latest_position.y..' true')
			else
				double_tap = true
				coroutine.schedule(end_double_tap, 2)
				windower.send_ipc_message('multibox follow '..zone..' '..latest_position.x..' '..latest_position.y)
			end
		else
			if self.status == 1 then windower.send_command('input /attack off') end -- Disengage from combat
			current_target = windower.ffxi.get_mob_by_name(current_leader) -- Know who to turn to when stopped, Call before latest_position
			if arg1 then 
				latest_position = { x = arg1, y = arg2 } -- Getting new follow order from leader
				if arg3 then move_here = true end
				
			else latest_position = {x = current_target.x, y = current_target.y} end
			
			if moving then stop_moving() end 
			current_waypoint = latest_position
		end
		
	elseif new_state == 'resume_follow' then
		stop_moving()
		interrupt = false
		coroutine.sleep(0.5) -- Wait a few seconds in case they are in an animation
		if interrupt then return end
		current_target = windower.ffxi.get_mob_by_name(current_leader)
		latest_position = { x = current_target.x, y = current_target.y }
		new_state = 'follow'
		stop_moving()
		
	elseif new_state == 'stop' then
		stop_engage = true
		if moving then stop_moving() end
		is_following = false
		
	elseif new_state == 'advance' then
		stop_engage = true
		stop_moving()
		local target
			if arg1 then target = windower.ffxi.get_mob_by_id(arg1)
			else target = windower.ffxi.get_mob_by_target('t') end
		if not target then print('no target') return end
		current_target = target
		if is_leader then windower.send_ipc_message('multibox advance '..zone..' '..current_target.id) end
		engage(current_target)
		
	elseif new_state == 'retreat' then
		stop_engage = true
		if is_leader then 
			local target = windower.ffxi.get_mob_by_target('t')
			if target then 
				current_target = target
				windower.send_ipc_message('multibox retreat '..zone..' '..current_target.id) 
			end
		else
			if windower.ffxi.get_player().target_locked then windower.send_command('input /lockon') end
			stop_moving()
			current_target = windower.ffxi.get_mob_by_id(arg1)
		end
		
	elseif new_state == 'casting' then
		if not casting then
			casting = true
			start_casting = false
			stop_moving()
		else
			casting = false
			if self.status == 1 then -- Weapon drawn
				change_state('advance')
			elseif is_following then
				change_state('follow')
			else
				change_state('stop')
			end return
		end 
		
	elseif new_state == 'interact' then
		if not interacting then  -- Start interaction
			if not current_target then print('No interaction target') return end
			interacting = true
			if last_message and last_report ~= last_message then -- Message hasn't been reported yet
				last_report = last_message
				windower.send_command('input /party Interacting : '..last_message)
			else
				windower.send_command('input /party Interacting with '..current_target.name)
			end
			
		else -- End interaction
			interacting = false
			if last_report ~= last_message then 
				windower.send_command('input /party '..last_message)
			end
			if is_following then change_state('resume_follow')
			else change_state('stop') end return
		end
	end
	
	current_state = new_state
	update_display()
	--print('state :'..current_state)
end

--- Run in renderer to keep accurate track of distances ---
windower.register_event('postrender', function()
	self = windower.ffxi.get_mob_by_target('me')
	if not self then if not zoning then change_state('zoning') end return end -- Change to zoning if not, either way return
	if self.hpp == 0 and current_state ~= 'stop' then change_state('stop') return end -- Dead
	if start_casting then change_state('casting') return end -- Casting

	if current_state == 'follow' then
		if not current_leader then print('No leader to follow') change_state('stop') return end
		
		check = check + 1
		
		if is_leader then -- If leader has moved far enough from last waypoint, create new waypoint
			local distance = math.sqrt((latest_position.x - self.x)^2 + (latest_position.y - self.y)^2)
			if distance > 2 then 
				if distance < 5 then
					send_latest_position(self) 
				else -- Leader moved too far in a single update
					windower.send_command('input /party Teleported, stopping')
					windower.send_ipc_message('multibox stop '..zone)
					change_state('stop')
				end
			end
		else -- Move follower 
			if not current_waypoint then windower.send_command('input /party No Waypoint') change_state('stop') return end
			
			local waypoint_distance = math.sqrt((current_waypoint.x - self.x)^2 + (current_waypoint.y - self.y)^2)
			
			if moving then
				local t = windower.ffxi.get_mob_by_name(current_leader)
				if not t then return end
				local leader_distance = math.sqrt((t.x - self.x)^2 + (t.y - self.y)^2)
				
				if move_here and waypoint_distance < 0.3 then -- Move to leaders position
					move_here = false
					stop_moving()
				
				elseif not move_here and waypoint_distance < 2.5 then -- Close enough to next waypoint 
					stop_moving()
				
				elseif last_checked_distance < waypoint_distance then -- Running the wrong direction
					if leader_distance < 20 then 
						-- windower.send_command('input /party Missed a waypoint, moving to leader')
						current_waypoint = { x = t.x, y = t.y }
						stop_moving()
					else 
						windower.send_command('input /party Leader too far, stopping')
						change_state('stop') 
					end
				elseif check >= 60 then -- Check roughly once a second
					check = 0
					if leader_distance < waypoint_distance - 0.2 then -- Leader closer than waypoint, switch to leader
						current_waypoint = { x = t.x, y = t.y }
						stop_moving()
						
					else
						last_checked_distance = waypoint_distance + 0.2
					end
				end
			else
				if move_here and waypoint_distance > 0.5 or waypoint_distance > 3.5 then -- Start moving to next waypoint
					last_checked_distance = waypoint_distance + 0.5
					windower.ffxi.run(get_direction(current_waypoint))
					moving = true
				
				elseif current_waypoint ~= latest_position then -- Update next waypoint
					local wdist = math.sqrt((latest_position.x - current_waypoint.x)^2 + (latest_position.y - current_waypoint.y)^2)
					if wdist < 20.0 then -- Check that the next waypoint is nearby
						current_waypoint = latest_position -- Move to next waypoint
					else
						windower.send_command('input /party Stopping: Next waypoint too far')
						change_state('stop')
					end
				elseif check >= 30 then -- Standing still with nothing else to do, look at target
					turn_to_target(current_target)
				end
			end
		end
		
	elseif current_state == 'advance' then
		if is_leader then return end-- Only followers approach enemies
		if not current_target then windower.send_command('input /party Lost Target') return end
		local t = windower.ffxi.get_mob_by_id(current_target.id)
		local distance = windower.ffxi.get_mob_by_id(t.id).distance:sqrt() - (t.model_size/2 + self.model_size/2 - 1)
		
		if moving then 
			if distance < 2 then
				stop_moving()
			end
		else
			if distance > 3 then
				windower.ffxi.run(get_direction(t))
				if not windower.ffxi.get_player().target_locked then windower.send_command('input /lockon') end -- Lockon to prevent running wrong direction
				moving = true
			else
				turn_to_target(t)
			end
		end
		
	elseif current_state == 'retreat' then
		if is_leader then return end
		if not current_target then windower.send_command('input /party Lost Target') return end
		local t = windower.ffxi.get_mob_by_id(current_target.id)
		if not t then return end 
		
		local distance = math.sqrt((t.x - self.x)^2 + (t.y - self.y)^2)
		if distance < retreat_range and not moving then -- Too close, move back
			windower.ffxi.run(get_direction(t, true))
			moving = true
			
		elseif distance > max_range and not moving then -- Too far, move forward
			windower.ffxi.run(get_direction(t))
			moving = true
			
		elseif distance < max_range and distance > retreat_range then -- In range, stop
			if moving then stop_moving()
			else turn_to_target(current_target) end
		end
	end
end)

function end_double_tap()
	double_tap = false
end

function send_latest_position(new_position)
	latest_position = { x = new_position.x, y = new_position.y }
	-- print('Updating postition x:'..latest_position.x..' y:'..latest_position.y)
	windower.send_ipc_message('multibox pos_update '..zone..' '..latest_position.x..' '..latest_position.y..'')
end

function get_direction(target, inverse)
	-- 0 is east, pi/2 south, -pi or pi is west, -pi/2 is north
	local me = windower.ffxi.get_mob_by_target('me')
	local h = math.atan2(target.x - me.x, target.y - me.y ) -- Returns between 3.14 and -3.14
	local tau = math.pi/2
	
	-- Rotate 90 degrees since 0 is east instead of north
	if h > -tau then h = h - tau 
	else h = h + math.pi + tau end
	
	-- Run away, Rotate 180 degrees
	if inverse then 
		if h > 0 then h = h - math.pi
		else h = h + math.pi end
	end
	return h
end

function stop_moving()
	moving = false
	windower.ffxi.run(false)
end

function turn_to_target(target)
	if not target then return end
	local tar_pos = windower.ffxi.get_mob_by_id(target.id)
	if not tar_pos then return end
	
	windower.ffxi.turn((math.atan2(tar_pos.x - self.x, tar_pos.y - self.y)) - 1.5708)
end

function engage(new_target)
	if not new_target then stop_engage = true return end
	local success = false
	stop_engage = false
	for i = 0, 5, 1 do -- Try 5 times
		if stop_engage then break end
		self = windower.ffxi.get_mob_by_target('me')
		local t = windower.ffxi.get_mob_by_target('t')
		if t and t.id == new_target.id and self.status == 1 then 
			success = true
		break end
		local attack = packets.new('outgoing', 0x01A, {
				["Target"] = new_target.id,
				["Target Index"] = new_target.index,
				["Category"] = 0x02 -- Engage
			})
		if self.status == 1 then attack['Category'] = 0x0F end -- Switch target
		packets.inject(attack)
		coroutine.sleep(2)
	end
	if success then
		-- print('Engaged with: '..new_target.name) 
	else
		print('Couldn\'t Engage')
		change_state('stop')
	end
end

windower.register_event('addon command', function(action, arg1)
	if not windower.ffxi.get_info().logged_in then return end
	if not self then self = windower.ffxi.get_player() end
	
	update_leader(self.name)
	
	if action == 'follow' then
		change_state('follow')
		
	elseif action == 'stop' then
		windower.send_ipc_message('multibox stop '..zone)
		change_state('stop')
		
	elseif action == 'advance' then
		local target = windower.ffxi.get_mob_by_target('t')
		if not target then return end
		if target.spawn_type == 16 or target.spawn_type == 14 then
			change_state('advance')
		end
		
	elseif action == 'retreat' then
		local target = windower.ffxi.get_mob_by_target('t')
		if not target then return end
		if target.spawn_type == 16 or target.spawn_type == 14 then
			change_state('retreat')
		end
		
	elseif action == 'track spells' or action == 'ts' then
		track_spell = not track_spell
		windower.add_to_chat(160, 'Track Spells: '..tostring(track_spell))
		
	elseif action == 'track abilities' or action == 'ta' then
		track_ability = not track_ability
		windower.add_to_chat(160, 'Track Abilities: '..tostring(track_ability))
		
	elseif action == 'u' then
		try_key_press('up')
		
	elseif action == 'd' then
		try_key_press('down')
		
	elseif action == 'e' then
		try_key_press('enter')
		
	elseif action == 'dispel' then
		local t = windower.ffxi.get_mob_by_target('t')
		if not t then return end
		if t.spawn_type == 16 or t.spawn_type == 14 then
			if turn then
				windower.send_command('send Cissilea Dispel '..t.id) 
				turn = false
			else
				windower.send_command('send Sneaksy DarkShot '..t.id) 
				turn = true
			end
		end
	
	elseif action == 't' then
		local tbl = windower.ffxi.get_ability_recasts()
		-- if tbl then table.vprint(tbl) end
		-- update_display()
		table.vprint(tbl)
	
	elseif action == 'bot' then
		windower.send_command('send Cissilea lua r healbot')
		windower.send_command('send Cissilea hb buff Spikex Refresh ')
		windower.send_command('send Cissilea hb buff Cissilea Refresh ')
		windower.send_command('send Cissilea hb debuff dia2')
		windower.send_command('send Cissilea hb disable cure')
		--windower.send_command('send Cissilea hb mincure 4')
		--windower.send_command('send Cissilea hb debuff slow')
		--windower.send_command('send Cissilea hb debuff paralyze')
		windower.send_command('send Cissilea hb on')
	else
		windower.add_to_chat(160, 'Multibox commands: //mb follow : Disenage and follow current character')
		windower.add_to_chat(160, 'Multibox commands: //mb stop : Stop moving')
		windower.add_to_chat(160, 'Multibox commands: //mb engage : Engage and approach target')
		windower.add_to_chat(160, 'Multibox commands: //mb retreat : Engage and move away from target until retreat_range')
		windower.add_to_chat(160, 'Multibox commands: //mb track spells or ts : Toggle spell tracking - Requires timers')
		windower.add_to_chat(160, 'Multibox commands: //mb track abilities or ta : Toggle ability tracking - Requires timers')
		windower.add_to_chat(160, 'Multibox commands: //mb u : Send up arrow to all characters')
		windower.add_to_chat(160, 'Multibox commands: //mb d : Send down arrow to all characters')
		windower.add_to_chat(160, 'Multibox commands: //mb e : Send enter to all characters')
		windower.add_to_chat(160, 'Multibox commands: ctrl + esc : Send escape to all characters')
		windower.add_to_chat(160, 'Multibox commands: ctrl + enter : tell all characters to try and interact with target')
	end
end)

windower.register_event('status change',function (new, old)
	
	self = windower.ffxi.get_mob_by_target('me')
	if old == 1 and new == 0 then  -- Was in combat, but not anymore
		if is_following then 
			change_state('resume_follow')
		else
			change_state('stop')
		end
	elseif old == 0 and new == 4 then -- Enter event state
		if trying_to_interact then
			event_found = true
		else
			change_state('interact')
		end
	elseif old == 4 and new == 0 then -- Exit event state
		if interacting then
			--print('Exit Event State')
			change_state('interact')
		end
	end
end)

function update_leader(new_leader) -- new_leader = name
	--print('Leader update: '..new_leader)
	self = windower.ffxi.get_mob_by_target('me') 
	if not self then return end
	if self.name == new_leader then
		zone = windower.ffxi.get_info().zone
		is_leader = true
		windower.send_ipc_message('multibox change_leader '..zone..' '..new_leader)
	else -- Update target to turn to if following and not fighting
		if is_following and self.status == 0 then current_target = windower.ffxi.get_mob_by_name(new_leader) end 
		is_leader = false
	end
	current_leader = new_leader
	if moving then stop_moving() end
	latest_position = { x = self.x, y = self.y } -- Update waypoint info to stop them from running to old position
	current_waypoint = latest_position
end

windower.register_event('zone change','load', function (new, old)
	self = nil
	interacting = false
	
	for i = 0, 10, 1 do -- Don't continue until player is loaded in
		self = windower.ffxi.get_mob_by_target('me')
		if self then break end
		coroutine.sleep(1)
	end
	if not self then return end
	zone = windower.ffxi.get_info().zone
	windower.send_ipc_message('multibox request_leader '..zone)
	coroutine.sleep(1)
	if not current_leader then update_leader(self.name) end
	if current_state ~= 'stop' then change_state('stop') end
	zoning = false
end)

windower.register_event('keyboard',function (dik, pressed, flags, blocked )
	if not windower.ffxi.get_info().logged_in then return end
	if not self then self = windower.ffxi.get_player() return end
	if current_leader ~= self.name then update_leader(self.name) end
	
	--print('Keyboard event dik:'..dik..'  pressed:'..tostring(pressed)..'  flags:'..flags..'  blocked:'..tostring(blocked))
	if dik == 28 and flags == 4 and not pressed then -- dik 28 = enter key, flag 4 = ctrl, not pressed = on key up
		if interacting then -- In event (Dialog open)
			try_key_press('enter')		
		else
			local target = windower.ffxi.get_mob_by_target('t')
			if not target then return end
			if target.spawn_type == 2 or target.spawn_type == 34 then -- 2 is friendly NPC, 34 object?
				windower.send_ipc_message('multibox interact '..zone..' '..target.id)
				if not trying_to_interact then interact_with_target(target) return end
			end
		end
	elseif dik == 1 and flags == 4 and not pressed then -- dik 1 = esc key, flag 1 = shift
		try_key_press('escape')
	end
end)

function try_key_press (key_to_press)
	if is_leader then 
		print('Sending ['..key_to_press..'] to others')
		windower.send_ipc_message('multibox key_press '..zone..' '..key_to_press) 
	end
	
	windower.send_command('input /party Pressing '..key_to_press)
	windower.send_command('setkey '..key_to_press..' down')
	coroutine.sleep(key_press_time)
	windower.send_command('setkey '..key_to_press..' up')
end

function interact_with_target(target)
	if not target then print ('No target to interact with') return end
	current_target = target
	
	trying_to_interact = true
	event_found = false
	
	last_report = nil
	last_message = nil
	repeat_dialogue = false
	
	local success = false
	
	for i = 0, 5, 1 do -- Send interactions until we get some kind of response
		if interacting or event_found or repeat_dialogue then success = true break end
		print('Interact attempt: '..i)
		packets.inject(packets.new('outgoing', 0x01A, {
			['Target'] = target.id,
			['Target Index'] = target.index,
			['Category'] = 0,
		}))
		coroutine.sleep(1)
	end
	if success then
		for i = 0, 3, 1 do -- Check a few times to see if an event started, they take a bit to go through
			-- print('checking for event success')
			if event_found then break end
			coroutine.sleep(1)
		end
		if event_found then -- In event state, talking to npc with more than a few lines of dialogue
			change_state('interact')
		else -- Got dialogue with no options
			if last_report ~= last_message then -- Last npc message hasn't been reported yet
				last_report = last_message
				windower.send_command('input /party '..last_message)
			end
		end
	else
		print('Couldn\'t interact with '..current_target.name)
	end
	trying_to_interact = false
end

--- Check for spellcast start ---
windower.register_event('outgoing chunk', function(id, data)
	if id == 0x01A then -- Player action
        local packet = packets.parse('outgoing', data)
		if packet.Category == 3 then -- Spell cast
			start_casting = true
			spellcast = res.spells:id(packet.Param)[packet.Param]
			--print(spell.en)
		elseif track_ability and packet.Category == 9 then -- Job ability
			local ability = res.job_abilities:id(packet.Param)[packet.Param]
			if filter_ability and not table.contains(tracked_abilities, ability.en) then return end
			coroutine.sleep(2) -- Wait a second for recast timers to update
			local arecast = windower.ffxi.get_ability_recasts()[ability.recast_id]
			print(ability.en.. ' ' ..arecast)
			windower.send_command('send @all timers c "['..self.name..'] '..ability.en..'" '..arecast)
		end
    end
end)

--- Check for spellcast completion ---
windower.register_event('incoming chunk', function(id, data)
	if id == 0x028 and casting then -- Finish casting spell
		local packet = packets.parse('incoming', data)
		if packet['Category'] == 4 and casting then
			--print('finished casting')
			change_state('casting')
			
			if track_spell then
				coroutine.sleep(1)
				local srecast = math.round(windower.ffxi.get_spell_recasts()[spellcast.recast_id] / 60) + 1
				windower.send_command('send @all timers c "['..self.name..'] '..spellcast.en..'" '..srecast)
			end
		elseif packet['Target 1 Action 1 Message'] == 0 and casting  then
			--print('interrupted casting')
			change_state('casting')
		end
	end
end)

--- Forward message to leader when recieving a tell ---
windower.register_event('chat message', function(message, sender, mode)
	if mode == 3 and not is_leader then
		windower.send_command('input /tell '..current_leader..' Forward: ['..message..'] - '..sender)
	end
end)

previous_message = nil
--- Output most recent npc dialogue ---
windower.register_event('incoming text', function(text, modified, mode)
	if mode < 124 then return end -- Normal chat channel, probably
	last_message = string.trim(text)
	if previous_message == last_message then 
		repeat_dialogue = true 
	else 
		previous_message = last_message
	end
end)

--- Hide command spam message ---
windower.register_event('incoming text', function(text)
	filter = S{'*A command error*', }
    return filter:any(windower.wc_match+{text})
end)