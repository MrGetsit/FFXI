function get_sets()
	mote_include_version = 2
	include('Mote-Include.lua')
end

function job_setup()	
	state.WeaponSet = M{'Naegling', 'Carnwenhan'}
	state.OffenseMode:options('Normal', 'Defense')
	send_command('bind @S gs c cycle OffenseMode')
    send_command('bind %capslock gs c change_weapon')
end
-- % Normal	^ Ctrl	! Alt	@ Win	# Apps	~ Shift
function user_setup() 
	send_command('send @all bind  numpad7   qa Cissilea WS "Savage Blade" t')
	send_command('send @all bind  numpad8   qa Cissilea MA "Horde Lullaby" mt')
	send_command('send @all bind  numpad9   qa Cissilea MA "Magic Finale" mt')
	send_command('send @all bind ~numpad7 send Cissilea /SentinelsScherzo')
	send_command('send @all bind ~numpad8   qa Cissilea MA "Horde Lullaby II" mt')
	send_command('send @all bind ~numpad9   qa Cissilea MA "Ice Threnody II" mt')	-- Distract, Paralyze
	send_command('send @all bind !numpad9   qa Cissilea MA "Dark Threnody II" mt')	-- Frazzle
	
	send_command('gs c startup')
end

function setup_job_aliases()
	send_command('send @all alias bref exec BRD_Refresh.txt')
	send_command('send @all alias brd1 exec BRD1.txt')
	send_command('send @all alias brd2 exec BRD2.txt')
	send_command('send @all alias brdsv exec BRDSV.txt')
	send_command('send @all alias brdsv2 exec BRDSV2.txt')
	send_command('send @all alias hon send Cissilea hb on')
	send_command('send @all alias hoff send Cissilea hb off')
    send_command('send @all alias shm send Cissilea gs c hmarch')	
    send_command('send @all alias shm2 send Cissilea gs c hmarch 2')	
    send_command('send @all alias sari send Cissilea gs c sari')
    send_command('send @all alias sari2 send Cissilea gs c sari 2')
    send_command('send @all alias spdl send Cissilea gs c sari')
    send_command('send @all alias spdl2 send Cissilea gs c sari 2')
	send_command('send @all alias sst send Cissilea Pianissimo')
	send_command('send @all alias snk3 exec sneak3.txt')
	
	send_command('send @all alias sd    qa Cissilea MA "Gold Capriccio"') 
	send_command('send @all alias smov  qa Cissilea MA "Chocobo Mazurka"') 
	send_command('send @all alias smov2 qa Cissilea MA "Raptor Mazurka"') 
	send_command('send @all alias sss	qa Cissilea MA "Sentinel\'s Scherzo"')
	send_command('send @all alias srr send Cissilea "Goddess\'s Hymnus"')
	
	send_command('send @all alias sreg  qa Cissilea MA "Army\'s Paeon VI"') 
	send_command('send @all alias sreg2 qa Cissilea MA "Army\'s Paeon V"') 
	send_command('send @all alias sreg3 qa Cissilea MA "Army\'s Paeon IV"') 
	send_command('send @all alias sref  qa Cissilea MA "Mage\'s Ballad III"') 
	send_command('send @all alias sref2 qa Cissilea MA "Mage\'s Ballad II"') 
	send_command('send @all alias sref3 qa Cissilea MA "Mage\'s Ballad"') 	
	send_command('send @all alias satt  qa Cissilea MA "Valor Minuet V"') 
	send_command('send @all alias satt2 qa Cissilea MA "Valor Minuet IV"') 
	send_command('send @all alias satt3 qa Cissilea MA "Valor Minuet III"') 
	send_command('send @all alias satt4 qa Cissilea MA "Valor Minuet II"') 
	send_command('send @all alias satt5 qa Cissilea MA "Valor Minuet"') 
	send_command('send @all alias sdef  qa Cissilea MA "Knight\'s Minne V"') 
	send_command('send @all alias sdef2 qa Cissilea MA "Knight\'s Minne IV"') 
	send_command('send @all alias sdef3 qa Cissilea MA "Knight\'s Minne III"') 
	send_command('send @all alias sacc  qa Cissilea MA "Blade Madrigal"') 
	send_command('send @all alias sacc2 qa Cissilea MA "Sword Madrigal"') 
	send_command('send @all alias seva  qa Cissilea MA "Sheepfoe Mambo"') 
	send_command('send @all alias seva2 qa Cissilea MA "Dragonfoe Mambo"') 
	send_command('send @all alias shas  qa Cissilea MA "Victory March"') 
	send_command('send @all alias shas2 qa Cissilea MA "Advancing March"') 
	
	send_command('send @all alias sstr  qa Cissilea MA "Herculean Etude"') 
	send_command('send @all alias sstr2 qa Cissilea MA "Sinewy Etude"') 
	send_command('send @all alias sdex  qa Cissilea MA "Uncanny Etude"') 
	send_command('send @all alias sdex2 qa Cissilea MA "Dextrous Etude"') 
	send_command('send @all alias svit  qa Cissilea MA "Vital Etude"') 
	send_command('send @all alias svit2 qa Cissilea MA "Vivacious Etude"') 
	send_command('send @all alias sagi  qa Cissilea MA "Swift Etude"') 
	send_command('send @all alias sagi2 qa Cissilea MA "Quick Etude"') 
	send_command('send @all alias sint  qa Cissilea MA "Sage Etude"') 
	send_command('send @all alias sint2 qa Cissilea MA "Learned Etude"') 
	send_command('send @all alias smnd  qa Cissilea MA "Logical Etude"')
	send_command('send @all alias smnd2 qa Cissilea MA "Spirited Etude"')	
	
	send_command('send @all alias sfc   qa Cissilea MA "Fire Carol II"')
	send_command('send @all alias sfc2  qa Cissilea MA "Fire Carol"')
	send_command('send @all alias sic   qa Cissilea MA "Ice Carol II"')
	send_command('send @all alias sic2  qa Cissilea MA "Ice Carol"')
	send_command('send @all alias swic  qa Cissilea MA "Wind Carol II"')
	send_command('send @all alias swic2 qa Cissilea MA "Wind Carol"')
	send_command('send @all alias sec   qa Cissilea MA "Earth Carol II"')
	send_command('send @all alias sec2  qa Cissilea MA "Earth Carol"')
	send_command('send @all alias swac  qa Cissilea MA "Water Carol II"')
	send_command('send @all alias swac2 qa Cissilea MA "Water Carol"')
	send_command('send @all alias stc   qa Cissilea MA "Lightning Carol II"')
	send_command('send @all alias stc2  qa Cissilea MA "Lightning Carol"')
	send_command('send @all alias sdc   qa Cissilea MA "Dark Carol II"')
	send_command('send @all alias sdc2  qa Cissilea MA "Dark Carol"')
	send_command('send @all alias slc   qa Cissilea MA "Light Carol II"')
	send_command('send @all alias slc2  qa Cissilea MA "Light Carol"')
	
	send_command('send @all alias sfd   qa Cissilea MA "Fire Threnody II"')
	send_command('send @all alias sid   qa Cissilea MA "Ice Threnody II"')
	send_command('send @all alias sad   qa Cissilea MA "Wind Threnody II"')
	send_command('send @all alias sed   qa Cissilea MA "Earth Threnody II"')
	send_command('send @all alias swd   qa Cissilea MA "Water Threnody II"')
	send_command('send @all alias std   qa Cissilea MA "Lightning Threnody II"')
	send_command('send @all alias sld   qa Cissilea MA "Light Threnody II"')
	send_command('send @all alias sdd   qa Cissilea MA "Dark Threnody II"')
