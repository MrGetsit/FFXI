_addon.author = 'Spikex'
_addon.version = '1.02'
_addon.name = 'Multibox'
_addon.commands = { 'multibox', 'mb' }

-- Changes: 
-- Changed request leader to just have the respond with their name
-- Fixed issue with leader not being assigned correctly
-- Added 'all' to passive toggle instead of making default
-- Fixed simulate_key_press so leader doesn't input as well causing double entry
-- Updated change zone so followers request leader
-- Lowered refresh rate of leader waypoint distance check to improve performace
-- Removed pet stuff
-- Removed unused requirements
-- Moved outgoing chunk casting check to incoming to avoid parsing outgoing chunks
-- Made variables local
-- Changed new waypoints to check distance against latest_waypoint instead of current position
-- Added more comments so I can follow what the fuck is going on
-- Added windower.has_focus() to startup as primary way to set leader on reload
-- Added mov_count and has_moved to check different movements in postrender to avoid running every frame
-- Saved the last two waypoints to calculate which direction to zone in to fix bug
-- Fixed casting interruption packet not being read correctly
-- Added stuck counter

require('sets')
require('strings')
require('tables')
res = require('resources')
packets = require('packets')

local current_state = 'stop' -- States: Zoning, Follow, Stop, Advance, Retreat, Reverse, Interact
local last_checked_distance = nil
local waypoint_spacing = 2 -- Distance between each created waypoint
local waypoints = {}
local last_waypoint = nil
local latest_waypoint = nil -- Most recent waypoint leader has sent, used for calculating zoning angle
local previous_waypoint = nil -- Second most recent waypoint leader has sent
local min_retreat_range = 12 
local max_retreat_range = 15
local is_following = false
local engage_distance = 2.5
local stop_engage = false
local current_leader = nil
local last_position = nil
local position_check_timer = 0
local casting_recovery = false
local is_leader = false
local moving = false
local self = nil
local interacting = false
local zone = nil -- Current zone leader is in
local zoning = false
local double_tap = false
local casting = false -- Don't start moving during a cast, Works but is messed up by sendtargets packet interception
local move_here = false
local check = 0 -- Increment to not check every frame
local mov_count = 0  -- Increment to not check every frame, for movement
local last_pos = nil -- See if player has moved this frame
local has_moved = false
local stuck_counter = 0
local casting_timeout = 0
local passive_mode = false
local key_down = false

function update_leader(new_leader, bypass) -- new_leader: character name
	-- Shouldn't be able to be called without self... but just in case
	if not self then print('Multibox: Unable to update leader without self.') return end
	local should_be_leader = (self.name == new_leader)
	
	-- Leader changed or double tap, stop autorun and clear waypoints
	if current_leader ~= new_leader or is_leader ~= should_be_leader or bypass then 
		previous_waypoint = nil
		latest_waypoint = nil
		stop_moving()
	
	-- Nothing has changed since last update, don't do anything
	else return end
	
	-- Set leader and send broadcast to followers to update
	if should_be_leader then
		zone = windower.ffxi.get_info().zone
		is_leader = true
		windower.send_ipc_message('multibox change_leader '..zone..' '..new_leader)
	else
		is_leader = false
	end
	
	current_leader = new_leader
end

