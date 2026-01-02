_addon.author = 'Spikex'
_addon.version = '0.95'
_addon.name = 'Multibox'
_addon.commands = { 'multibox', 'mb' }

-- Changes: 
-- Fixed not resuming follow after spellcast
-- Reworked resume follow logic, again...
-- Followers start following after 2+ waypoints to give space
-- Removed current_target
-- Removed sound controls and created new addon just for that
-- Removed ability timers and created new addon 

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
last_checked_distance = nil
new_waypoint = nil -- XY Coordinate, Next place to move after current waypoint is reached
waypoints = {} -- List of waypoints to follow
min_retreat_range = 12 
max_retreat_range =  15
is_following = false
engage_distance = 2.5
current_leader = nil
last_position = nil
position_check_timer = 0
casting_recovery = false
is_leader = false
moving = false
self = nil
interacting = false
zone = nil -- Current zone leader is in
zoning = false
double_tap = false
casting = false -- Don't start moving during a cast, Works but is messed up by sendtargets packet interception
move_here = false
keydown = false
command_mode = 'all'
check = 0 -- Increment to not check every frame
casting_timeout = 0

blocked_abilities = S{} 
default_settings = {}
 
multibox_display_text = ''
 
settings = config.load(default_settings)
t = texts.new(settings)

function update_display(is_visible)
	if is_visible then t:visible(true) else t:visible(false) return end	
	t:text('Loupan '..pethp)
end

function update_leader(new_leader) -- new_leader = character name
	self = windower.ffxi.get_mob_by_target('me') 
	if not self then print('no self update_leader') return end
	last_waypoint = nil
	waypoints = {}
	if self.name == new_leader then
		zone = windower.ffxi.get_info().zone
		is_leader = true
		windower.send_ipc_message('multibox change_leader '..zone..' '..new_leader)
		stop_moving()
	else -- Update target to turn to if following and not fighting
		is_leader = false
	end
	current_leader = new_leader
	new_waypoint = { x = self.x, y = self.y } -- Update waypoint info to stop them from running to old position
end

