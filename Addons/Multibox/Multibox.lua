_addon.author = 'Spikex'
_addon.version = '0.0'
_addon.name = 'Multibox'
_addon.commands = { 'multibox', 'mb' }

-- Changes: 
-- Switched state to stop after zoning

config = require('config')
require('sets')
require('strings')
require('tables')
require('logger')
texts = require('texts')
config = require('config')
res = require('resources')
packets = require('packets')

current_state = 'stop' -- follow: follows leader, stop: stops following, advance: engage and follow enemy, retreat: move back while engaged
current_target = nil
last_checked_distance = nil
new_waypoint = nil -- XY Coordinate, Next place to move after current waypoint is reached
current_waypoint = nil -- XY Coordinate, Follower waypoint that doesn't update until reached to prevent missing a moving waypoint
min_retreat_range = 12 
max_retreat_range =  15
is_following = false
engage_distance = 1.2
can_follow = true
can_engage = true
current_leader = nil
is_leader = false
moving = false
self = nil
interacting = false
zone = nil -- Current zone leader is in
zoning = false
double_tap = false
casting = false -- Don't start moving during a cast, Works but is messed up by sendtargets packet interception
keydown = false
has_focus = false
check = 0 -- Increment to not check every frame

blocked_abilities = S{} 
default_settings = {}
 
 multibox_display_text = ''
 
settings = config.load(default_settings)
t = texts.new(settings)

function update_display(is_visible)
	if is_visible then t:visible(true) else t:visible(false) end	
	
	t:text('Loupan '..pethp)
end

function update_leader(new_leader) -- new_leader = name
	self = windower.ffxi.get_mob_by_target('me') 
	if not self then return end
	if self.name == new_leader then
		zone = windower.ffxi.get_info().zone
		is_leader = true
		windower.send_ipc_message('multibox change_leader '..zone..' '..new_leader)
		stop_moving()
	else -- Update target to turn to if following and not fighting
		if is_following and self.status == 0 then current_target = windower.ffxi.get_mob_by_name(new_leader) end 
		is_leader = false
	end
	current_leader = new_leader
	new_waypoint = { x = self.x, y = self.y } -- Update waypoint info to stop them from running to old position
	current_waypoint = new_waypoint
end

function change_state(new_state, arg1, arg2, arg3)
	if new_state == 'zoning' then
		if zoning then return end -- Already trying to zone
		zoning = true
		current_state = 'zoning' 
		if is_following then
			if is_leader then
				if zone_teleport then -- Teleported from a homepoint/survival guide/etc, so stop
					windower.send_ipc_message('multibox stop '..zone)
				else -- Ran across zone line, everyone move forward
					windower.send_ipc_message('multibox zoning '..zone)
				end
			else 
				if not windower.ffxi.get_info().logged_in or not windower.ffxi.get_mob_by_target('me') then return end -- Sending run command in loading screen crashes game
				current_leader = nil
				interrupt = false
				
				start_zone_pos = windower.ffxi.get_mob_by_target('me')
				local incr = 0
				while windower.ffxi.get_mob_by_target('me') and -- Haven't started zoning
				distance_to(start_zone_pos, windower.ffxi.get_mob_by_target('me')) < 6 and -- At least this far
				incr < 10 do -- Try this many times
					windower.ffxi.run(true) 
					self = windower.ffxi.get_mob_by_target('me')
					if not self then break end -- Started zoning
					--print('zone distance '..distance_to(start_zone_pos, self)..' '..incr)
					coroutine.sleep(0.5)
					incr = incr + 1
				end
			end 
			current_state = 'stop'
		end return
	end
	self = windower.ffxi.get_mob_by_target('me')
	if not self then print('No self') return end
	if not zone then zone = windower.ffxi.get_info().zone end
	if not current_leader then windower.send_ipc_message('multibox request_leader '..zone) end
	interrupt = true
	check = 0
	
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
		elseif can_follow then
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
		new_waypoint = current_waypoint
		interrupt = false
		coroutine.sleep(1) -- Wait a few seconds in case they are in an animation
		--if interrupt then windower.send_command('input /party Resume interrupt') return end
		current_target = windower.ffxi.get_mob_by_name(current_leader)
		new_state = 'follow'
		stop_moving()
		
	elseif new_state == 'stop' then
		stop_engage = true
		stop_moving()
		is_following = false
		
	elseif new_state == 'advance' then
		if not can_engage then return end
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
			if target then current_target = target else print('No target to retreat from') return end
			if double_tap then
				windower.add_to_chat(160, 'Order: Retreat.')
				windower.send_ipc_message('multibox retreat '..zone..' '..current_target.id) 
				windower.ffxi.run(get_direction(current_target, true))
				coroutine.sleep(0.2)
				windower.ffxi.run(false)
			else
				windower.add_to_chat(160, 'Order: Turn around.')
				double_tap = true
				coroutine.schedule(end_double_tap, 2)
				windower.send_ipc_message('multibox reverse '..zone..' '..current_target.id) 
				if windower.ffxi.get_player().target_locked then windower.send_command('input /lockon') end
				turn_to_target(current_target, true)
				new_state = 'reverse'
			end
		else 
			stop_moving()
			current_target = windower.ffxi.get_mob_by_id(arg1)
		end
		
	elseif new_state == 'reverse' then
		stop_engage = true
		stop_moving()
		current_target = windower.ffxi.get_mob_by_id(arg1)
		
	elseif new_state == 'casting' then
		if current_state ~= 'casting' then -- Save state to switch back to after cast
			previous_state = current_state
		end
		if not casting then
			casting = true
			start_casting = false
			stop_moving()
		else
			casting = false
			if not current_target then current_target = windower.ffxi.get_mob_by_target('t') end
			if previous_state == 'follow' then
				change_state('resume_follow', current_target.id)
			else
				change_state(previous_state, current_target.id)
			end
		return end 
		
	elseif new_state == 'interact' then
		interacting = true
		
	elseif new_state == 'end_interact' then
		interacting = false
		if is_following then change_state('resume_follow')
		else change_state('stop') end return
	end
	
	current_state = new_state
	--windower.send_command('input /party state: '..current_state)
