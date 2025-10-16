_addon.author = 'Spikex'
_addon.version = '0.75'
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
new_waypoint = nil -- XY Coordinate, Next place to move after current waypoint is reached
current_waypoint = nil -- XY Coordinate, Follower waypoint that doesn't update until reached to prevent missing a moving waypoint
retreat_range = 12
max_range =  15
is_following = false
stop_distance = 1.2
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
automate = false
pull_ability = 'Dia3'
report = false

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
blocked_abilities = S{
	'Focus',
	'Footwork',
	'Impetus',
	'Haste Samba',
	'Dia II',
	'Sylvie (UC)',
	'Joachim',
	'Valainderal',
	'Shantotto II',
}
 
default_settings = {}
 
settings = config.load(default_settings)
t = texts.new(settings)

function update_display(show)
	t:text('Loupon '..pethp)
	if show then t:visible(true)
	else t:visible(false) end
end

windower.register_event('ipc message', function (msg)
    if not windower.ffxi.get_info().logged_in then return end
	zone = windower.ffxi.get_info().zone
	
	ipc_message = msg:split(' ')
	if ipc_message[1] ~= 'multibox' then return end
	local command = ipc_message[2]
	if command == 'mute_others' then enable_sound(false) return end
	if ipc_message[3] ~= tostring(zone) then return end
	local arg1 = ipc_message[4]
	local arg2 = ipc_message[5]
	local arg3 = ipc_message[6]
	
	if command == 'pos_update' then 
		new_waypoint = { x = arg1, y = arg2 }		
		newest_distance = math.sqrt((new_waypoint.x - self.x)^2 + (new_waypoint.y - self.y)^2)
		if not waypoint_distance or newest_distance < waypoint_distance then -- New waypoint is closer
			-- Only update if closer, but not too close else it breaks things
			if newest_distance > 3 then current_waypoint = new_waypoint end
			stop_moving()
		end		
    elseif command == 'change_leader' then 
		update_leader(arg1)
		
    elseif command == 'request_leader' then 
		if is_leader and self then update_leader(self.name) end
		
	elseif command == 'key_press' then 
		try_key_press(arg1)
		
	elseif command == 'interact' then
		if arg1 and not trying_to_interact then interact_with_target(windower.ffxi.get_mob_by_id(arg1)) return end
	
	elseif command == 'set_pos' then
		automate = true
		windower.send_command('input /autotarget off')
		set_home_position()
		
	elseif command == 'pet_update' then 
		pethp = tonumber(arg1)
		if pethp > 0 then update_display(true)
		else update_display(false) end
		
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
	if not self then print('No self') return end
	if not zone then zone = windower.ffxi.get_info().zone end
	if not current_leader then windower.send_ipc_message('multibox request_leader '..zone) end
	interrupt = true
	
	if new_state == 'follow' then
		stop_engage = true
		is_following = true
		if is_leader then
			if double_tap then
				windower.add_to_chat(160, 'Move followers to current position.')
				windower.send_ipc_message('multibox follow '..zone..' '..self.x..' '..self.y..' true')
			else
				double_tap = true
				coroutine.schedule(end_double_tap, 2)
				windower.send_ipc_message('multibox follow '..zone..' '..self.x..' '..self.y)
			end
		else
			if self.status == 1 then windower.send_command('input /attack off') end -- Disengage from combat
			current_target = windower.ffxi.get_mob_by_name(current_leader) -- Know who to turn to when stopped
			if arg1 then 
				new_waypoint = { x = arg1, y = arg2 } -- Getting new follow order from leader
				if arg3 then move_here = true end
				
			else new_waypoint = {x = current_target.x, y = current_target.y} end
			
			if moving then stop_moving() end 
		end
		
	elseif new_state == 'resume_follow' then
		stop_moving()
		current_waypoint = { x = self.x, y = self.y }
		interrupt = false
		coroutine.sleep(0.5) -- Wait a few seconds in case they are in an animation
		if interrupt then return end
		current_target = windower.ffxi.get_mob_by_name(current_leader)
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
		
		if automate and not is_leader then 
			circle_amount = math.random(-1,1) 
			coroutine.sleep(math.random(0,4))
			cancel_return = true
		end
		if is_leader then windower.send_ipc_message('multibox advance '..zone..' '..current_target.id) end
		engage(current_target)
		
	elseif new_state == 'retreat' then
		is_following = false
		stop_engage = true
		if windower.ffxi.get_player().target_locked then windower.send_command('input /lockon') end
		if is_leader then 
			local target = windower.ffxi.get_mob_by_target('t')
			if target then 
				current_target = target
				windower.send_ipc_message('multibox retreat '..zone..' '..current_target.id) 
				windower.ffxi.run(get_direction(target, true))
				coroutine.sleep(0.2)
				windower.ffxi.run(false)
			end
		else
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
			if is_following then
				if self.status == 1 then -- Weapon drawn
					new_state = 'advance'
				else
					new_state = 'follow'
				end
			else
				change_state('stop')
				return
			end 
		end 
		
	elseif new_state == 'interact' then
		interacting = true
		if report then
			if last_message and last_report ~= last_message then -- Message hasn't been reported yet
				last_report = last_message
				windower.send_command('input /party Interacting : '..last_message)
			elseif current_target then
				windower.send_command('input /party Interacting with '..current_target.name)
			end
		end
		
	elseif new_state == 'end_interact' then
		interacting = false
		if report and last_report ~= last_message then 
			windower.send_command('input /party '..last_message)
		end
		if is_following then change_state('resume_follow')
		else change_state('stop') end return	
	end
	
	current_state = new_state
end

--- Run in renderer to keep accurate track of distances ---
windower.register_event('postrender', function()
	self = windower.ffxi.get_mob_by_target('me')
	if not self then if not zoning then change_state('zoning') end return end -- Change to zoning if not, either way return
	if self.hpp == 0 and current_state ~= 'stop' then change_state('stop') return end -- Dead
	if start_casting then change_state('casting') return end -- Casting

	if testing then
		local t = windower.ffxi.get_mob_by_target('t')
		self = windower.ffxi.get_mob_by_target('me')
		--print ('target: '..t.facing..' self: '..self.facing)
		local heading = t.facing - self.facing
		print ('heading: '..heading)
		if heading > 0.5 then
			if t.facing > self.facing + 0.1 then
				windower.send_command('setkey a down')
				windower.send_command('setkey a up')
				local try_right = heading
			end
		end
	return end 

	if current_state == 'follow' then
		if not current_leader then print('No leader to follow') change_state('stop') return end
		
		check = check + 1
		
		if is_leader then -- If leader has moved far enough from last waypoint, create new waypoint
			local distance = math.sqrt((new_waypoint.x - self.x)^2 + (new_waypoint.y - self.y)^2)
			if distance > 2 then 
				if distance < 5 then
					send_new_waypoint(self) 
				else -- Leader moved too far in a single update
					windower.send_command('input /party Teleported, stopping')
					windower.send_ipc_message('multibox stop '..zone)
					change_state('stop')
				end
			end
		else -- Move follower 
			if not current_waypoint then windower.send_command('input /party No Waypoint') change_state('stop') return end
			
			waypoint_distance = math.sqrt((current_waypoint.x - self.x)^2 + (current_waypoint.y - self.y)^2)
			
			if moving then				
				if move_here and waypoint_distance < 0.3 then -- Move to leaders position
					move_here = false
					stop_moving()
				
				elseif not move_here and waypoint_distance < 1 then -- Close enough to next waypoint 
					stop_moving()
				
				elseif last_checked_distance < waypoint_distance then -- Running the wrong direction
					if waypoint_distance < 35 then 
						--windower.send_command('input /party Missed a waypoint, moving to leader')
						stop_moving()
						windower.ffxi.run(get_direction(current_waypoint))
					else 
						windower.send_command('input /party Leader too far, stopping')
						change_state('stop') 
					end
				elseif check >= 60 then -- Check roughly once a second
					check = 0
					last_checked_distance = waypoint_distance + 0.2
				end
			else				
				if move_here and waypoint_distance > 0.5 or waypoint_distance > 2.5 then -- Start moving to next waypoint
					last_checked_distance = waypoint_distance + 0.5
					windower.ffxi.run(get_direction(current_waypoint))
					moving = true
				
				elseif current_waypoint ~= new_waypoint then -- Update next waypoint
					local wdist = math.sqrt((new_waypoint.x - current_waypoint.x)^2 + (new_waypoint.y - current_waypoint.y)^2)
					if wdist < 30 then -- Check that the next waypoint is nearby
						current_waypoint = new_waypoint -- Move to next waypoint
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
		if is_leader and not automate then return end-- Only followers approach enemies
		
		local t = windower.ffxi.get_mob_by_target('t')
		if not t then return end
		local distance = t.distance:sqrt() - (t.model_size/2 + self.model_size/2 - 1)
		
		if moving then 
			if distance < stop_distance then
				stop_moving()
			end
		else
			if distance > 3 and not is_leader then
				windower.ffxi.run(get_direction(t))
				if not windower.ffxi.get_player().target_locked then windower.send_command('input /lockon') end -- Lockon to prevent running wrong direction
				stop_distance = math.random(1.5,2.49)
				windower.send_command('setkey d up')
				windower.send_command('setkey a up')
				moving = true
			elseif check > 30 then
				check = 0
				turn_to_target(t)
				if move_behind then
					windower.send_command('setkey d up')
					circling = false
				end
				if automate and not is_leader then
					if circle_amount and circle_amount ~= 0 then
						if circle_amount < 0 then key_press_for_time('a', -circle_amount)
						else key_press_for_time('d', circle_amount) end
						circle_amount = 0
						circling = true
						coroutine.sleep(2)
						circling = false
					end
					local rnd = math.random(1,100)
					if rnd > 95 then circle_amount = math.random(-1,1) end
				end
			else
				check = check + 1
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

function send_new_waypoint(new_position)
	new_waypoint = { x = new_position.x, y = new_position.y }
	windower.send_ipc_message('multibox pos_update '..zone..' '..new_waypoint.x..' '..new_waypoint.y..'')
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
	
	elseif action == 'report' then
		report = not report
		windower.add_to_chat(160, 'Report: '..tostring(report))
	
	elseif action == 'pulla' then
		if not arg1 then windower.add_to_chat(160, 'No pull ability specified. mb pulla Dia3') return end
		pull_ability = arg1
		windower.add_to_chat(160, 'Pulling with: '..tostring(pull_ability))
	
	elseif action == 'pull' then
		home_position = nil
		if arg1 then
			pull_target = arg1
			windower.add_to_chat(160, 'Pulling: '..tostring(pull_target))	
		else 
			windower.add_to_chat(160, 'Specify target to pull: mb pull "Apex Bats"')
		end	
		set_home_position()
		windower.send_ipc_message('multibox set_pos '..zone)
		automate = true
		find_target()
		pull_mob()
	
	elseif action == 'flank' then
		move_behind = not move_behind
		print('Flanking: '..tostring(move_behind))
	
	elseif action == 'test' then
		testing = true
	
	else
		windower.add_to_chat(160, 'Multibox commands: ctrl + esc : Send escape to all characters')
		windower.add_to_chat(160, 'Multibox commands: ctrl + enter : tell all characters to try and interact with target')
		windower.add_to_chat(160, 'Multibox commands: //mb u : Send up arrow to all characters')
		windower.add_to_chat(160, 'Multibox commands: //mb d : Send down arrow to all characters')
		windower.add_to_chat(160, 'Multibox commands: //mb e : Send enter to all characters')
		windower.add_to_chat(160, 'Multibox commands: //mb follow : Disenage and follow current character')
		windower.add_to_chat(160, 'Multibox commands: //mb stop : Stop moving')
		windower.add_to_chat(160, 'Multibox commands: //mb engage : Engage and approach target')
		windower.add_to_chat(160, 'Multibox commands: //mb retreat : Engage and move away from target until retreat_range')
		windower.add_to_chat(160, 'Multibox commands: //mb track spells or ts : Toggle spell tracking - Requires timers')
		windower.add_to_chat(160, 'Multibox commands: //mb track abilities or ta : Toggle ability tracking - Requires timers')
		windower.add_to_chat(160, 'Multibox commands: //mb pull : Pulls anything nearby')
		windower.add_to_chat(160, 'Multibox commands: //mb pull target : Pulls specific target (mb pull "Apex Bats")')
		windower.add_to_chat(160, 'Multibox commands: //mb pulla : Change pulling ability (default: mb pulla Dia3)')
	end
end)

windower.register_event('status change',function (new, old)	
	if old == 1 and new == 0 then  -- Was in combat, but not anymore
		if automate then 
			windower.send_command('setkey d up')
			windower.send_command('setkey a up')
			change_state('stop')
			return_home() 
			if is_leader then
				find_target()
				pull_mob()
			end
		elseif is_following then 
			change_state('resume_follow')
			
		else
			change_state('stop')
		end
	elseif old == 0 and new == 4 then -- Enter event state
		if trying_to_interact then -- Sent command to interact
			event_found = true
			
		elseif not interacting then -- Interacting without command
			change_state('interact') 
		end
	elseif old == 4 and new == 0 then -- Exit event state
		change_state('end_interact')
	end
end)

windower.register_event('gain focus',function (new, old)	
	enable_sound()
	windower.send_ipc_message('multibox mute_others')
end)

function find_target()
	local closest_target = nil
	for i,v in pairs(windower.ffxi.get_mob_array()) do
		if v.spawn_type == 16 and v.hpp > 90 then -- and v.claim_id == 0
			if pull_target and v.name ~= pull_target then print('nopull') return end
			if not closest_target or v.distance < closest_target.distance then
				closest_target = v
			end
		end 
	end
	print ('Target found: '..closest_target.name..' - '..closest_target.id..' - '..closest_target.distance..' - '..closest_target.hpp)
	current_target = windower.ffxi.get_mob_by_id(closest_target.id)
end

function pull_mob()
	mob_engaged = false
	pull_attempt = 0
	while not mob_engaged do
		print ('Pull attempt: '..pull_attempt)
		if pull_attempt > 3 then 
			pull_attempt = 0
			find_target()
			coroutine.sleep(2)
		end
		windower.send_command(pull_ability..' '..current_target.id)
		--windower.send_command('input /'..pull_ability..' '..current_target.id)
		coroutine.sleep(2)
		-- Refresh current target info to see if it was tagged
		current_target = windower.ffxi.get_mob_by_id(current_target.id)
		if current_target.status == 1 then 
			mob_engaged = true 
			break
		else
			pull_attempt = pull_attempt + 1
		 end
	end
	
	local mob_too_far = true
	local count = 0
	while mob_too_far do
		local m_dist = windower.ffxi.get_mob_by_id(current_target.id).distance
		if m_dist < 20 or count > 15 then 
			mob_too_far = false
		else 
			coroutine.sleep(0.5) 
			count = count + 1
		end
	end
	current_state = 'advance'
	windower.send_ipc_message('multibox advance '..zone..' '..current_target.id)
	-- Clear target when targeting myself, used to get enemy target
	if windower.ffxi.get_player().target_index == self.index then key_press_for_time('escape', 1) end
	engage(current_target)
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
	if not success then
		if automate then
			coroutine.sleep(5)
			engage(new_target)
		else
			print('Couldn\'t Engage')
			change_state('stop')
		end
	end
end

function return_home()
	self = windower.ffxi.get_mob_by_target('me')
	local home_distance = math.sqrt((home_position.x - self.x)^2 + (home_position.y - self.y)^2)
	if windower.ffxi.get_player().target_locked then windower.send_command('input /lockon') end
	stop_moving()	
	cancel_return = false
	if home_distance > 5 then
		local too_far = true
		local lastdst = 10000
		while too_far do
			if cancel_return then 
				print('cancel return') 
				stop_moving()
				cancel_return = false 
			break end
			local dst = math.sqrt((home_position.x - self.x)^2 + (home_position.y - self.y)^2)
			print ('distance from home: '..dst)
			if not moving then 
				windower.ffxi.run(get_direction(home_position))
				moving = true
			else 
				if lastdst + 0.2 < dst then -- Moving wrong direction
					print('wrong way')
					stop_moving()	
					windower.ffxi.run(get_direction(home_position))	
				elseif dst < 3 then -- Close enough
					stop_moving()	
				break end
				lastdst = dst							
			end
			coroutine.sleep(0.5)
		end
	end
end

function set_home_position()
	local me = windower.ffxi.get_mob_by_target('me')
	home_position = { x = me.x, y = me.y }		
	windower.add_to_chat(160, 'Home position set: x'..home_position.x..' y'..home_position.y)
end

function update_leader(new_leader) -- new_leader = name
	--print('Leader update: '..new_leader)
	self = windower.ffxi.get_mob_by_target('me') 
	if not self then return end
	if self.name == new_leader then
		zone = windower.ffxi.get_info().zone
		is_leader = true
		windower.send_ipc_message('multibox change_leader '..zone..' '..new_leader)
		enable_sound()
	else -- Update target to turn to if following and not fighting
		if is_following and self.status == 0 then current_target = windower.ffxi.get_mob_by_name(new_leader) end 
		is_leader = false
		enable_sound(false)
	end
	current_leader = new_leader
	new_waypoint = { x = self.x, y = self.y } -- Update waypoint info to stop them from running to old position
	current_waypoint = new_waypoint
end

windower.register_event('unload', function (new, old)
	windower.send_command('setkey a up')
	windower.send_command('setkey d up')
end)
	
windower.register_event('zone change','load', function (new, old)
	self = nil
	interacting = false
	
	for i = 0, 10, 1 do -- Don't continue until player is loaded in
		self = windower.ffxi.get_mob_by_target('me')
		if self then break end
		coroutine.sleep(1)
	end
	if not self then return end
	enable_sound(false)
	job = windower.ffxi.get_player().main_job
	zone = windower.ffxi.get_info().zone
	windower.send_ipc_message('multibox request_leader '..zone)
	coroutine.sleep(1)
	if not current_leader then update_leader(self.name) end
	if current_state ~= 'stop' then change_state('stop') end
	zoning = false
end)

function enable_sound(mute)
	if mute ~= false then
		windower.send_command('input /mutebgm off')
		windower.send_command('input /mutese off')
	else
		windower.send_command('input /mutebgm on')
		windower.send_command('input /mutese on')
	end
end
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

function key_press_for_time(key_to_press, time_to_press)
	windower.send_command('setkey '..key_to_press..' down')
	coroutine.sleep(time_to_press)
	windower.send_command('setkey '..key_to_press..' up')
	coroutine.sleep(1)
	windower.send_command('setkey '..key_to_press..' up')
	windower.send_command('setkey a up')
	windower.send_command('setkey d up')
end

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
		if event_found then
			change_state('interact')
		else
			for i = 0, 3, 1 do -- Check a few times to see if an event started, they take a bit to go through
				-- print('checking for event success')
				if event_found then break end
				coroutine.sleep(1)
			end
			if event_found then 
				change_state('interact')
			else -- Got dialogue with no options				
				if report and last_report ~= last_message then -- Last npc message hasn't been reported yet
					last_report = last_message
					windower.send_command('input /party '..last_message)
				end
			end
		end
	else
		print('Couldn\'t interact with '..current_target.name)
	end
	trying_to_interact = false
end

function check_recast(check, kind)
	if not check then return end
	coroutine.sleep(2) -- Wait a second for recast timers to update
	if kind == 'ability' then
		recast =  math.round(windower.ffxi.get_ability_recasts()[check.recast_id])
	elseif kind == 'spell' then
		recast = math.round(windower.ffxi.get_spell_recasts()[check.recast_id] / 60)
	else return end
	if table.contains(blocked_abilities, check.en) or
	recast > 1200 then return end -- Filter out all 1hrs
	windower.send_command('send @all timers c "'..job..' : '..check.en..'" '..recast)
end

function pet_status()		
	pethp = 100
	while pethp do
		local pet = windower.ffxi.get_mob_by_target('pet')
		if not pet then -- Pet dead / unsummoned
			update_display(false)
			windower.send_ipc_message('multibox pet_update '..zone..' 0') 
			break 
		elseif pet.hpp ~= pethp then -- Pet health changed, update everyone
			pethp = pet.hpp
			windower.send_ipc_message('multibox pet_update '..zone..' '..pethp)
			if pethp > 0 then update_display(true)
			else update_display(false) break end
		end
		coroutine.sleep(2)
	end
end

--- Check for spellcast start ---
windower.register_event('outgoing chunk', function(id, data)
	if id == 0x01A then -- Player action
        local packet = packets.parse('outgoing', data)
		if packet.Category == 3 then -- Spellcast
			start_casting = true 
		
		elseif packet.Category == 9 then -- Ability
			check_recast(res.job_abilities:id(packet.Param)[packet.Param], 'ability')
		end
    end
end)

--- Check for spellcast completion ---
windower.register_event('incoming chunk', function(id, data)
	if id == 0x028 then -- Finish casting spell
		local packet = packets.parse('incoming', data)
		if packet.Actor ~= self.id then return end
		if packet['Category'] == 4 then -- Casting Finish
			if casting then change_state('casting') end
			local sp = res.spells:id(packet.Param)[packet.Param]
			if not sp then return end
			check_recast(sp, 'spell')
			-- No idea what the requirements are, but only geo spells have 32
			if sp.requirements == 32 then pet_status() end
			
		elseif packet['Target 1 Action 1 Message'] == 0 and casting then
			--print('interrupted casting')
			change_state('casting')
		end
	end
end)

--- Update job for timers ---
windower.register_event('job change', function()
	job = windower.ffxi.get_player().main_job
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
	if mode < 124 or not report then return end -- Normal chat channel, probably
	
	last_message = string.trim(text)
	if previous_message == last_message then 
		repeat_dialogue = true 
	else 
		previous_message = last_message
	end
end)