function change_state(new_state, arg1, arg2, arg3)
	if new_state == 'zoning' then
		if zoning then return end -- Already trying to zone
		zoning = true
		current_state = 'zoning' 
		if is_following then
			stop_moving()
			is_following = false
			last_waypoint = nil
			
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
					self = windower.ffxi.get_mob_by_target('me')
					if not self then break end -- Started zoning
					windower.ffxi.run(true) 
					coroutine.sleep(0.5)
					incr = incr + 1
				end				
			end 
		end return
	end
	self = windower.ffxi.get_mob_by_target('me')
	if not self then return end
	if not zone then zone = windower.ffxi.get_info().zone end
	if not current_leader then windower.send_ipc_message('multibox request_leader '..zone) end
	interrupt = true
	check = 0
	
	if new_state == 'follow' then
		if command_mode == 'only_engage' then return end
		stop_engage = true
		waypoints = {}
		if is_leader then
			last_waypoint = nil
			if double_tap and not wait_for_seconds then
				windower.add_to_chat(160, 'Move followers to current position.')
				windower.send_ipc_message('multibox follow '..zone..' '..self.x..' '..self.y..' true')
				wait_for_seconds = true
				coroutine.schedule(function() wait_for_seconds = false end, 1)
			else
				double_tap = true
				coroutine.schedule(function() double_tap = false end, 2)
				windower.send_ipc_message('multibox follow '..zone..' '..self.x..' '..self.y)
			end
		else
			if self.status == 1 then windower.send_command('input /attack off') end -- Disengage from combat
			if windower.ffxi.get_player().target_locked then windower.send_command('input /lockon') end
			if moving then stop_moving() end 
			turn_to_target(windower.ffxi.get_mob_by_name(current_leader))
			
			if arg1 then -- Getting new follow order from leader
				new_waypoint = { x = tonumber(arg1), y = tonumber(arg2) }
				if distance_to(new_waypoint, self) > 40 then return end
				if arg3 then -- Double tap
					--print('Double tap follow - clearing waypoints')
					waypoints = {}
					move_here = true 
				end
				table.insert(waypoints, new_waypoint)
			end			
		end
		is_following = true
	
	elseif new_state == 'stop' then
		stop_engage = true
		stop_moving()
		is_following = false
		
	elseif new_state == 'advance' then
		stop_engage = true
		local target
		if is_leader then			
			target = windower.ffxi.get_mob_by_target('t')
			if not target then print('no target') return end
			windower.send_ipc_message('multibox advance '..zone..' '..target.id)
			if command_mode == 'only_follow' then return end
		else		
			if command_mode == 'only_follow' then print('only follow') return end
			stop_moving()
			if arg1 then 
				target = windower.ffxi.get_mob_by_id(arg1)
			else return end
		end
		engage(target) 
		
	elseif new_state == 'retreat' then
		stop_engage = true
		
		if is_leader then
			local target = windower.ffxi.get_mob_by_target('t')
			if not target then print('No target to retreat from') return end
			if double_tap then
				windower.add_to_chat(160, 'Order: Retreat.')
				windower.send_ipc_message('multibox retreat '..zone..' '..target.id) 
				windower.ffxi.run(get_direction(target, true))
				coroutine.sleep(0.2)
				windower.ffxi.run(false)
			else
				windower.add_to_chat(160, 'Order: Turn around.')
				double_tap = true
				coroutine.schedule(function() double_tap = false end, 2)
				windower.send_ipc_message('multibox reverse '..zone..' '..target.id) 
				if windower.ffxi.get_player().target_locked then windower.send_command('input /lockon') end
				turn_to_target(target, true)
				new_state = 'reverse'
			end
		else 
			stop_moving()
		end
		
	elseif new_state == 'reverse' then
		stop_engage = true
		stop_moving()
		
	elseif new_state == 'interact' then
		interacting = true
		
	elseif new_state == 'end_interact' then
		interacting = false
		if is_following then change_state('follow')
		else change_state('stop') end return
	end
	
	current_state = new_state
end

function interact_with_target(target)
	if not target then print ('No target to interact with') return end
	trying_to_interact = true
	event_found = false
	
	local success = false
	
	--print('Attempting to interact with '..target.name)
	for i = 0, 5, 1 do -- Send interactions until we get some kind of response
		if interacting or event_found then success = true break end
		--print('Interact attempt: '..i)
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
		if target then print('Couldn\'t interact with '..target.name) end
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
	if not success then -- Unable to engage
		change_state('stop')
	end
end

function send_new_waypoint(new_position)
	new_waypoint = { x = new_position.x, y = new_position.y }
	windower.send_ipc_message('multibox pos_update '..zone..' '..new_waypoint.x..' '..new_waypoint.y..'')
end

function get_direction(target, inverse)
	-- 0 is east, pi/2 south, -pi or pi is west, -pi/2 is north
	if not target then return end
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
	waypoints = {}
	moving = false
	if windower.ffxi.get_info().logged_in and -- Sending run command without player crashes game
	windower.ffxi.get_mob_by_target('me') then
		windower.ffxi.run(false)
	end
end

function turn_to_target(target, invert)
	if not target then return end
	local tar_pos = windower.ffxi.get_mob_by_id(target.id)
	if not tar_pos then return end
	
	turn_direction = (math.atan2(tar_pos.x - self.x, tar_pos.y - self.y)) - 1.5708
	if invert then turn_direction = turn_direction + 3.14 end
	
	windower.ffxi.turn(turn_direction)
end