end

function interact_with_target(target)
	if not target then print ('No target to interact with') return end
	current_target = target	
	trying_to_interact = true
	event_found = false
	
	local success = false
	
	for i = 0, 5, 1 do -- Send interactions until we get some kind of response
		if interacting or event_found then success = true break end
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
				if event_found then 
					change_state('interact') 
				break end
				coroutine.sleep(1)
			end
		end
	else
		if current_target then print('Couldn\'t interact with '..current_target.name) end
	end
	trying_to_interact = false
end

function engage(new_target)
	if not new_target then stop_engage = true return end
	local success = false
	stop_engage = false
	for i = 0, 5, 1 do -- Try 5 times
		self = windower.ffxi.get_mob_by_target('me')
		if not self or stop_engage or self.hpp < 1 then break end
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
		--print('Couldn\'t Engage')
		change_state('stop')
	end
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

function distance_to(point1, point2)
	new_distance = math.sqrt((point1.x - point2.x)^2 + (point1.y - point2.y)^2)
	return new_distance
end

function stop_moving()
	moving = false
	movpos = windower.ffxi.get_mob_by_target('me')
	if current_waypoint then
		current_waypoint.x = movpos.x
		current_waypoint.y = movpos.y
	end
	windower.ffxi.run(false)
end

function turn_to_target(target, invert)
	if not target then return end
	local tar_pos = windower.ffxi.get_mob_by_id(target.id)
	if not tar_pos then return end
	
	turn_direction = (math.atan2(tar_pos.x - self.x, tar_pos.y - self.y)) - 1.5708
	if invert then turn_direction = turn_direction + 3.14 end
	
	windower.ffxi.turn(turn_direction)
end

function toggle_state(arg1, arg2)
	if arg1 == 'follow' and string.lower(arg2) == string.lower(self.name) then
		can_follow = not can_follow
		windower.send_command('input /party Follow: '..tostring(can_follow))
		if current_state == 'follow' and not can_follow then stop_moving() end
		
	elseif arg1 == 'engage' and string.lower(arg2) == string.lower(self.name) then
		can_engage = not can_engage
		windower.send_command('input /party Engage: '..tostring(can_engage))
		if current_state == 'advance' and not can_engage then change_state('stop') end
	end
end

function enable_sound(mute)
	if mute ~= false then
		windower.send_command('input /mutebgm off')
		windower.send_command('input /mutese off')
		sound_enabled = false
	else
		windower.send_command('input /mutebgm on')
		windower.send_command('input /mutese on')
		sound_enabled = true
	end