function change_state(new_state, arg1, arg2, arg3)
	if new_state ~= 'zoning' then
		self = windower.ffxi.get_mob_by_target('me')
		if not self then print (new_state) return end
		if not zone then zone = windower.ffxi.get_info().zone end
		if not current_leader then print('cs missing leader') windower.send_ipc_message('multibox request_leader '..zone) end
		check = 0
	end
	
	if new_state == 'zoning' then
		if zoning then return end
		zoning = true
		
		if is_following then	
			if is_leader then
				-- Calculate final waypoint (waypoint_spacing) ahead of where the leader was moving towards
				if not last_waypoint or not previous_waypoint then print('Multibox: Zone error') return end
				local dx, dy = last_waypoint.x - previous_waypoint.x, last_waypoint.y - previous_waypoint.y
				local dist = math.sqrt(dx*dx + dy*dy)
				if dist == 0 then print('0 somehow') return end -- Both previous_waypoint and last_waypoint identical, somehow
				local dirx, diry = dx / dist, dy / dist
				local offsetx, offsety = dirx * waypoint_spacing, diry * waypoint_spacing
				windower.send_ipc_message('multibox pos_update '..zone..' '..last_waypoint.x + offsetx..' '..last_waypoint.y + offsety..' final')
			else
				-- Need to re-request leader info once we land in the new zone
				current_leader = nil 
				
				-- Get current position to check distance against
				local start_zone_pos = windower.ffxi.get_mob_by_target('me')
				if not windower.ffxi.get_info().logged_in or not start_zone_pos then return end
				
				-- Check if we either started zoning (lost self), or ran further than the max distance to try and run
				for i = 0, 10, 1 do
					local cur_pos = windower.ffxi.get_mob_by_target('me')
					if not cur_pos or distance_to(start_zone_pos, cur_pos) < 6 then	return end
					coroutine.sleep(0.5)
				end
				
				-- Never actually zoned, stop
				if windower.ffxi.get_mob_by_target('me') then 
					zoning = false
					change_state('stop')
				end
			end 
			stop_moving()
			is_following = false
			last_waypoint = nil		
		end		
		
	elseif new_state == 'follow' then
		is_following = true
		engage()
		waypoints = {}
		
		if interacting then 
			simulate_key_press('escape')
			print('stop interact through follow')
			interacting = false
		end
		
		if is_leader then
			last_waypoint = nil
			if not arg1 then
				if double_tap and not wait_for_seconds then
					windower.add_to_chat(160, 'Move followers to current position.')
					update_leader(self.name, true)
					windower.send_ipc_message('multibox follow '..zone..' '..self.x..' '..self.y..' true')
					wait_for_seconds = true
					coroutine.schedule(function() wait_for_seconds = false end, 1)
				else
					double_tap = true
					coroutine.schedule(function() double_tap = false end, 2)
					windower.send_ipc_message('multibox follow '..zone..' '..self.x..' '..self.y)
				end
			end
		else
			if self.status == 1 then windower.send_command('input /attack off') end -- Disengage from combat
			if windower.ffxi.get_player().target_locked then windower.send_command('input /lockon') end
			if moving then stop_moving() end 
			if not current_leader then print('follow miss leader') windower.send_ipc_message('multibox request_leader '..zone) return end
			turn_to_target(windower.ffxi.get_mob_by_name(current_leader))
			
			if arg1 and arg2 then -- Getting new follow order from leader
				local new_waypoint = { x = tonumber(arg1), y = tonumber(arg2) }
				if distance_to(new_waypoint, self) > 40 then return end
				if arg3 then -- Double tap
					--print('Double tap follow - clearing waypoints')
					if casting then casting = false print('dt finish casting') end
					move_here = true 
				end
				waypoints = {}
				latest_waypoint = nil
				table.insert(waypoints, new_waypoint)
			end
		end
	
	elseif new_state == 'stop' then
		engage()
		stop_moving()
		is_following = false
		
	elseif new_state == 'advance' then
		engage()
		local target
		if is_leader then
			target = windower.ffxi.get_mob_by_target('t')
			if not target then print('no target') return end
			windower.send_ipc_message('multibox advance '..zone..' '..target.id)
		else
			stop_moving()
			if arg1 then 
				target = windower.ffxi.get_mob_by_id(arg1)
				turn_to_target(target)
			else return end
		end
		if passive_mode then return end
		engage(target) 
		
	elseif new_state == 'retreat' then
		engage()
		
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
		engage()
		stop_moving()
		
	elseif new_state == 'interact' then
		print('interacting')
		interacting = true
	end
	
	current_state = new_state
end

