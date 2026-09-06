function get_sets()
	mote_include_version = 2
	include('Mote-Include.lua')
end
function job_setup()
	windower.send_command('sta !packets on') -- For SendTarget to work

	state.OffenseMode:options('Normal', 'Defense') -- 'Hybrid', 
	
	--state.MainWeapon = M{'Qutrub Knife', 'Twinned Blade', 'Ophidian Sword', 'Lost Sickle', 'Iapetus', 'Debahocho', 'Ethereal Tachi', 'Thunder Hammer', 'Erudite\'s Staff' }
	state.MainWeapon = M{'Chango', 'Naegling', 'Shining One'}
	
	send_command('bind @w gs c lock')
	send_command('bind capslock gs c cycle MainWeapon')
	send_command('bind @S gs c cycle OffenseMode')
	
	WeaponLock = false
	
	if player.sub_job == 'NIN' or player.sub_job == 'DNC' then
		dual_wield = true
	else
		dual_wield = false
	end	
end

function user_setup()
	setup_weapon_keybinds()
	
	send_command('send @all alias ms send Spikex MightyStrikes') 
	
	send_command('send @all bind %q   sta Spikex Restraint')
	send_command('send @all bind !q  send Spikex Hasso')
	send_command('send @all bind ^q  send Spikex Meditate')
	send_command('send @all bind %e   sta Spikex Provoke')
	send_command('send @all bind !e   sta Spikex Tomahawk')
	send_command('send @all bind %4  send Spikex Berserk')
	send_command('send @all bind %5  send Spikex Warcry')
	send_command('send @all bind ^4  send Spikex Aggressor')
	send_command('send @all bind ^5  send Spikex BloodRage')
	send_command('send @all bind %z  send Spikex Defender')
	send_command('send @all bind %x  send Spikex Retaliation')
	
	send_command('gs c set MainWeapon Chango')
	send_command('wait 5; input /lockstyleset 1')