end

function end_double_tap()
	double_tap = false
end

function simulate_key_press (key_to_press)
	if keydown then return end
	keydown = true
	if is_leader then 
		print('Sending ['..key_to_press..'] to others')
		windower.send_ipc_message('multibox key_press '..zone..' '..key_to_press) 
	end
	
	windower.send_command('setkey '..key_to_press..' down')
	coroutine.sleep(0.5)
	windower.send_command('setkey '..key_to_press..' up')
	keydown = false
end

function check_recast(check, kind)
	if not check then return end
	coroutine.sleep(2) -- Wait a second for recast timers to update
	if kind == 'ability' then
		recast =  math.round(windower.ffxi.get_ability_recasts()[check.recast_id])
	elseif kind == 'spell' then
		recast = math.round(windower.ffxi.get_spell_recasts()[check.recast_id] / 60)
	else return end
	if blocked_abilities and table.contains(blocked_abilities, check.en) or
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

windower.register_event('addon command', function(action, arg1, arg2)
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
		
	elseif action == 'toggle' or action == 't' then
		if not arg1 or not arg2 then
			windower.add_to_chat(160, 'Specify what to toggle: mb toggle follow character or mb toggle engage character')
			return end
		
		if arg1 == 'follow' or arg1 == 'f' then
			cmd = 'follow'
		elseif arg1 == 'engage' or arg1 == 'e' then
			cmd = 'engage'
		else return end
		
		if string.lower(arg2) == string.lower(self.name) then 
			toggle_state(cmd, arg2) 
		else
			windower.send_ipc_message('multibox toggle '..zone..' '..cmd..' '..arg2)
		end
		
	elseif action == 'u' then
		simulate_key_press('up')
		
	elseif action == 'd' then
		simulate_key_press('down')
		
	elseif action == 'e' then
		simulate_key_press('enter')
	
	else
		windower.add_to_chat(160, 'Multibox commands: ctrl + up/down/left/right/esc : Send key press to all characters')
		windower.add_to_chat(160, 'Multibox commands: ctrl + enter : tell all characters to try and interact with target')
		windower.add_to_chat(160, 'Multibox commands: //mb follow : Disenage and follow current character, double press to move closer to current location')
		windower.add_to_chat(160, 'Multibox commands: //mb stop : Stop moving')
		windower.add_to_chat(160, 'Multibox commands: //mb engage : Engage and approach target')
		windower.add_to_chat(160, 'Multibox commands: //mb retreat : Characters turn away, double press to move away from target until min_retreat_range')
		windower.add_to_chat(160, 'Multibox commands: //mb toggle follow character or //mb t f character: Disable/Enable follow for character')
		windower.add_to_chat(160, 'Multibox commands: //mb toggle engage character or //mb t e character: Disable/Enable engage for character')
	end
end)

