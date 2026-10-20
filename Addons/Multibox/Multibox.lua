_addon.author = 'Spikex'
_addon.version = '1.05'
_addon.name = 'Multibox'
_addon.commands = { 'multibox', 'mb' }

-- Changes: 
-- Stopped resetting leader after zoning as no data is saved other than the name, nothing to refresh
-- Got rid of spawn_type check on interaction, just always interact when commanded
-- Changed following logic to better handle teleporting around
-- Force leader update on double tap
-- Cleaned up follow in postrender again
-- Fixed spellcast interrupt counting as a new spell starting

require('sets')
require('strings')
require('tables')
res = require('resources')
packets = require('packets')

local self = nil
local current_leader = nil
local is_leader = false
local current_state = 'stop' -- States: Zoning, Follow, Stop, Advance, Retreat, Reverse, Interact
local passive_mode = false
local min_retreat_range = 12 
local max_retreat_range = 15
local waypoint_spacing = 1.2 -- Distance between each created waypoint
local waypoints = {}
local last_waypoint = nil -- Used by leader to see how far they have moved, or to calculate zoning angle
local previous_waypoint = nil -- Second most recent waypoint leader has sent for zoning calculation
local last_checked_distance = nil -- Used to check if followers are moving correct direction
local last_checked_position = nil -- Used to check if followers get stuck
local last_pos = nil -- See if player has moved this frame
local move_here = false
local moving = false
local has_moved = false
local is_following = false
local stuck_counter = 0
local engage_distance = 2.5
local engage_call = 0
local interacting = false
local zone = nil -- Current zone leader is in
local zoning = false
local double_tap = false
local casting = false -- Don't start moving during a cast, Works but is messed up by sendtargets packet interception
local casting_timeout = 0
local check = 0 -- Increment to not check every frame
local points_too_far = 0
local party_slot = nil
local party_ids = {}

function change_leader(new_leader) -- new_leader: character name
	if not self then print('Multibox: Unable to update leader without self.') return end	
	queued_waypoint = nil
	last_waypoint = nil
	stop_moving()
	if self.name == new_leader then
		zone = windower.ffxi.get_info().zone
		is_leader = true
		windower.send_ipc_message('multibox change_leader '..zone..' '..new_leader)
	else
		is_leader = false
	end
	
	update_party_slot()
	current_leader = new_leader
	--print(current_state.. ' ' .. current_leader)
end