function interact_with_target(target)
	if not target then print ('No target to interact with') return end
	trying_to_interact = true
	event_found = false
	npc_reaction = false
	
	local success = false
	
	print('Attempting to interact with '..target.name)
	for i = 0, 5, 1 do -- Send interactions until we get some kind of response
		if interacting or event_found or npc_reaction then success = true break end
		--print('Interact attempt: '..i)
		packets.inject(packets.new('outgoing', 0x01A, {
			['Target'] = target.id,
			['Target Index'] = target.index,
			['Category'] = 0,
		}))
		coroutine.sleep(1)
	end
	if success then
		change_state('interact')
	else
		if target then print('Couldn\'t interact with '..target.name) end
	end
	trying_to_interact = false
end

function engage(new_target)
	-- Sending engage command without target will stop any current engagement
	if not new_target then stop_engage = true return end
	engage_call = (engage_call or 0) + 1
	local current_call = engage_call
	stop_engage = false
	
	for i = 0, 5, 1 do
		-- Exit out if any new engagment has been started or told to stop
		if stop_engage or engage_call ~= current_call then return end
		
		-- Make sure player is capable of engaging
		self = windower.ffxi.get_mob_by_target('me')
		if not self or self.hpp < 1 then break end
		
		-- Check if currently engaged to correct target
		local cur_target = windower.ffxi.get_mob_by_target('t')
		if cur_target and cur_target.id == new_target.id and self.status == 1 then return end
		
		-- See if target is still nearby
		local target_to_find = windower.ffxi.get_mob_by_id(new_target.id)
		if not target_to_find then print('Multibox: Unable to find target.') return end
		
		-- Set engagement category type, update if switching targets
		local attack_category = 0x02
		if self.status == 1 then attack_category = 0x0F end
		
		-- Send engagement packet
		local attack = packets.new('outgoing', 0x01A, {
			["Target"] = target_to_find.id,
			["Target Index"] = target_to_find.index,
			["Category"] = attack_category
			})
		packets.inject(attack)
		coroutine.sleep(2)
	end
	
	print('Multibox: Unable to engage.')
	change_state('stop')
end

function send_new_waypoint(new_position)
	previous_waypoint = latest_waypoint
	latest_waypoint = new_position
	windower.send_ipc_message('multibox pos_update '..zone..' '..new_position.x..' '..new_position.y)
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
	local new_distance = math.sqrt((point1.x - point2.x)^2 + (point1.y - point2.y)^2)
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
	
	local turn_direction = (math.atan2(tar_pos.x - self.x, tar_pos.y - self.y)) - 1.5708
	if invert then turn_direction = turn_direction + 3.14 end
	
	windower.ffxi.turn(turn_direction)
end

function simulate_key_press (key_to_press)
	if is_leader then 
		--print('Sending ['..key_to_press..'] to others')
		windower.send_ipc_message('multibox key_press '..zone..' '..key_to_press) 
	else
		key_down = true
		windower.send_command('setkey '..key_to_press..' down')
		coroutine.sleep(0.5)
		windower.send_command('setkey '..key_to_press..' up')
		key_down = false
	end
end

function toggle_passive()
	passive_mode = not passive_mode
	windower.add_to_chat(160, 'Passive Mode: '..tostring(passive_mode))
end

windower.register_event('addon command', function(action, arg1, arg2)
	if not windower.ffxi.get_info().logged_in then return end
	if not self then self = windower.ffxi.get_player() end
	if not current_leader then print('addon cmd miss leader') windower.send_ipc_message('multibox request_leader '..zone) end
	
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
		
	elseif action == 'passive' or action == 'p' then
		if arg1 then
			if arg1 == 'all' then
				windower.send_ipc_message('multibox passive '..zone)
				toggle_passive()
			else
				windower.add_to_chat(160, 'Multibox: Changing '..arg1..' to Passive')
				windower.send_ipc_message('multibox passive '..zone..' '..string.lower(arg1))
			end
		else
			toggle_passive()
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
		windower.add_to_chat(160, 'Multibox commands: //mb passive character or //mb p character: Disable/Enable passive mode for character')
	end
end)