windower.register_event('postrender', function()
	self = windower.ffxi.get_mob_by_target('me')
	if not self then if not zoning then change_state('zoning') end return end -- Change to zoning if not, either way return
	if self.hpp == 0 and current_state ~= 'stop' then change_state('stop') return end -- Dead
	if start_casting then change_state('casting') return end -- Casting
	
	if current_leader ~= self.name then -- Only update followers
		player_current = windower.ffxi.get_player()
		if player_current.autorun then 
			moving = true 
		else 
			moving = false 
		end 
	end
	
	if current_state == 'follow' then
		if not current_leader then print('No leader to follow') change_state('stop') return end
		
		if is_leader then -- If leader has moved far enough from last waypoint, create new waypoint
			local distance = distance_to(new_waypoint, self)
			if distance > 2 then 
				if distance < 20 then -- Had it at 5 before, seemed to occassionally trigger within server update
					send_new_waypoint(self) 
				else -- Leader moved too far in a single update
					windower.send_command('input /party Teleported, stopping '..distance)
					windower.send_ipc_message('multibox stop '..zone)
					change_state('stop')
				end
			end
		elseif can_follow then -- Move follower 
			if player_current.status == 1 then return end -- Engaged, don't turn away
			if not current_waypoint then 
				windower.send_command('input /party No Waypoint') 
				change_state('stop') 
				return end
			
			waypoint_distance = distance_to(current_waypoint, self)
			
			if moving then
				if move_here and waypoint_distance < 0.3 then -- Move closer to leaders position
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
				elseif check == 30 then -- Update distance from waypoint
					last_checked_distance = waypoint_distance + 0.2
				end
			else
				if not current_waypoint then 
					windower.send_command('Missing waypoint') 
					change_state('stop')
					return end
				
				if move_here and waypoint_distance > 0.5 or waypoint_distance > 2.5 then -- Start moving to next waypoint
					--windower.send_command('input /party Next waypoint '..waypoint_distance)
					last_checked_distance = waypoint_distance + 0.5
					windower.ffxi.run(get_direction(current_waypoint))
				
				elseif new_waypoint.x and new_waypoint.y and current_waypoint ~= new_waypoint then -- Update next waypoint
					local wdist = distance_to(new_waypoint, current_waypoint)
					if wdist < 30 then -- Check that the next waypoint is nearby
						current_waypoint = new_waypoint -- Move to next waypoint
					else
						windower.send_command('input /party Stopping: Next waypoint too far')
						change_state('stop')
					end
				elseif check == 15 or check == 45 then -- Standing still with nothing else to do, look at target
					turn_to_target(current_target)
				end
			end
		end
		
	elseif current_state == 'advance' then
		if is_leader then return end-- Only followers approach enemies
		
		local t = windower.ffxi.get_mob_by_target('t')
		if not t then 
			if moving then stop_moving() end
			return end
			
		local distance = t.distance:sqrt() - (t.model_size/2 + self.model_size/2 - 1)
		
		if moving then 
			if distance < engage_distance then
				stop_moving()
			end
		else
			if check == 0 or check == 30 then -- Lockon to prevent running wrong direction
				if not player_current.target_locked then windower.send_command('input /lockon') end
			end
			if distance > 3 and not is_leader then
				windower.ffxi.run(get_direction(t))
			elseif check == 0 or check == 20 or check == 40 then
				turn_to_target(t)
			end
		end
		
	elseif current_state == 'reverse' then
		if is_leader then return end
		if check == 0 or check == 20 or check == 40 then
			if player_current.target_locked then windower.send_command('input /lockon') end -- Unlock
			local t = windower.ffxi.get_mob_by_id(current_target.id)
			if not t then return end 
			turn_to_target(t, true)
		end
		
	elseif current_state == 'retreat' then
		if is_leader then return end
		if not current_target then windower.send_command('input /party Lost Target') return end
		local t = windower.ffxi.get_mob_by_id(current_target.id)
		if not t then return end 
		
		local distance =distance_to(t, self)
		if distance < min_retreat_range and not moving then -- Too close, move back
			if player_current.target_locked then windower.send_command('input /lockon') end -- Unlock
			windower.ffxi.run(get_direction(t, true))
			
		elseif distance > max_retreat_range and not moving then -- Too far, move forward
			windower.ffxi.run(get_direction(t))
			
		elseif distance < max_retreat_range and distance > min_retreat_range then -- In range, stop
			if moving then stop_moving()
			else turn_to_target(t) end
		end
	end
	if check >= 60 then -- Keep from running every frame
		check = 0 
	else
		check = check + 1 
	end
end)

windower.register_event('ipc message', function (msg)
    if not windower.ffxi.get_info().logged_in or not self then return end
	zone = windower.ffxi.get_info().zone
	
	ipc_message = msg:split(' ')
	if ipc_message[1] ~= 'multibox' then return end
	local command = ipc_message[2]
	local ipc_zone = ipc_message[3]
	local arg1 = ipc_message[4]
	local arg2 = ipc_message[5]
	local arg3 = ipc_message[6]
	
	if command == 'mute_others' then 
		enable_sound(false) return
		
	elseif command == 'toggle' then
		toggle_state(arg1, arg2)
	end
	
	if ipc_zone ~= tostring(zone) then return end
	
	if command == 'pos_update' then 
		new_waypoint = { x = arg1, y = arg2 }
		newest_distance = distance_to(new_waypoint, self)
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
		simulate_key_press(arg1)
		
	elseif command == 'interact' then
		if arg1 and not trying_to_interact then interact_with_target(windower.ffxi.get_mob_by_id(arg1)) return end
	
	elseif command == 'pet_update' then 
		pethp = tonumber(arg1)
		if pethp > 0 then update_display(true)
		else update_display(false) end
		
	else
		change_state(command, arg1, arg2, arg3)
	end
end)