end
function init_gear_sets()
	--- Gear Sets ---
	sets.Chango 	= {main = "Chango", 	sub = "Utu Grip"}
	sets.Naegling 	= {main = "Naegling", 	sub = "Blurred Shield +1"}
	sets.Shining 	= {main = "Shining One",sub = "Utu Grip"}
	
	--- Ability Sets ---
	sets.precast.JA['Aggressor']		= { head = "Pummeler's Mask", chest="Agoge Lorica" }
	sets.precast.JA['Berserk']			= { chest= "Pummeler's Lorica +4", back="Cichol's Mantle", feet="Agoge Calligae" }
	sets.precast.JA['Blood Rage']		= { chest= "Boii Lorica +3" }
	sets.precast.JA['Defender']			= { hands= "Agoge Mufflers" }
	sets.precast.JA['Mighty Strikes']	= { hands= "Agoge Mufflers" }
	sets.precast.JA['Restraint']		= { hands= "Boii Mufflers +3" }
	sets.precast.JA['Retaliation']		= { hands= "Pummeler's Mufflers +3", feet="Ravager's Calligae +2" }
	sets.precast.JA['Tomahawk']			= { feet = "Agoge Calligae" }
	sets.precast.JA['Warcry']			= { head = "Agoge Mask +4" }
	
	--- WS Sets ---
	sets.precast.WS = {
		ammo	= "Knobkierrie",
		head	= "Agoge Mask +4",
		neck	= "Rep. Plat. Medal",
		ear1	= "Thrud Earring",
		ear2	= "Moonshade Earring",
		body	= "Pummeler's Lorica +4",
		hands	= "Boii Mufflers +3",
		ring1	= "Cornelia's Ring",
		ring2	= "Regal Ring",
		back	= "Cichol's Mantle",
		waist	= "Sailfi Belt +1",
		legs	= "Boii Cuisses +3",
		feet	= "Sakpata's Leggings",
		}
	sets.precast.WS['Savage Blade'] = {
		ammo	= "Knobkierrie",
		head	= "Agoge Mask +4",
		neck	= "Rep. Plat. Medal",	-- War. Beads +2
		ear1	= "Thrud Earring",
		ear2	= "Moonshade Earring",
		body	= "Pummeler's Lorica +4",
		hands	= "Boii Mufflers +3",
		ring1	= "Cornelia's Ring",
		ring2	= "Regal Ring",
		back	= "Cichol's Mantle",
		waist	= "Sailfi Belt +1",
		legs	= "Boii Cuisses +3",
		feet	= "Sakpata's Leggings",
		}
		
	--- Engaged Sets ---
	sets.engaged = {
		ammo	= "Coiste Bodhar",
		head	= "Boii Mask +3",		-- Boii Mask +3
		neck	= "Null Loop",			-- Vim Torque +1
		ear1	= "Schere Earring",
		ear2	= "Boii Earring +1",
		body	= "Boii Lorica +3",
		hands	= "Sakpata's Gauntlets",
		--ring1	= "Niqmaddu Ring", 
		ring1	= "Chirich Ring +1",	-- Moonlight Ring
		ring2	= "Chirich Ring +1",	-- Moonlight Ring
		back	= "Null Shawl",			-- Cichol's Mantle
		waist	= "Sailfi Belt +1",		-- Ioskeha Belt +1
		legs	= "Boii Cuisses +3",	-- Pumm. Cuisses +3
		feet	= "Sakpata's Leggings", -- Pumm. Calligae +3
		}
	sets.defense = {
		ammo	= "Coiste Bodhar",
		head	= "Sakpata's Helm",		
		neck	= "Null Loop",			
		ear1	= "Schere Earring",
		ear2	= "Dedition Earring",	
		body	= "Sakpata's Plate",	
		hands	= "Sakpata's Gauntlets",
		ring1	= "Niqmaddu Ring", 
		ring2	= "Chirich Ring +1",	
		back	= "Null Shawl",
		waist	= "Plat. Mog. Belt",
		legs	= "Sakpata's Cuisses",	
		feet	= "Sakpata's Leggings", 
		}
		
	--- Other Sets ---
	sets.idle = sets.defense
	sets.idle.Town = set_combine(sets.idle, {ring1="Warp Ring", ring2="Dim. Ring (Holla)"})	    
	
	sets.buff.Doom = {
		neck="Nicander's Necklace",	--30
		ring1="Blenmot's Ring",		--5
		ring2="Blenmot's Ring",		--5
		waist="Gishdubar Sash",		--10
	}
end

function setup_weapon_keybinds()
	local main = state.MainWeapon.value
	
	if main == 'Naegling' then
		send_command('send @all bind %1 send Spikex /SavageBlade')
		send_command('send @all bind %2 send Spikex /ChantDuCygne')
		send_command('send @all bind !1 send Spikex /RedLotusBlade')
		send_command('send @all bind !2 send Spikex /SeraphBlade')
		weapon_text = 'Switched to:  Naegling'
		
	elseif main == 'Chango' then
		send_command('send @all bind %1 send Spikex /Upheaval')
		send_command('send @all bind !1 send Spikex /KingsJustice')
		send_command('send @all bind %2 send Spikex /FellCleave')
		send_command('send @all bind !2 send Spikex /UkkosFury')
		send_command('send @all bind %3 send Spikex /ArmorBreak')
		weapon_text = 'Switched to:  Chango'
		
	elseif main == 'Shining One' then
		send_command('send @all bind %1 send Spikex /ImpulseDrive')
		weapon_text = 'Switched to:  Shining One'
	
	elseif main == 'Twinned Blade' then
		send_command('send @all bind %1 send Spikex /RedLotusBlade')
		send_command('send @all bind %2 send Spikex /SeraphBlade')
	
	elseif main == 'Ophidian Sword' then
		send_command('send @all bind %1 send Spikex /Freezebite')
	
	elseif main == 'Lost Sickle' then
		send_command('send @all bind %1 send Spikex /ShadowOfDeath')
		
	elseif main == 'Iapetus' then
		send_command('send @all bind %1 send Spikex /RaidenThrust')
		
	elseif main == 'Debahocho' then
		send_command('send @all bind %1 send Spikex /BladeEi')
		equip({neck="Yarak Torque"})
		
	elseif main == 'Ethereal Tachi' then
		send_command('send @all bind %1 send Spikex /TachiJinpu')
		send_command('send @all bind %2 send Spikex /TachiKoki')
		equip({head="Kengo Hachimaki",neck="Agelast Torque"})
		
	elseif main == 'Thunder Hammer' then
		send_command('send @all bind %1 send Spikex /SeraphStrike')
		
	elseif main == 'Erudite\'s Staff' then
		send_command('send @all bind %1 send Spikex /EarthCrusher')
		send_command('send @all bind %2 send Spikex /Sunburst')
	end
	--windower.add_to_chat(209, weapon_text)