windower.register_event('postrender', function()
	-- Check counter to avoid running some actions on every frame
	if check >= 60 then check = 0 else check = check + 1 end
	
	-- See if player is currently loaded, update position counter if it is or switch to zoning otherwise
	self = windower.ffxi.get_mob_by_target('me')
	if self then 
		-- Use mov_count and has_moved for movement based checks to avoid running them on every frame
		if not last_pos then last_pos = { x = self.x, y = self.y } end	
		if self.x ~= last_pos.x or self.y ~= last_pos.y then
			if mov_count < 20 then mov_count = mov_count + 1 else mov_count = 0 end
			has_moved = true
			if interacting then print('mov not interacting') interacting = false end -- Double check if stuck interacting without npc release
			last_pos = { x = self.x, y = self.y }
		end
	else if not zoning then change_state('zoning') end return end
	if self.hpp == 0 and current_state ~= 'stop' then change_state('stop') return end -- Dead
	
	if casting then
		casting_timeout = casting_timeout + 1
		if casting_timeout > 600 then 
			print('Casting timeout, resetting')
			casting = false
			casting_timeout = 0
		end
	end
	if current_state == 'follow' then
		if not current_leader then print('No leader to follow') change_state('stop') return end
		
		if is_leader then 
			if last_waypoint then
				-- Avoid running distance calculation on every frame
				if mov_count == 0 then
					-- If leader has moved far enough from last waypoint, create new waypoint
					local distance = distance_to(last_waypoint, self)
					if distance > waypoint_spacing then 
						if distance < 20 then -- Had it at 5 before, seemed to occassionally trigger within server update
							--print('Creating new waypoint. x'..self.x..' y'..self.y)
							last_waypoint = { x = self.x, y = self.y }
							send_new_waypoint(last_waypoint) 
						else -- Leader moved too far in a single update
							print('Teleported, stopping '..distance)
							windower.send_ipc_message('multibox stop '..zone)
							change_state('stop')
						end
					end
				end
			else
				-- If there aren't any waypoints yet, create one right away
				last_waypoint = { x = self.x, y = self.y }
				send_new_waypoint(last_waypoint)
			end
		else -- Move follower 
			local player_current = windower.ffxi.get_player()
				
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
			
			-- Stop moving if follower is casting or in combat
			if player_current.status == 1 or casting or casting_recovery then
				if moving then
					windower.ffxi.run(false)
					moving = false
				end
			return end
			
			-- No more waypoints, stop
			if not waypoints[1] then return end
			
			-- Remove current waypoint if we are close enough to it
			local distance_to_next_waypoint = distance_to(waypoints[1], self)			
			if not moving and distance_to_next_waypoint < 0.8 then
				table.remove(waypoints, 1)
				if not waypoints[1] then return end
				distance_to_next_waypoint = distance_to(waypoints[1], self)
			end
			
			if moving then
				-- Arrived at next waypoint
				if (move_here and distance_to_next_waypoint < 0.2) or -- Stop on position
				(not move_here and distance_to_next_waypoint < 0.8) then -- Close enough
					stuck_counter = 0
					move_here = false
					table.remove(waypoints, 1)
					last_checked_distance = nil
					
					-- See if there is another waypoint to move towards
					if waypoints[1] then
						local next_distance = distance_to(waypoints[1], self)						
						if next_distance > 0.5 then
							last_checked_distance = next_distance
							windower.ffxi.run(get_direction(waypoints[1]))
							moving = true
						else
							moving = false
						end
						
					-- Stopping at final waypoint
					else stop_moving() end
				
				-- See if we are still headed the correct direction by checking if we further away than last time we looked
				elseif last_checked_distance and last_checked_distance < distance_to_next_waypoint then
					-- Running the wrong way or stuck, but still close enough to next waypoint. Stopping will restart it
					if distance_to_next_waypoint < 20 and stuck_counter < 10 then 
						stuck_counter = stuck_counter + 1
						print('wrong way: '..tostring(stuck_counter))
						windower.ffxi.run(false)
						moving = false
						last_checked_distance = nil
						
					-- The next waypoint is too far to pick up the path, stop entirely
					else 
						windower.send_command('input /party Unable to reach next waypoint, stopping')
						change_state('stop') 
					end
				
				-- Update last_checked_distance to know if we get turned around
				elseif mov_count == 5 or mov_count == 15 then
					if not last_checked_distance or distance_to_next_waypoint < last_checked_distance then
						last_checked_distance = distance_to_next_waypoint
					end
				end
			elseif not casting or move_here then
				-- Start moving to next waypoint
				if distance_to_next_waypoint > 0.5 then  -- If we're far enough from the waypoint
					last_checked_distance = distance_to_next_waypoint
					windower.ffxi.run(get_direction(waypoints[1]))
					moving = true
					
				elseif check == 50 then -- Periodic check
					-- Out of combat and should be following, but we are locked on to something
					if player_current.status == 0 and player_current.target_locked then 
						print('should unlock')
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
			if check == 45 then -- Lockon to prevent running wrong direction
				if not windower.ffxi.get_player().target_locked then windower.send_command('input /lockon') end
			end
			if distance > 3 and not is_leader then
				moving = true
				windower.ffxi.run(get_direction(t))
			elseif check == 15 then
				turn_to_target(t)
			end
		end
		
	elseif current_state == 'reverse' then
		if is_leader then return end
		if check == 30 then
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
	if has_moved then has_moved = false end
end)