windower.register_event('status change',function (new, old)
	if old == 1 and new == 0 then  -- Exit combat state
		if is_following then 
			for i = 0, 5, 1 do 
				if current_state == 'follow' then break end
				change_state('resume_follow')
				coroutine.sleep(2)
			end
			
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

windower.register_event('Gain focus',function (new, old)
	if not self then
		loaded = false
		for i = 0, 5, 1 do -- Try 5 times
			self = windower.ffxi.get_mob_by_target('me')
			coroutine.sleep(2)
			if self then loaded = true break end
		end
		if not loaded then return end
	end
	if current_leader ~= self.name then update_leader(self.name) end
	has_focus = true
	enable_sound()
	windower.send_ipc_message('multibox mute_others')
end)

windower.register_event('lose focus',function (new, old)
	has_focus = false
end)
	
windower.register_event('load', 'login', function (new, old)
	if self then return end -- Already ran it
	for i = 0, 10, 1 do -- Don't continue until player is loaded in
		self = windower.ffxi.get_mob_by_target('me')
		if self then break end
		coroutine.sleep(1)
	end
	if not self then return end
	enable_sound(false)
	job = windower.ffxi.get_player().main_job
	subjob = windower.ffxi.get_player().sub_job
	zone = windower.ffxi.get_info().zone
	windower.send_command('input /autotarget off')
	change_state('stop')
	windower.send_ipc_message('multibox request_leader '..zone)
	coroutine.sleep(1)
	if not current_leader then update_leader(self.name) end
end)

windower.register_event('zone change',function (new, old)
	check = 0
	zone = windower.ffxi.get_info().zone
	self = windower.ffxi.get_mob_by_target('me')
	if self then
		while windower.ffxi.get_player().autorun or check < 5 do
			stop_moving()
			coroutine.sleep(0.5)
		end
	end
	coroutine.sleep(1)
	
	if not has_focus then enable_sound(false) end
	zoning = false
end)

windower.register_event('keyboard',function (dik, pressed, flags, blocked )
	if not windower.ffxi.get_info().logged_in then return end
	if not self then self = windower.ffxi.get_player() return end
	if not has_focus then 
		enable_sound()
		has_focus = true
	end
	
	--print('Keyboard event dik:'..dik..'  pressed:'..tostring(pressed)..'  flags:'..flags..'  blocked:'..tostring(blocked))
	if dik == 28 and flags == 4 and pressed then -- dik 28 = enter key, flag 4 = ctrl, not pressed = on key up
		if interacting then -- In event (Dialog open)
			simulate_key_press('enter')
		else
			local target = windower.ffxi.get_mob_by_target('t')
			if not target then return end
			if target.spawn_type == 2 or target.spawn_type == 34 then -- 2 is friendly NPC, 34 object?
				windower.send_ipc_message('multibox interact '..zone..' '..target.id)
				if not trying_to_interact then interact_with_target(target) return end
			end
		end
	elseif dik == 200 and flags == 4 and pressed and interacting then -- dik 200 = up key, flag 1 = shift
		simulate_key_press('up')
	elseif dik == 208 and flags == 4 and pressed and interacting  then -- dik 208 = down key, flag 1 = shift
		simulate_key_press('down')
	elseif dik == 1 and flags == 4 and pressed then -- dik 1 = esc key, flag 1 = shift
		simulate_key_press('escape')
	end
end)

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
	elseif id == 0x029 then -- Spell interrupted
		if current_state == 'casting' then 
			change_state('casting')
		end
	elseif id == 0x00B and not zoning then -- Started zoning
		change_state('zoning')
	elseif id == 0x034 and not zone_teleport then -- Started zoning
		zone_teleport = true
		coroutine.sleep(4)
		zone_teleport = false
	end
end)

windower.register_event('job change', function()
	job = windower.ffxi.get_player().main_job -- Update job for timers
end)

windower.register_event('chat message', function(message, sender, mode)
	if mode == 3 and not is_leader then -- Forward message to leader when recieving a tell
		windower.send_command('input /tell '..current_leader..' Multibox Forward: ['..message..'] - '..sender)
	end
end)
 
filter = S{ -- Block audio change messages
	'Sound effects:*',
	'Background music:*',
}
windower.register_event('incoming text', function(text)
    return filter:any(windower.wc_match+{text})
end)