end

function check_weapon(bypass)
	if temp_weapons then
		enable('main','sub')
		equip({main = tempmain, sub = tempsub})
		toggle_weapon_lock(true)
		temp_weapons = false
		return
	end

	if not bypass and WeaponLock then return end
	
	enable('main','sub','range')
	
	if state.MainWeapon.value == 'Chango' then
		equip(sets.Chango)
	elseif state.MainWeapon.value == 'Naegling' then
		equip(sets.Naegling)
	elseif state.MainWeapon.value == 'Shining One' then
		equip(sets.Shining)
	else
		equip({main = state.MainWeapon.value})
	end
end

function customize_melee_set()
	if state.OffenseMode.value == "Defense" or
	player.status == 'Idle' or incapacitated then
		equip(sets.defense)
	elseif state.OffenseMode.value == "Hybrid" then
		if dual_wield then
			equip(sets.hybrid.DW)
		else
			equip(sets.hybrid)
		end
	else
		if dual_wield then
			equip(sets.engaged.DW)
		else
			equip(sets.engaged)
		end
	end
	check_weapon()
end

function job_buff_change(buff,gain)
	if buff == "doom" then
		if gain then
			enable('ring1','ring2','waist','neck')
			equip(sets.buff.Doom)
			send_command('@input /p Doomed.')
			disable('ring1','ring2','waist','neck')
		else
			send_command('@input /p Doom Removed')
			enable('ring1','ring2','waist','neck')
		end
	elseif buff == "charm" then
		if gain then
			send_command('@input /p Charmed.')
		end
	end
	if buff == "sleep" then
		if gain then
			incapacitated = true
			save_temp_weapons()
			enable('main')
			equip({main = 'Caliburnus'})
			toggle_weapon_lock(false)
		else
			incapacitated = false
			if temp_weapons then check_weapon() end
		end
	end
	if buff == "terror" or buff == "petrification" or buff == "stun" then
		if gain then
			incapacitated = true
		else
			incapacitated = false
		end
	end
	customize_melee_set()
end

function job_post_pretarget(spell, action, spellMap, eventArgs)
	cancel = false
	if spell.action_type == 'Magic' then -- Don't change gear on CD
		local recast = windower.ffxi.get_spell_recasts()[spell.recast_id]
		if recast and recast >= 1 then cancel = true end
	elseif spell.type == 'WeaponSkill' then
		if player.tp <= 1000 then cancel = true	end
	end
	if cancel or incapacitated then
		cancel_spell()
		eventArgs.handled = true
		return
	end
	
	if WeaponLock then
		disable('main','sub','range')
	end
end

function job_aftercast(spell)
	customize_melee_set()
end

function job_state_change(field, new_value, old_value)
	if field == 'MainWeapon' then 
		setup_weapon_keybinds()
		check_weapon(true)
	end
	customize_melee_set()
end

function job_self_command(cmdParams, eventArgs)
	if cmdParams[1]:lower() == 'rune' then
		send_command('@input /ja '..state.Runes.value..' <me>')
	
	elseif cmdParams[1]:lower() == 'lock' then
		WeaponLock = not WeaponLock
		toggle_weapon_lock(WeaponLock)
	end
end

function save_temp_weapons()
	temp_weapons = true
	tempmain = player.equipment.main
	tempsub = player.equipment.sub
end

function toggle_weapon_lock(should_enable)
	if should_enable then
		WeaponLock = true
		disable('main','sub','range')
		windower.add_to_chat(206, 'Weapon Lock: On')
	else
		WeaponLock = false
		enable('main','sub','range')
		windower.add_to_chat(206, 'Weapon Lock: Off') 
		check_weapon()
	end
end