windower.register_event('ipc message', function (msg)
    if not windower.ffxi.get_info().logged_in or not self then return end
	zone = windower.ffxi.get_info().zone
	
	local ipc_message = msg:split(' ')
	if ipc_message[1] ~= 'multibox' then return end
	local command = ipc_message[2]
	local ipc_zone = ipc_message[3]
	local arg1 = ipc_message[4]
	local arg2 = ipc_message[5]
	local arg3 = ipc_message[6]
	
	if ipc_zone ~= tostring(zone) then return end
	
	if command == 'pos_update' then 
		if not arg1 or not arg2 then print('bad update') return end
		local new_waypoint = { x = tonumber(arg1), y = tonumber(arg2) }
		self = windower.ffxi.get_mob_by_target('me')
		if not self then return end
		
		-- Check the new waypoint is close enough to a previous waypoint (Didn't teleport)
		if not latest_waypoint then print('latest missing') end
		local reference = latest_waypoint or self
		if distance_to(new_waypoint, reference) > 30 then 
			print('next wp too far')
			change_state('stop')
			return 
		end
		
		-- Check if this waypoint is too close to the last waypoint in the list (Duplicate)
		if waypoints[#waypoints] then
			local last_wp_distance = distance_to(new_waypoint, waypoints[#waypoints])
			if last_wp_distance < 0.5 then 
				print('removing duplicate wp')
				return 
			end
		end
		
		-- New waypoint is closer, clear list and start from here (Shorter path)
		if waypoints[1] and distance_to(new_waypoint, self) < distance_to(waypoints[1], self) then 
			print('closer path avaliable')
			waypoints = {}
			stop_moving()
		end
		table.insert(waypoints, new_waypoint)
		if arg3 == 'final' then move_here = true end
		latest_waypoint = new_waypoint
		
    elseif command == 'change_leader' then 
		if not current_leader or current_leader ~= arg1 then update_leader(arg1) end
		
    elseif command == 'request_leader' then 
		if is_leader then windower.send_ipc_message('multibox change_leader '..zone..' '..self.name) end
		
	elseif command == 'key_press' then 
		simulate_key_press(arg1)
		
	elseif command == 'interact' then
		if arg1 and not trying_to_interact then interact_with_target(windower.ffxi.get_mob_by_id(arg1)) return end
	
	elseif command == 'passive' then
		if not arg1 or arg1 == string.lower(self.name) then 
			toggle_passive()
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
			change_state('follow', true)
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
		if is_following then 
			change_state('follow')
		else 
			change_state('stop') 
		end
	end
end)

windower.register_event('Gain focus',function (new, old)
	-- Make sure self is up to date
	self = windower.ffxi.get_mob_by_target('me')
	while not self do
		coroutine.sleep(2)
		self = windower.ffxi.get_mob_by_target('me')
	end
	
	-- If switching to a follower, promote follower to leader. Otherwise do nothing as leader is unchanged
	if current_leader ~= self.name then update_leader(self.name) end
end)

startup = windower.register_event('load', 'login', function (new, old)
	if self then return end -- Already ran it
	while not self do -- Don't continue until player is loaded in
		self = windower.ffxi.get_mob_by_target('me')
		if self then break end
		coroutine.sleep(1)
	end
	zone = windower.ffxi.get_info().zone
	windower.send_command('input /autotarget off')
	
	-- Set leader as focus with slight delay to give others time to load as well
	if windower.has_focus() then 
		coroutine.schedule(function() update_leader(self.name) end, 1)			
	else
		coroutine.schedule(function() 
		if not current_leader then
			windower.send_ipc_message('multibox request_leader '..zone)
		end end, 2)
	end
	coroutine.schedule(function() change_state('stop') end, 3)			
	windower.unregister_event(startup)
end)

windower.register_event('zone change',function (new, old)
	zone = new
	latest_waypoint = nil
	
	-- Make sure self is up to date
	self = windower.ffxi.get_mob_by_target('me')
	while not self do
		self = windower.ffxi.get_mob_by_target('me')
		coroutine.sleep(1)
	end	
	zoning = false
	if self.name == current_leader then return end
	current_leader = nil
	
	-- Double check followers aren't moving
	for i = 1, 5 do
		if windower.ffxi.get_player().autorun then 
			stop_moving()
			coroutine.sleep(0.5)
		else break end
	end
	
	-- Have followers request leader
	for i = 1, 5 do
		if current_leader then break end
		coroutine.sleep(2)
		windower.send_ipc_message('multibox request_leader '..zone)
	end
end)

windower.register_event('keyboard',function (dik, pressed, flags, blocked )
	if not windower.ffxi.get_info().logged_in then return end
	if not self then self = windower.ffxi.get_player() return end
	if not current_leader then 
		if windower.has_focus() then update_leader(self.name)
		else windower.send_ipc_message('multibox request_leader '..zone) end 
	end -- Backup if startup fails to get leader
	--print('Keyboard event dik:'..dik..'  pressed:'..tostring(pressed)..'  flags:'..flags..'  blocked:'..tostring(blocked))
	
	-- Only check if ctrl key (dik 29 or flags 4) is held down
	if flags ~= 4 or pressed then return end
	
	if dik == 28 then -- dik 28 = enter key
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
	elseif dik == 200 then -- dik 200 = up key
		simulate_key_press('up')
	elseif dik == 208 then -- dik 208 = down key
		simulate_key_press('down')
	elseif dik == 1 then -- dik 1 = esc key
		simulate_key_press('escape')
	end
end)

interaction_ids = S{
	0x032, -- 50 NPC Interaction 1
	0x034, -- 52 NPC Interaction 2
	0x036, -- 54 NPC Chat
	0x03E, -- 62 Open Buy/Sell
	0x04C, -- 76 NPC Auction House Menu
}
windower.register_event('incoming chunk', function(id, data)
	if trying_to_interact and not npc_reaction and interaction_ids:contains(id) then
		npc_reaction = true
		
	elseif id == 0x028 then -- Player action
		local packet = packets.parse('incoming', data)
		if packet.Actor ~= self.id then return end
		
		if packet['Target 1 Action 1 Message'] == 0 and casting then -- Interrupted casting
			casting = false
			casting_recovery = true
			coroutine.schedule(function() casting_recovery = false end, 1.5)
			
		elseif packet['Category'] == 8 then -- Started casting
			casting = true 
			casting_timeout = 0
			
		elseif packet['Category'] == 4 then -- Finished casting
			casting = false
			casting_timeout = 0
			casting_recovery = true
			coroutine.schedule(function() casting_recovery = false end, 1.5)		
		end
	elseif id == 0x00B and not zoning then -- Started zoning
		change_state('zoning')
		
	elseif id == 0x034 and not zone_teleport then -- Started zoning through teleport
		windower.send_ipc_message('multibox stop '..zone)
		
	elseif id == 0x052 and interacting then -- NPC Release
		coroutine.schedule(function()
			if current_state ~= 'interact' then
				print('end interact')
				interacting = false
			end
		end, 0.5)
	end
end)