end

function setup_weapon_keybinds()
	if state.WeaponSet.value == 'Carnwenhan' then
		send_command('send @all bind  numpad7   qa Cissilea WS "Mordant Rime" t')
		send_command('send @all bind !numpad7   qa Cissilea WS "Rudra\'s Storm" t')		
	else
		send_command('send @all bind  numpad7   qa Cissilea WS "Savage Blade" t')
		send_command('send @all bind !numpad7   qa Cissilea WS "Burning Blade" t')
	end
end

function init_gear_sets()
	gear.CapeFC	=	{ name="Intarabus's Cape", augments={'CHR+20','Mag. Acc+20 /Mag. Dmg.+20','"Fast Cast"+10',}}
	gear.CapeSR =	{ name="Intarabus's Cape", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity-10','Occ. inc. resist. to stat. ailments+10',}}
	gear.CapeWS =	{ name="Intarabus's Cape", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%','Damage taken-5%',}}
	gear.CapeTP =	{ name="Intarabus's Cape", augments={'HP+60','Accuracy+20 Attack+20','DEX+10','"Store TP"+10','Occ. inc. resist. to stat. ailments+10',}}
	
	gear.LinosTP =	{ name="Linos", augments={'Accuracy+15','"Store TP"+4','Quadruple Attack +3',}}
	gear.LinosWS =	{ name="Linos", augments={'Accuracy+15 Attack+15','Weapon skill damage +3%','STR+8',}}
	
   --- Precast Sets ---	
	sets.precast.JA['Nightingale']	= { feet = "Bihu Slippers +4" }
	sets.precast.JA['Soul Voice']	= { legs = "Bihu Cann. +4" }
	sets.precast.JA['Troubadour']	= { body = "Bihu Justaucorps +4" }
		
	sets.precast.Song = {						-- 76
		head	= "Fili Calot +3",				-- 16
		neck	= "Orunmila's Torque",			-- 05
		ear1	= "Alabaster earring",
		ear2	= "Etiolation earring",			-- 01
		body	= "Inyanga Jubbah +2",			-- 14
		hands	= "Gende. Gages +1",			-- 07
		ring1	= "Murky ring",
		ring2	= "Kishar ring",				-- 04
		back	= gear.CapeFC,					-- 10
		waist	= {name="Plat. Mog. Belt", priority=1},
		legs	= "Ayanmo Cosciales +2",		-- 06
		feet	= "Fili Cothurnes +3",			-- 13
	}
	
	sets.precast.FC = {							-- 77
		--main	= "Kali",						-- 07
		head	= "Welkin Crown",				-- 07
		neck	= "Orunmila's Torque",			-- 05
		ear1	= "Alabaster earring",
		ear2	= "Etiolation earring",			-- 01
		body	= "Inyanga Jubbah +2",			-- 14
		hands	= "Gende. Gages +1",			-- 07
		ring1	= "Etana ring",
		ring2	= "Kishar ring",				-- 04
		back	= gear.CapeFC,					-- 10
		waist	= {name="Plat. Mog. Belt", priority=1},
		legs	= "Ayanmo Cosciales +2",		-- 06
		feet	= "Fili Cothurnes +3",			-- 13
	}

	sets.precast.FC['Healing Magic'] = {		-- 71
		--main	= "Kali",						-- 07
		head	= "Vanya Hood",					-- 07
		neck	= "Orunmila's Torque",			-- 05
		ear1	= {name="Alabaster earring", priority=2},
		ear2	= "Etiolation earring",			-- 01
		body	= "Inyanga Jubbah +2",			-- 14
		hands	= "Gende. Gages +1",			-- 07
		ring1	= {name="Etana ring", priority=3},
		ring2	= "Kishar ring",				-- 04
		back	= gear.CapeFC,					-- 10
		waist	= {name="Plat. Mog. Belt", priority=1},
		legs	= "Vanya Slops",				-- 07
		feet	= "Fili Cothurnes +3",			-- 13
		}
	sets.precast.Cure = sets.precast.FC['Healing Magic']

    sets.precast.WS = {	
		range	= gear.LinosWS,
		head	= "Nyame Helm",
		neck	= "Rep. Plat. Medal",
		ear1	= "Ishvara Earring",
		ear2	= "Moonshade Earring",
		body	= "Bihu Jstcorps. +4",
		hands	= "Bihu Cuffs +4",
		ring1	= "Rufescent ring",
		ring2	= "Gurebu's Ring",
		back	= gear.CapeWS,
		waist	= "Sailfi Belt +1",
		legs	= "Revelation Brais",
		feet	= "Revelation Sab.",
		}
	sets.precast.WS['Mordant Rime']  = {-- Need Crepuscular Knife for mordant rime
		range	= gear.LinosWS,
		head	= "Nyame Helm",
		neck	= "Rep. Plat. Medal",	-- Need Bard's Charm +2
		ear1	= "Ishvara Earring",	-- Need regal or fili +2	~100 / 150
		ear2	= "Alabaster Earring",	
		body	= "Bihu Jstcorps. +4",
		hands	= "Bihu Cuffs +4",
		ring1	= "Metamor. Ring +1",	-- Needs aug
		ring2	= "Gurebu's Ring",		-- Epaminodas + ~700
		back	= gear.CapeWS,
		waist	= "Sailfi Belt +1",
		legs	= "Revelation Brais",
		feet	= "Revelation Sab.",
		}

	--- Midcast Sets ---
	sets.midcast.Song = {
		main	= "Carnwenhan",
		range	= "Miracle Cheer",
		head	= "Fili Calot +3",
		neck	= "Mnbw. Whistle +1",
		body	= "Fili Hongreline +3",
		hands	= "Fili Manchettes +3",
		ring1	= "Murky Ring",
		waist	= {name="Plat. Mog. Belt", priority=1},
		legs	= "Fili Rhingrave +3",
		feet	= "Fili Cothurnes +3",
		}
		
	sets.midcast.SongDuration = {
		main	= "Carnwenhan",
		head	= "Fili Calot +3",
		neck	= "Mnbw. Whistle +1",
		body	= "Fili Hongreline +3",
		hands	= "Fili Manchettes +3",
		ring1	= "Murky Ring",
		waist	= {name="Plat. Mog. Belt", priority=1},
		legs	= "Inyanga Shalwar +2",
		feet	= "Brioso Slippers +3",
		}
		
	sets.midcast.Debuff = {
		range	= "Blurred Harp",
		head	= "Brioso Roundlet +3",
		neck	= "Mnbw. Whistle +1",
		ear1	= {name="Alabaster Earring", priority=1},
		ear2	= {name="Etiolation Earring", priority=2}, -- Gersemi
		body	= "Brioso Justaucorps +4",
		hands	= "Brioso Cuffs +3",
		ring1	= "Murky ring",			-- 10
		ring2	= "Gurebu's Ring",
		back	= gear.CapeFC,
		waist	= "Null Belt",
		legs	= "Inyanga Shalwar +2",
		feet	= "Brioso Slippers +3",
		}		
	sets.midcast['Enfeebling Magic'] = sets.midcast.Debuff
		
	sets.midcast.Dummy = { -- Dummy song
		range	= "Daurdabla",
		head	= "Null Masque",		-- 10
		neck	= "Warder's Charm +1",
		ear1	= "Alabaster Earring",	-- 05
		ear2	= "Fili Earring +1",
		body	= "Nyame Mail",			-- 09
		hands	= "Nyame Gauntlets",	-- 07
		ring1	= "Murky ring",			-- 10
		ring2	= "Etana Ring",
		back	= "Aurist's Cape +1",
		waist	= "Plat. Mog. Belt",	-- 03	
		legs	= "Nyame Flanchard",	-- 08
		feet	= "Nyame Sollerets",	-- 07
		}
	sets.midcast['Gold Capriccio'] = sets.midcast.Dummy
	sets.midcast['Bewitching Etude'] = sets.midcast.Dummy


	sets.midcast['Healing Magic'] = {
		--main	= "Daybreak",
		head	= "Vanya Hood",
		neck	= {name="Null Loop",				priority= 1},
		ear1	= "Alabaster Earring",
		ear2	= "Fili Earring +1",
		body	= {name="Brioso Just. +4",			priority= 2},
		hands	= "Fili Manchettes +3",
		ring1	= "Murky Ring",
		ring2	= "Lebeche Ring",
		back	= gear.CapeFC,
		legs	= "Vanya Slops",
		feet	= "Vanya Clogs",
		}

	--- Engaged Sets ---
	sets.engaged = {
		range	= gear.LinosTP,
		head	= "Null Masque",
		neck	= "Null Loop",
		ear1	= "Crep. Earring",
		ear2	= "Brutal Earring",
		body	= "Nyame Mail",
		hands	= "Bunzi's Gloves",
		ring1	= "Murky ring",
		ring2	= "Gurebu's Ring",
		back	= "Null Shawl",
		waist	= "Sailfi Belt +1",
		legs	= "Revelation Brais",
		feet	= "Revelation Sab.",
		}
		
	sets.defense = {
		range	= "Miracle Cheer",
		head	= "Fili Calot",			-- 11	More MDB/MEV than Null or Nyame
		neck	= "Warder's Charm +1",
		ear1	= "Alabaster Earring",	-- 05
		ear2	= "Fili Earring +1",	-- 04
		body	= "Fili Hongreline +3",	--		Trade 3 MEV for MDB on Nyame, +5 Regen
		hands	= "Bunzi's Gloves",		-- 08	3 more MDB for 30 DEF/EVA
		ring1	= "Murky ring",			-- 10
		ring2	= "Gurebu's Ring",
		back	= gear.CapeSR,
		waist	= "Null Belt",
		legs	= "Fili Rhingrave +3",	-- 13	More MEV/MDB than Nyame
		feet	= "Fili Cothurnes +3",	--		More MEV/MDB than Nyame
		}

	--- Other Sets ---
	sets.idle = set_combine(sets.defense, {	head = "Null Masque" })
	sets.idle.Town = set_combine(sets.defense, { ring1 = "Warp Ring", ring2 = "Dim. Ring (Holla)" })	 
end

function job_buff_change(buff,gain)
    if buff == "terror" or buff == "petrification" or buff == "stun" then
        if gain then
            incapacitated = true
		else
            incapacitated = false
        end
	elseif buff == "sleep" then
		if gain then
			incapacitated = true
			enable('main')
			equip({main = 'Mpu Gandring'})
			disable('main')
			return
		else
			incapacitated = false
			enable('main')
			customize_melee_set()
		end
    elseif buff == "doom" then
        if gain then
            equip(sets.buff.Doom)
            send_command('@input /p Doomed.')
            disable('ring1','ring2','waist','neck')
        else
            enable('ring1','ring2','waist','neck')
        end
	elseif buff == "charm" then
		if gain then
			send_command('@input /p Charmed.')
		end
	elseif buff == "silence" then
		if gain then
			send_command('@input /p Silenced.')
			silenced = true
			auto_echo_drops()
		else
			silenced = false
		end
	elseif spell_order then
		if buff == "Nightingale" then
			send_command('qa Cissilea JA Troubadour')
		elseif buff == "Troubadour" then
			send_command('qa Cissilea MA '..spell_order)
		elseif buff == "March" then
			spell_order = nil
		end
    end
end

function customize_melee_set()
	if state.OffenseMode.value == "Defense" or incapacitated then
		meleeSet = sets.defense
	else
		meleeSet = sets.engaged
	end
	
	meleeSet = set_combine(meleeSet, { main = state.WeaponSet.current } )
	if dual_wield then 
		meleeSet = set_combine(meleeSet, { sub = "Centovente" })
	else
		meleeSet = set_combine(meleeSet, { sub = "Genmei Shield" })
	end
	
	equip(meleeSet)
end

function job_post_pretarget(spell, action, spellMap, eventArgs)
	local cancel = false
		
	if spell.name == 'Honor March' then
		equip({range="Marsyas"})
		
	elseif spell.name == 'Aria of Passion' then
		equip({range="Loughnashade"})
		
	elseif casting then 
		cancel = true
			
	elseif spell.action_type == 'Magic' then -- Don't change gear on CD
		if windower.ffxi.get_spell_recasts()[spell.recast_id] >= 1 then
			cancel = true
		end
		
	elseif spell.type == 'WeaponSkill' then
		if player.tp <= 1000 then
			cancel = true
		end
	end
	
	if cancel then
		cancel_spell()
		eventArgs.handled = true
		return
	end
end

function job_precast(spell, action, spellMap, eventArgs)
	if spell.type == 'BardSong' then
		if spell.name == 'Honor March' then
			equip(set_combine(sets.precast.Song, {range="Marsyas"}))
		elseif spell.name == 'Aria of Passion' then
			equip(set_combine(sets.precast.Song, {range="Loughnashade"}))
		else
			equip(sets.precast.Song)
		end
		eventArgs.handled = true
	elseif midaction() then
		cancel_spell()
		eventArgs.handled = true
		return
	end
	casting = true
	cast_timer_id = (cast_timer_id or 0) + 1
	local this_timer = cast_timer_id
	coroutine.schedule(function()
		if this_timer ~= cast_timer_id then return end
		casting = false
	end, 4)
end

function job_midcast(spell, action, spellMap, eventArgs)
	if spell.type == 'BardSong' then
		if spell.name == 'Honor March' then
			equip(set_combine(sets.midcast.SongDuration, {range="Marsyas"}))
		elseif spell.name == 'Aria of Passion' then
			equip(set_combine(sets.midcast.SongDuration, {range="Loughnashade"}))
		elseif S{'Magic Finale','Foe Lullaby','Foe Lullaby II','Horde Lullaby','Horde Lullaby II','Pining Nocturne','Foe Requiem VII','Carnage Elegy'}:contains(spell.english) or spell.english:endswith('Threnody II') then
			equip(sets.midcast.Debuff)
		else
			equip(sets.midcast.Song)
		end
	end
end

function job_aftercast(spell, action, spellMap, eventArgs)
	casting = false
	cast_timer_id = (cast_timer_id or 0) + 1
	customize_melee_set()
end

function job_update(cmdParams, eventArgs)
	check_dual_wield()
	casting = false
	customize_melee_set()
end

function job_state_change(field, new_value, old_value)
	casting = false	
	customize_melee_set()
end

function job_self_command(cmdParams, eventArgs)
	if cmdParams[1] == 'startup' then
		setup_job_aliases()
		check_dual_wield()
		customize_melee_set()
		setup_weapon_keybinds()
		send_command('wait 5; input /lockstyleset 2') 
		
	elseif cmdParams[1] == 'change_weapon' then
		enable('main','sub')
		state.WeaponSet:cycle()
		setup_weapon_keybinds()
		customize_melee_set()
		
	elseif cmdParams[1] == 'sari' then
		enable('range')
		equip({range="Loughnashade"})
		if cmdParams[2] then 
			spell_order = '"Aria of Passion"'
			send_command('qa Cissilea JA Nightingale')
		else
			send_command('qa Cissilea MA "Aria of Passion"')
		end
		
	elseif cmdParams[1] == 'hmarch' then
		enable('range')
		equip({range="Marsyas"})
		if cmdParams[2] then 
			spell_order = '"Honor March"'
			send_command('qa Cissilea JA Nightingale')
		else
			send_command('qa Cissilea MA "Honor March"')
		end
	end
end

function auto_echo_drops ()
	if not silenced then return end
	send_command('input /item "Echo Drops" <me>')
	coroutine.schedule(function() auto_echo_drops() end, 2)
end

function check_dual_wield()
	if player.sub_job and player.sub_job_level >= 20 then
		if player.sub_job == 'NIN' or player.sub_job == 'DNC' then
			dual_wield = true
		return end
	end
	dual_wield = false
end