function update_party_slot()
    local party = windower.ffxi.get_party()
    local me = windower.ffxi.get_player().id
    local ids = {}

    for i = 0, (party.party1_count or 1) - 1 do
        local member = party['p' .. i]
        if member and member.mob then
            ids[#ids + 1] = member.mob.id
        end
    end

    table.sort(ids)
    party_ids = ids

    party_slot = nil
    for slot, id in ipairs(ids) do
        if id == me then
            party_slot = slot
            break
        end
    end
	--print('Party Slot: '..party_slot)
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
				if not last_waypoint or not previous_waypoint then return end
				local dx, dy = last_waypoint.x - previous_waypoint.x, last_waypoint.y - previous_waypoint.y
				local dist = math.sqrt(dx*dx + dy*dy)
				if dist == 0 then print('0 somehow') return end -- Both previous_waypoint and last_waypoint identical, somehow
				local dirx, diry = dx / dist, dy / dist
				local offsetx, offsety = dirx * waypoint_spacing, diry * waypoint_spacing
				windower.send_ipc_message('multibox pos_update '..zone..' '..last_waypoint.x + offsetx..' '..last_waypoint.y + offsety..' final')
			else
				-- Need to re-request leader info once we land in the new zone
				-- current_leader = nil 
				
				-- Get current position to check distance against
				local start_zone_pos = windower.ffxi.get_mob_by_target('me')
				if not windower.ffxi.get_info().logged_in or not start_zone_pos then return end
				
				-- Check if we either started zoning (lost self), or ran further than the max distance to try and run
				for i = 0, 10, 1 do
					local cur_pos = windower.ffxi.get_mob_by_target('me')
					if not cur_pos or distance_to(start_zone_pos, cur_pos) > 6 then	return end
					coroutine.sleep(0.5)
				end
				
				-- Never actually zoned, stop
				if windower.ffxi.get_mob_by_target('me') then 
					zoning = false
					print('Unable to zone')
					change_state('stop')
				end
			end 
			stop_moving()
			previous_waypoint = nil
			last_waypoint = nil
		end
		
	elseif new_state == 'follow' then
		is_following = true
		engage()
		waypoints = {}
		
		if interacting then 
			simulate_key_press('escape')
			interacting = false
		end
		
		if is_leader then
			last_waypoint = nil
			if not arg1 then
				if double_tap and not wait_for_seconds then
					windower.add_to_chat(160, 'Move followers to current position.')
					change_leader(self.name)
					windower.send_ipc_message('multibox follow '..zone..' '..self.x..' '..self.y..' true')
					wait_for_seconds = true
					coroutine.schedule(function() wait_for_seconds = false end, 1)
				else
					double_tap = true
					coroutine.schedule(function() double_tap = false end, 2)
					windower.send_ipc_message('multibox follow '..zone)
				end
			end
		else
			if self.status == 1 then print('disengagea') windower.send_command('input /attack off') end -- Disengage from combat
			if windower.ffxi.get_player().target_locked then print('unlocka') windower.send_command('input /lockon') end
			if moving then stop_moving() end 
			
			-- Force leader update on double tap
			if arg1 then windower.send_ipc_message('multibox request_leader '..zone) end
			while not current_leader do
				windower.send_ipc_message('multibox request_leader '..zone)
				coroutine.sleep(1)
			end
			local leader_ref = windower.ffxi.get_mob_by_name(current_leader)
			turn_to_target(leader_ref)
			
			if arg1 and not arg2 then -- Resuming follow after combat	
				table.insert(waypoints, {x = leader_ref.x, y = leader_ref.y})
			elseif arg1 and arg2 then -- Getting new follow order from leader
				local new_waypoint = { x = tonumber(arg1), y = tonumber(arg2) }
				if distance_to(new_waypoint, self) > 40 then return end
				if arg3 then -- Double tap
					print('Double tap follow - clearing waypoints')
					if casting then casting = false print('dt finish casting') end
					stop_moving()
					move_here = true 
				end
				waypoints = {}
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
			if not target then return end
			windower.send_ipc_message('multibox advance '..zone..' '..target.id)
			if self.status == 1 then current_state = new_state return end -- Already engaged with target, don't need to use function
		else
			stop_moving()
			if arg1 then 
				target = windower.ffxi.get_mob_by_id(arg1)
				turn_to_target(target)
			else return end
		end
		engage(target.id) 
		
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
				change_state('reverse')
			end
		else 
			stop_moving()
		end
		
	elseif new_state == 'reverse' then
		if windower.ffxi.get_player().target_locked then print('unlockb') windower.send_command('input /lockon') end
		local target = windower.ffxi.get_mob_by_target('t')
		if target then turn_to_target(target, true) else return end
		engage()
		stop_moving()
		
	elseif new_state == 'interact' then
		stop_moving()
		interacting = true
	end
	
	current_state = new_state
end

function interact_with_target(target)
	if trying_to_interact then print('already trying to interact') return end
	if not target then print ('No target to interact with') return end
	trying_to_interact = true
	event_found = false
	npc_reaction = false
	
	local success = false
	
	print('Attempting to interact with '..target.name)
	for i = 0, 5, 1 do -- Send interactions until we get some kind of response
		if npc_reaction then trying_to_interact = false return end
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
		change_state('interact')
	else
		if target then print('Couldn\'t interact with '..target.name) end
	end
	trying_to_interact = false
end

function engage(new_target)
	engage_call = engage_call + 1
	-- Sending engage command without target will stop any current engagement
	if not new_target or passive_mode then return end
	local current_call = engage_call
	
	for i = 0, 5, 1 do
		-- Exit out if any new engagment has been started or told to stop
		if engage_call ~= current_call then return end
		
		-- Make sure player is capable of engaging
		self = windower.ffxi.get_mob_by_target('me')
		if not self or self.hpp < 1 then break end
		
		-- Check if currently engaged to correct target
		local cur_target = windower.ffxi.get_mob_by_target('t')
		if cur_target and cur_target.id == new_target and self.status == 1 then return end
		
		-- See if target is still nearby
		local target_to_find = windower.ffxi.get_mob_by_id(new_target)
		if not target_to_find then print('Multibox: Unable to find target.') return end
		turn_to_target(target_to_find)
		
		-- Set engagement category type, update if switching targets
		local attack_category = 0x02
		if not is_leader and self.status == 1 then print('switch packet') attack_category = 0x0F end
		
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
	previous_waypoint = last_waypoint
	last_waypoint = new_position
	if queued_waypoint then windower.send_ipc_message('multibox pos_update '..zone..' '..queued_waypoint.x..' '..queued_waypoint.y) end
	queued_waypoint = new_position
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

function stop_moving(keep_waypoints)
	if not keep_waypoints then waypoints = {} end
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
		--print('Pressing ['..key_to_press..']')
		windower.send_command('setkey '..key_to_press..' down')
		coroutine.sleep(0.5)
		windower.send_command('setkey '..key_to_press..' up')
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
		
	elseif action == 'reverse' then
		change_state('reverse')
		
	elseif action == 'assault' then
		local mobs = windower.ffxi.get_mob_array()
		local ids = {}

		for _, mob in pairs(mobs) do
			if mob.valid_target
			   and mob.is_npc
			   and mob.spawn_type == 16      -- monsters only
			   and mob.hpp > 0
			   and mob.distance <= 225 then  -- 15 yalms squared
				ids[#ids + 1] = mob.id
				if #ids >= 5 then break end
			end
		end

		if #ids > 0 then windower.send_ipc_message('multibox assault ' .. zone .. ' ' .. table.concat(ids, '_')) end
		local my_target = windower.ffxi.get_mob_by_target('t')
		if my_target then
			engage(my_target.id)
		else
			engage(ids[party_slot])
		end
		
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
		windower.add_to_chat(160, 'Multibox commands: //mb advance : Engage and approach target')
		windower.add_to_chat(160, 'Multibox commands: //mb assault : Party attacks different targets')
		windower.add_to_chat(160, 'Multibox commands: //mb retreat : Characters turn away, double press to move away from target until min_retreat_range')
		windower.add_to_chat(160, 'Multibox commands: //mb passive character or //mb p character: Disable/Enable passive mode for character')
	end
end)

windower.register_event('postrender', function()
	if zoning then return end
	-- Check counter to avoid running some actions on every frame
	if check >= 60 then check = 0 else check = check + 1 end
	
	-- See if player is currently loaded, update position counter if it is or switch to zoning otherwise
	self = windower.ffxi.get_mob_by_target('me')
	if self then 
		-- Use mov_count and has_moved for movement based checks to avoid running them on every frame
		if not last_pos then last_pos = { x = self.x, y = self.y } end	
		if self.x ~= last_pos.x or self.y ~= last_pos.y then
			has_moved = true
			if interacting then interacting = false end -- Double check if stuck interacting without npc release
			last_pos = { x = self.x, y = self.y }
		end
	else if not zoning then print('Multibox: Started zoning') change_state('zoning') end return end
	if self.hpp == 0 and current_state ~= 'stop' then print('Multibox: Dead') change_state('stop') return end
	
	if casting then
		if moving then stop_moving(true) end
		casting_timeout = casting_timeout + 1
		if casting_timeout > 600 then 
			print('Casting timeout, resetting')
			casting = false
			casting_timeout = 0
		end
	end
	
	if current_state == 'follow' then
		if not current_leader then print('follow miss leader') windower.send_ipc_message('multibox request_leader '..zone) end
		
		if is_leader then 
			if last_waypoint then
				-- Avoid running distance calculation on every frame
				if not has_moved then return end
				-- If leader has moved far enough from last waypoint, create new waypoint
				local distance = distance_to(last_waypoint, self)
				if distance > waypoint_spacing then 
					send_new_waypoint(self) 
				end
			else
				-- If there aren't any waypoints yet, create one right away
				send_new_waypoint(self) 
			end
		else
			-- Stop casting if leader is too far away, otherwise return while casting
			if casting then
				if distance_to(windower.ffxi.get_mob_by_name(current_leader), self) > 5 then
					print('Multibox: Leader too far, stopping cast.')
					casting = false
				else return end
			end
			
			local player_current = windower.ffxi.get_player()
			local distance_to_next_waypoint = waypoints[1] and distance_to(waypoints[1], self)
			
			if moving then
				-- Moving without a waypoint to move towards
				if not waypoints[1] then stop_moving() return end
				if not has_moved then print('stop') stop_moving(true) end
				-- Arrived at next waypoint
				if (move_here and distance_to_next_waypoint < 0.1) or -- Stop on position
				(not move_here and distance_to_next_waypoint < 0.5) then -- Close enough
					stuck_counter = 0
					move_here = false
					table.remove(waypoints, 1)
					last_checked_distance = nil
					
					-- See if there is another waypoint to move towards
					while waypoints[1] do
						local next_distance = distance_to(waypoints[1], self)
						if next_distance > 0.5 then
							last_checked_distance = next_distance
							windower.ffxi.run(get_direction(waypoints[1]))
							moving = true
							return
						else -- Next waypoint is too close somehow, remove it and check the next one
							print('removing wp')
							table.remove(waypoints, 1)
						end
					end	
					-- There are no more waypoints, stop moving
					stop_moving(true)
				
				-- See if we are still headed the correct direction by checking if we further away than last time we looked
				elseif last_checked_distance and last_checked_distance < distance_to_next_waypoint then
					if stuck_counter < 20 then 
						stuck_counter = stuck_counter + 1
						-- Running the wrong way or stuck, but still close enough to next waypoint
						if distance_to_next_waypoint < 30 then
							stop_moving(true)
							last_checked_distance = nil
						
						-- The next waypoint is too far to normally receive
						else
							print('teleported')
							stop_moving()
						end
					-- Path is blocked by something
					else 
						windower.send_command('input /tell '..current_leader..' Multibox: I am stuck on something.')
						stuck_counter = -1000
						stop_moving()
					end				
				-- Update last_checked_distance to know if we get turned around
				elseif has_moved then
					if not last_checked_distance or distance_to_next_waypoint < last_checked_distance then
						last_checked_distance = distance_to_next_waypoint
					end				
				-- Don't check every frame as most frames the player hasn't moved yet even while running
				elseif check == 0 or check == 20 or check == 40 then
					-- Stop moving if follower is in combat
					if player_current.status == 1 then stop_moving(true) return end					
					-- Check followers position to confirm if they are actually moving
					if last_checked_position and math.sqrt((self.x - last_checked_position.x)^2 + (self.y - last_checked_position.y)^2) < 0.05 then
						print('Multibox: Movement stuck detected, resetting')
						stop_moving(true)
					end
					last_checked_position = { x = self.x, y = self.y }
				end
			else	
				-- Somehow moved when should have been not moving
				if has_moved then stop_moving(true) end
				if distance_to_next_waypoint then
					-- Remove current waypoint if we are stopped close enough to it
					if distance_to_next_waypoint < 0.8 then
						table.remove(waypoints, 1)
						if not waypoints[1] then return end
						distance_to_next_waypoint = distance_to(waypoints[1], self)
					end
					-- Start moving to next waypoint
					if distance_to_next_waypoint < 30 then
						if not move_here and table.length(waypoints) < 2 then return end
						last_checked_distance = distance_to_next_waypoint
						windower.ffxi.run(get_direction(waypoints[1]))
						moving = true
					end					
				-- Out of combat and should be following, but we are locked on to something
				elseif check == 50 then
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
				print('not following')
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
				if not windower.ffxi.get_player().target_locked then print('locka') windower.send_command('input /lockon') end
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
			if windower.ffxi.get_player().target_locked then print('unlockd') windower.send_command('input /lockon') end -- Unlock
			local t = windower.ffxi.get_mob_by_target('t')
			if t then
				turn_to_target(t, true)
			elseif is_following then
				change_state('follow')
			else
				print('reverse stop')
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
				print('retreat stop')
				change_state('stop')
			end	
		return end
		local distance = distance_to(t, self)
		if distance < min_retreat_range and not moving then -- Too close, move back	
			if windower.ffxi.get_player().target_locked then print('unlocke') windower.send_command('input /lockon') end -- Unlock
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
	has_moved = false
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
	
	if command == 'change_leader' then
		--print('change leader command: '..arg1)
		if not current_leader or current_leader ~= arg1 then change_leader(arg1) end return
		
	elseif command == 'request_leader' then 
		if is_leader then windower.send_ipc_message('multibox change_leader '..zone..' '..self.name) end return
		
	elseif command == 'party_update' then 
		update_party_slot()
	return end
	
	-- Follower only commands
	if is_leader then return end
	
	if command == 'pos_update' then
		if not arg1 or not arg2 then print('bad update') return end
		local new_waypoint = { x = tonumber(arg1), y = tonumber(arg2) }
		self = windower.ffxi.get_mob_by_target('me')
		if not self then return end
		local wp_too_far = false
		
		-- Check new waypoint is valid
		if waypoints[#waypoints] then
			local last_wp_distance = distance_to(new_waypoint, waypoints[#waypoints])
			
			-- Check if this waypoint is too close to the last waypoint in the list (Duplicate) or too far to accept
			if last_wp_distance < 0.6 then 
				return 
			elseif last_wp_distance > 30 then
				wp_too_far = true
			end
			
		else-- There are no current waypoints, but the new waypoint is too far away			
			if distance_to(new_waypoint, self) > 30 then
				stop_moving()
				wp_too_far = true
			end
		end
		
		if wp_too_far then
			-- Send a stuck message if getting several waypoints in a row out of range
			if points_too_far >= 0 then
				points_too_far = points_too_far + 1
				if points_too_far == 3 then
					windower.send_command('input /tell '..current_leader..' Multibox: Next waypoint too far.')
					points_too_far = -1000
					coroutine.schedule(function() 
						if points_too_far < 0 then print('Waypoints timeout') change_state('stop') end
						points_too_far = 0
					end, 30)
				end
			end
		else points_too_far = 0 end
		
		-- New waypoint is closer, clear list and start from here (Shorter path)
		if waypoints[1] and distance_to(new_waypoint, self) < distance_to(new_waypoint, waypoints[1]) then
			waypoints = {}
		end
		
		table.insert(waypoints, new_waypoint)
		if arg3 == 'final' then move_here = true end
		
	elseif command == 'key_press' then 
		simulate_key_press(arg1)
		
	elseif command == 'interact' and arg1 then
		interact_with_target(windower.ffxi.get_mob_by_id(arg1))
	
	elseif command == 'assault' and arg1 then
		if not party_slot then update_party_slot() end

		local targets = {}
		for id in arg1:gmatch('[^_]+') do
			targets[#targets + 1] = tonumber(id)
		end

		if #targets == 0 then return end

		-- wrap around if there are more players than targets
		local target_id = targets[((party_slot - 1) % #targets) + 1]
		change_state('advance', target_id)
	
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
		event_found = true
		change_state('interact') 
		
	elseif old == 4 and new == 0 then -- Exit event state
		trying_to_interact = false
		event_found = false
		interacting = false
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
	if not current_leader or current_leader ~= self.name then change_leader(self.name) end
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
		coroutine.schedule(function() change_leader(self.name) end, 0.1)
	else
		coroutine.schedule(function() 
		if not current_leader then
			windower.send_ipc_message('multibox request_leader '..zone)
		end end, 0.3)
	end
	windower.unregister_event(startup)
end)

windower.register_event('party invite',function (new, old)
	coroutine.schedule(function() 
		windower.send_ipc_message('multibox party_update '..zone)	
	end, 5)
end)

windower.register_event('zone change',function (new, old)
	zone = new
	
	-- Make sure self is up to date
	self = windower.ffxi.get_mob_by_target('me')
	while not self do
		self = windower.ffxi.get_mob_by_target('me')
		coroutine.sleep(1)
	end	
	zoning = false
	if is_leader then
		change_leader(self.name)
	else
		-- Double check followers aren't moving
		for i = 1, 5 do
			if windower.ffxi.get_player().autorun then 
				stop_moving()
				coroutine.sleep(0.5)
			else break end
		end
		
		-- Have followers request leader
		while not current_leader do
			windower.send_ipc_message('multibox request_leader '..zone)
			coroutine.sleep(1)
		end
	end
	if is_following then change_state('follow') end
end)

windower.register_event('keyboard',function (dik, pressed, flags, blocked )
	if not windower.ffxi.get_info().logged_in then return end
	if not self then self = windower.ffxi.get_player() return end
	if not current_leader then 
		if windower.has_focus() then change_leader(self.name)
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
			windower.send_ipc_message('multibox interact '..zone..' '..target.id)
			interact_with_target(target)
		end
	elseif dik == 200 then -- dik 200 = up key
		simulate_key_press('up')
	elseif dik == 208 then -- dik 208 = down key
		simulate_key_press('down')
	elseif dik == 1 then -- dik 1 = esc key
		simulate_key_press('escape')
	end
end)

local function raw_actor_id(data) -- Faster way to determine if data is for current player
	local b1, b2, b3, b4 = data:byte(6, 9)
	return b1 + b2 * 256 + b3 * 65536 + b4 * 16777216
end

interaction_ids = S{
	0x032, -- 50 NPC Interaction 1
	0x034, -- 52 NPC Interaction 2
	0x036, -- 54 NPC Chat
	0x03E, -- 62 Open Buy/Sell
	0x04C, -- 76 NPC Auction House Menu
	-- 0x052, -- 82 NPC Release, Sometimes received before other interaction packets causing them to not go through
}
windower.register_event('incoming chunk', function(id, data)
	if not self then return end
	if trying_to_interact and not npc_reaction and interaction_ids:contains(id) then
		npc_reaction = true
		
	elseif id == 0x028 then -- Player action
		local packet = packets.parse('incoming', data)
		if packet.Actor ~= self.id then return end
		
		if casting then
			if packet['Target 1 Action 1 Message'] == 0 or -- Interrupted casting
			packet['Category'] == 4 then -- Finished casting
				casting = false
			end
		elseif packet['Category'] == 8 and -- Started casting
		packet['Target 1 Action 1 Message'] ~= 0 then -- Wasn't interrupted
			-- Prevent casting too far from leader so they don't fall behind
			local dst = distance_to(windower.ffxi.get_mob_by_name(current_leader), self) 
			if dst < 10 then
				casting = true 
				casting_timeout = 0
			else 
				print('Too far to cast :'..dst)
			end
		end
		
	elseif id == 0x00B and not zoning then -- Started zoning
		change_state('zoning')
		
	elseif id == 0x052 then -- NPC Release, Exit interacting if not in an event
		if event_found then return end
		coroutine.schedule(function()
			if not event_found and current_state ~= 'interact' then
				interacting = false
			end
		end, 0.5)
	end
end)