function toggle_state()
	if command_mode == 'all' then
		windower.add_to_chat(160, 'Multibox: Follow Mode.')
		command_mode = 'only_follow'
		
	elseif command_mode == 'only_follow' then
		windower.add_to_chat(160, 'Multibox: Engage Mode.')
		command_mode = 'only_engage'
		waypoints = {}
		
	else
		windower.add_to_chat(160, 'Multibox: All Mode.')
		command_mode = 'all'
	end
	change_state('stop')
end

function simulate_key_press (key_to_press)
	if keydown then return end
	keydown = true
	if is_leader then 
		--print('Sending ['..key_to_press..'] to others')
		windower.send_ipc_message('multibox key_press '..zone..' '..key_to_press) 
	end
	
	windower.send_command('setkey '..key_to_press..' down')
	coroutine.sleep(0.5)
	windower.send_command('setkey '..key_to_press..' up')
	keydown = false
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
		if arg1 then
			windower.add_to_chat(160, 'Multibox: Changing Mode for: '..arg1)
			windower.send_ipc_message('multibox toggle '..zone..' '..string.lower(arg1))

		else
			windower.send_ipc_message('multibox toggle '..zone)
			toggle_state()
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
	if casting then
		casting_timeout = casting_timeout + 1
		if casting_timeout > 600 then 
			--print('Casting timeout, resetting')
			casting = false
			casting_timeout = 0
		end
	else
		casting_timeout = 0
	end
	if current_state == 'follow' then
		if not current_leader then print('No leader to follow') change_state('stop') return end
		
		if is_leader then -- If leader has moved far enough from last waypoint, create new waypoint
			if last_waypoint then 
				local distance = distance_to(last_waypoint, self)
				if distance > 2 then 
					if distance < 10 then -- Had it at 5 before, seemed to occassionally trigger within server update
						last_waypoint = { x = self.x, y = self.y }
						send_new_waypoint(self) 
					else -- Leader moved too far in a single update
						windower.send_command('input /party Teleported, stopping '..distance)
						windower.send_ipc_message('multibox stop '..zone)
						change_state('stop')
					end
				end
			else
				last_waypoint = { x = self.x, y = self.y }
				send_new_waypoint(self)
			end
		else -- Move follower 
			player_current = windower.ffxi.get_player()
			
			if is_following and current_state ~= 'follow' then
				print('State mismatch detected, correcting')
				current_state = 'follow'
			end
				
			-- Check if character is actually moving by comparing positions
			position_check_timer = position_check_timer + 1
			if position_check_timer >= 30 then 
				if last_position and moving then
					local pos_distance = math.sqrt((self.x - last_position.x)^2 + (self.y - last_position.y)^2)
					if pos_distance < 0.05 then -- Character hasn't moved but moving flag is true
						--print('Movement stuck detected, resetting')
						windower.ffxi.run(false)
						moving = false
					end
				end
				last_position = { x = self.x, y = self.y }
				position_check_timer = 0
			end
			
			if player_current.status == 1 or casting or casting_recovery then
				if moving then
					windower.ffxi.run(false)
					moving = false
				end
			return end
			
			if not waypoints[1] then return end
			
			waypoint_distance = distance_to(waypoints[1], self)
			
			--if check == 0 then
			--	print(string.format('WP: %d/%d | Dist: %.2f | Moving: %s | MoveHere: %s', 
			--	1, #waypoints, waypoint_distance, tostring(moving), tostring(move_here)))
			--end			
			
			if not moving and waypoint_distance < 0.8 then
				--print('Already at waypoint, removing it ('..#waypoints..' total)')
				table.remove(waypoints, 1)
				if not waypoints[1] then return end
				waypoint_distance = distance_to(waypoints[1], self)
			end
			
			if moving then
				if (move_here and waypoint_distance < 0.2) or -- Stop on position
				(not move_here and waypoint_distance < 0.8) then -- Close enough
					--print('Reached waypoint '..#waypoints..' remaining')
					move_here = false
					table.remove(waypoints, 1)
					last_checked_distance = nil
					
					if waypoints[1] then
						local next_distance = distance_to(waypoints[1], self)
						--print(string.format('Next WP distance: %.2f', next_distance))
						
						if next_distance > 0.5 then
							--print(string.format('Immediately moving to next WP (%.2f away)', next_distance))
							last_checked_distance = next_distance
							windower.ffxi.run(get_direction(waypoints[1]))
							moving = true
						else
							--print('Next WP too close, will check again next frame')
							moving = false
						end
					else -- No more waypoints
						stop_moving()
					end
					
				elseif last_checked_distance and last_checked_distance < waypoint_distance then
					--print(string.format('Wrong direction - was %.2f now %.2f', last_checked_distance, waypoint_distance))

					if waypoint_distance < 20 then 
						windower.ffxi.run(false)
						moving = false
						last_checked_distance = nil 
					else 
						windower.send_command('input /party Next waypoint too far, stopping')
						change_state('stop') 
					end
				elseif check == 30 then
					if not last_checked_distance or waypoint_distance < last_checked_distance then
						last_checked_distance = waypoint_distance
					end
				end
			elseif not casting then				
				if waypoint_distance > 0.5 then  -- If we're far enough from the waypoint
					--print(string.format('Starting movement to WP (%.2f away)', waypoint_distance))
					if not move_here and #waypoints < 2 then return end
					last_checked_distance = waypoint_distance
					windower.ffxi.run(get_direction(waypoints[1]))
					moving = true
					
				elseif check == 30 then -- Periodic check
					if player_current.status == 0 and player_current.target_locked then 
						windower.send_command('input /lockon') 
					end
				end
			end
		end
		
	elseif current_state == 'advance' then
		if is_leader then return end-- Only followers approach enemies
		
		local t = windower.ffxi.get_mob_by_target('t')
		if not t then 
			if moving then stop_moving() end
			if is_following then 
				change_state('follow') 
			else
				change_state('stop') 
			end
		return end	
		local distance = t.distance:sqrt() - (t.model_size/2 + self.model_size/2 - 1)
		
		if moving then 
			if distance < engage_distance then
				stop_moving()
			end
		elseif not casting then
			if check == 0 or check == 30 then -- Lockon to prevent running wrong direction
				if not windower.ffxi.get_player().target_locked then windower.send_command('input /lockon') end
			end
			if distance > 3 and not is_leader then
				moving = true
				windower.ffxi.run(get_direction(t))
			elseif check == 0 or check == 20 or check == 40 then
				turn_to_target(t)
			end
		end
		
	elseif current_state == 'reverse' then
		if is_leader then return end
		if check == 0 or check == 20 or check == 40 then
			if windower.ffxi.get_player().target_locked then windower.send_command('input /lockon') end -- Unlock
			local t = windower.ffxi.get_mob_by_target('t')
			if t then 		
				turn_to_target(t, true)	
			elseif is_following then 
				change_state('follow') 
			else
				change_state('stop') 
			end
		end
		
	elseif current_state == 'retreat' then
		if is_leader then return end
		local t = windower.ffxi.get_mob_by_target('t')
		if not t then 
			if is_following then 
				change_state('follow')
			else
				change_state('stop')
			end	
		return end
		local distance = distance_to(t, self)
		if distance < min_retreat_range and not moving then -- Too close, move back	
			if windower.ffxi.get_player().target_locked then windower.send_command('input /lockon') end -- Unlock
			moving = true
			windower.ffxi.run(get_direction(t, true))
			
		elseif distance > max_retreat_range and not moving then -- Too far, move forward
			moving = true
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
	
	if ipc_zone ~= tostring(zone) then return end
	
	if command == 'pos_update' then 
		if not arg1 or not arg2 then print('bad update') return end
		new_waypoint = { x = tonumber(arg1), y = tonumber(arg2) }
		self = windower.ffxi.get_mob_by_target('me')
		if not self then return end
		
		newest_distance = distance_to(new_waypoint, self)
		if newest_distance > 30 then return end
		
		-- Check if this waypoint is too close to the last waypoint in the list
		if waypoints[#waypoints] then
			local last_wp_distance = distance_to(new_waypoint, waypoints[#waypoints])
			if last_wp_distance < 0.5 then 
				--print('disregard wp - duplicate')
				return 
			end
		end
		
		if waypoints[1] and newest_distance < distance_to(waypoints[1], self) then -- New waypoint is closer
			--print('New waypoint closer, clearing old waypoints')
			waypoints = {}
			stop_moving()
		end
		--print('Adding waypoint: '..#waypoints + 1 ..' dist: '..string.format("%.2f", newest_distance))
		table.insert(waypoints, new_waypoint)
		
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
	
	elseif command == 'toggle' then
		if not arg1 or arg1 == string.lower(self.name) then 
			toggle_state() 
		end
		
	else
		change_state(command, arg1, arg2, arg3)
	end
end)

windower.register_event('status change',function (new, old)
	if old == 1 and new == 0 then  -- Exit combat state
		waypoints = {}
		moving = false
		windower.ffxi.run(false)
		if is_following then
			-- Wait a moment for the stop command to process before resuming follow
			for i = 0, 5, 1 do -- Try 5 times
				change_state('follow')
				coroutine.sleep(2)
				if current_state == 'follow' then break end
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
end)
	
startup = windower.register_event('load', 'login', function (new, old)
	if self then return end -- Already ran it
	for i = 0, 10, 1 do -- Don't continue until player is loaded in
		self = windower.ffxi.get_mob_by_target('me')
		if self then break end
		coroutine.sleep(1)
	end
	if not self then return end
	job = windower.ffxi.get_player().main_job
	subjob = windower.ffxi.get_player().sub_job
	zone = windower.ffxi.get_info().zone
	windower.send_command('input /autotarget off')
	change_state('stop')
	windower.send_ipc_message('multibox request_leader '..zone)
	coroutine.sleep(1)
	if not current_leader then update_leader(self.name) end
	windower.unregister_event(startup)
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
	zoning = false
end)
ctrl_down = false
windower.register_event('keyboard',function (dik, pressed, flags, blocked )
	if not windower.ffxi.get_info().logged_in then return end
	if not self then self = windower.ffxi.get_player() return end
	
	if flags == 4 then
		if not ctrl_down then ctrl_down = true end
	else
		if ctrl_down then ctrl_down = false end
	end
	--print('Keyboard event dik:'..dik..'  pressed:'..tostring(pressed)..'  flags:'..flags..'  blocked:'..tostring(blocked))
	if dik == 28 and pressed and ctrl_down then -- dik 28 = enter key, flag 4 = ctrl, not pressed = on key up
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
			casting = true 
			casting_timeout = 0
		end
	elseif id == 0x037 then -- Use item: Check for warp ring, vertical conflux, etc
        local packet = packets.parse('outgoing', data)
		if packet.Bag ~= 0 then -- Not in main inventory, 3 for temp items, 7/8 wardrobe
			change_state('stop')
		end
    end
end)

windower.register_event('incoming chunk', function(id, data)
	if id == 0x028 then -- Finish casting spell
		local packet = packets.parse('incoming', data)
		if packet.Actor ~= self.id then return end		
		
		if packet['Category'] == 4 then -- Casting Finish
			casting = false
			casting_timeout = 0
			casting_recovery = true
			coroutine.schedule(function() casting_recovery = false end, 1.5)
			
			local sp = res.spells:id(packet.Param)[packet.Param]
			if not sp then return end
			-- No idea what the requirements are, but only geo spells have 32
			if sp.requirements == 32 then pet_status() end
			
		elseif packet['Target 1 Action 1 Message'] == 0 and casting then
			casting = false
			casting_recovery = true
			coroutine.schedule(function() casting_recovery = false end, 1.5)
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