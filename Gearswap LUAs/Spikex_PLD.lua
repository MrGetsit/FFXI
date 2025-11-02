function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
	windower.send_command('sta !packets on') -- For SendTarget to work
end
--[[
Fire >	Ice >	Wind >	Earth >	Thund >	Water >		Fire
Ignis	Fire	Ice		Evasion Down	Paralyze 	Frost		Bind
Gelus	Ice		Wind	Defense Down	Gravity		Silence		Choke
Tellus	Earth	Electr	Magic D Down	Stun 		Shock
Sulpor	Electr	Water	Attack Down		Poison		Drown
Flabra	Wind	Earth	Accuracy Down	Petrify		Rasp		Slow
Unda	Water	Fire	M Attack Down	Amnesia		Plague		Addle		Burn
Lux		Light	Dark	M Evasion Down	Dispel 		Sleep		Blind
Tenebra Dark	Light	M Accuracy Down	Finale		Lullaby 	Charm	
]]
function job_setup()		
    rune_enchantments = S{'Lux','Tenebrae', 'Ignis', 'Gelus', 'Flabra', 'Tellus', 'Sulpor', 'Unda' }
    state.Runes = M{['description']='Runes', 'Lux', 'Tenebrae','Ignis', 'Gelus', 'Flabra', 'Tellus', 'Sulpor', 'Unda' }
	
    state.WeaponLock = M(false, 'Weapon Lock')	
	state.WeaponSet = M{['description']='Weapon Set', 'Sword', 'Tank', 'Club'}	
    state.CastingMode:options('Normal','SIRD') 	
	state.Stance = M{['description']='Stance', 'Normal', 'Offense', 'PDT', 'Block', 'MDT', 'Resist'}
	
    send_command('bind @w gs c toggle WeaponLock')	
    send_command('bind %capslock gs c cycle WeaponSet')		
	send_command('bind %~W gs c cycle CastingMode')	
	send_command('bind %~A gs c set Stance MDT')
    send_command('bind @A gs c set Stance Resist')
	send_command('bind %~S gs c set Stance PDT')
	send_command('bind @S gs c set Stance Block')
    send_command('bind %~D gs c offense')
end

function user_setup()
	
	send_command('send @all bind %1   sta Spikex /SavageBlade')
	send_command('send @all bind !1   sta Spikex /SwiftBlade')
	send_command('send @all bind %2   sta Spikex /ChantDuCygne')
	send_command('send @all bind !2   sta Spikex /Atonement')
	send_command('send @all bind %3   sta Spikex /SanguineBlade')
	send_command('send @all bind !3   sta Spikex /CircleBlade')
	send_command('send @all bind %4   sta Spikex /Cure4 <stpc>')
	send_command('send @all bind !4   sta Spikex /Cure3 <stpc>')
	send_command('send @all bind %5  send Spikex /Majesty')
	send_command('send @all bind !5  send Spikex /Chivalry')
	send_command('send @all bind %e   sta Spikex /Flash <stnpc>')
	send_command('send @all bind ~%e  sta Spikex /DivineEmblem')
	send_command('send @all bind ~%1 send Spikex /Crusade')
	send_command('send @all bind ~%2 send Spikex /Phalanx')
	send_command('send @all bind ~%3 send Spikex /Reprisal')
	send_command('send @all bind ~%4 send Spikex /Enlight2')
	send_command('send @all bind %9  send Spikex /Protect5')
	send_command('send @all bind %0  send Spikex /Shell4')
	send_command('send @all bind %q   sta Spikex /ShieldBash')
	send_command('send @all bind !q   sta Spikex /FlatBlade')
	send_command('send @all bind %z  send Spikex /Sentinel')
	send_command('send @all bind ~%z send Spikex /Rampart')
	send_command('send @all bind ^z  send Spikex /Palisade')
	send_command('send @all bind @z  send Spikex /Palisade')
	send_command('send @all bind %c   sta Spikex /Cover <stpc>')
	send_command('send @all bind !c  send Spikex /Invincible')
	send_command('send @all bind ~%c send Spikex /Intervene')
	
	if player.sub_job == 'WAR' then
		send_command('send @all bind !z  send Spikex /Defender')
		send_command('send @all bind %x  send Spikex /Berserk')
		send_command('send @all bind ~%x send Spikex /Warcry')
		send_command('send @all bind !e  sta Spikex /Provoke <stnpc>')
	elseif player.sub_job == 'BLU' then
		send_command('send @all bind !z  send Spikex /Cocoon')
		send_command('send @all bind !e  send Spikex /Jettatura')
		send_command('send @all bind %x  send Spikex /CursedSphere')
	elseif player.sub_job == 'RUN' then
		send_command('send @all bind !z  send Spikex /Swordplay')
		send_command('send @all bind %x  send Spikex gs c rune')
		send_command('send @all bind ~%x send Spikex gs c cycle Runes')
		send_command('send @all bind ^x  send Spikex gs c cycleback Runes')
		send_command('send @all bind !x  send Spikex /Valiance')
		send_command('send @all bind @x  send Spikex /Vallation')
		send_command('send @all bind ~%6  send Spikex /Blink')
	elseif player.sub_job == 'NIN' then
		send_command('send @all bind %x  send Spikex /UtsusemiNi')
		send_command('send @all bind !x  send Spikex /UtsusemiIchi')
	end
	
	--send_command('input /echo <PLD> (Stance : '..state.Stance.value..') (Weapon : '..state.WeaponSet.value..') (SIRD : '..tostring(state.SIRD)..')')
	send_command('wait 5; input /lockstyleset 1')
end

function init_gear_sets()
    --- Weapon Sets ---
    sets.Sword 	= 	{ main="Naegling", 			sub="Blurred Shield +1"}
    sets.Tank 	= 	{ main="Naegling", 			sub="Priwen"}
    sets.Club 	= 	{ main="Beryllium Mace +1", sub="Priwen"}	
	
	--- Augmented Equipment ---
	gear.CapeDT = { name="Rudianos's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity+10','Phys. dmg. taken-10%',} }
	gear.CapeFC = { name="Rudianos's Mantle", augments={'"Fast Cast"+10','Spell interruption rate down-10%',} }
	
    --- Precast Sets ---
	sets.emnity = {	
        ammo	= {name="Sapience Orb",			priority= 2},	-- 2
		head  	= {name="Souv. Schaller +1",	priority=13},	-- 9	280
		neck  	= {name="Unmoving Collar +1",	priority= 1},	-- 10	
		ear1  	= {name="Tuisto Earring",		priority=10},	--		150
		ear2  	= {name="Eabani Earring",		priority= 4},	--		45
		body  	= {name="Souv. Cuirass +1",		priority=12},	-- 20	171
		hands 	= {name="Souv. Handschuhs",		priority=11},	-- 7	164
		ring1	= {name="Etana Ring",			priority= 8},	--		60
		ring1	= {name="Eihwaz Ring",			priority= 7},	-- 5	60
		back  	= {name=gear.CapeDT,			priority= 6},	-- 10	60
		waist	= {name="Creed Baudrier",  		priority= 3},	-- 5	40
		legs  	= {name="Eschite Cuisses",		priority= 9},	-- 7	117
		feet  	= {name="Chev. Sabatons +3",	priority= 5},	-- 15	52
	}
	sets.precast.JA['Shield Bash'] = set_combine(sets.emnity, {hands="Cab. Gauntlets +2"})
    sets.precast.JA['Sentinel'] = set_combine(sets.emnity, {feet="Caballarius Leggings"})
    sets.precast.JA['Rampart'] = set_combine(sets.emnity, {head="Cab. Coronet"})
    sets.precast.JA['Divine Emblem'] = set_combine(sets.emnity, {feet="Chev. Sabatons +3"})
    sets.precast.JA['Chivalry'] = set_combine(sets.emnity, {hands="Cab. Gauntlets +2"})
    sets.precast.JA['Palisade'] = sets.emnity
    sets.precast.JA['Vallation'] = sets.emnity
    sets.precast.JA['Valiance'] = sets.emnity
	
    sets.precast.WS = set_combine(sets.engaged, {
        ammo	= {name="Oshasha's Treatise",   priority= 5},
		head  	= {name="Chev. Armet +2",  	 	priority=12},	-- 135
		neck  	= {name="Rep. Plat. Medal",     priority= 4},
		ear1  	= {name="Tuisto Earring",       priority=13},	-- 150
		ear2  	= {name="Moonshade earring",    priority= 3},
		body  	= {name="Sulevia\'s Plate. +2",	priority=10},	-- 70
		hands 	= {name="Chev. Gauntlets +2",	priority= 7},	-- 54
		ring1 	= {name="Etana Ring",           priority= 9},	-- 60
		--ring1 	= {name="Cornelia's Ring",      priority= 9},	-- 60
		ring2 	= {name="Rajas Ring",           priority= 2},
		back  	= gear.CapeDT,            						-- 60
		waist 	= {name="Plat. Mog. Belt",      priority=20},	-- 10%
		legs  	= {name="Chev. Cuisses +2", 	priority=11},	-- 117
		feet  	= {name="Sulev. Leggings +1",   priority= 6},	-- 20
		})
	sets.precast.WS['Savage Blade'] = sets.precast.WS
	sets.precast.WS['Sanguine Blade'] = set_combine(sets.precast.WS, {neck="Sibyl Scarf"})
	
    sets.precast.FC = {											-- 71
		ammo  	= {name="Sapience Orb",			priority= 3}, 	-- 2
		head  	= {name="Carmine Mask +1",		priority= 5}, 	-- 14	38
		neck  	= {name="Null Loop",			priority= 8}, 	-- 		50
		ear1  	= {name="Tuisto Earring", 		priority=11},	-- 		150
		ear2	= {name="Eabani Earring", 		priority= 7},	-- 		45
		body  	= {name="Reverence Surcoat +3", priority=12},	-- 10	254
		hands 	= {name="Leyline Gloves",       priority= 4}, 	-- 7	25
		ring1	= {name="Prolix Ring",			priority= 2}, 	-- 2	
		ring2	= {name="Weather. Ring",		priority= 1}, 	-- 5
		back	= gear.CapeFC,					 				-- 10	
		waist	= {name="Platinum moogle belt", priority=13}, 	-- 		10%
		legs	= {name="Enif Cosciales",		priority= 6}, 	-- 8	40
		feet  	= {name="Chev. Sabatons +3",	priority= 9}, 	-- 13	52
		}       
		
    --- Midcast Sets ---					-- SID	FC
    sets.midcast = { }	-- Midcast overrides JAs, Don't use
    sets.midcast.SIRD = {							-- 110
        ammo	= {name="Staunch Tathlum",		priority= 4},	-- 10
        head	= {name="Souv. Schaller +1",	priority= 7},	-- 20	280
        neck	= {name="Moonbeam Necklace",	priority= 3},	-- 10
		back	= gear.CapeFC,					 				-- 10	
		legs	= {name="Founder's Hose",		priority= 6},	-- 30	54
		feet	= {name="Odyssean Greaves",		priority= 5},	-- 20	20
	}			
    sets.midcast.Cure = set_combine(sets.emnity, {ear2="Chev. Earring",neck ="Sacro Gorget",})
    sets.midcast.Cure.SIRD = set_combine(sets.midcast.Cure, sets.midcast.SIRD)
    sets.midcast['Phalanx'] = set_combine(sets.emnity, {
		hands	= "Souveran handschuhs",	-- 4
		feet  	= "Souveran Schuhs",		-- 4
	})
    sets.midcast['Phalanx'].SIRD = set_combine(sets.midcast['Phalanx'], sets.midcast.SIRD)
	sets.midcast['Flash'] = sets.emnity
	
    --- Primary Sets ---	
    sets.idle = {
        ammo	= {name="Staunch Tathlum",      priority= 2},
		head  	= {name="Chev. Armet +2",	    priority= 0},	-- 138
		neck  	= {name="Null Loop",            priority= 4},	-- 50
		ear1  	= {name="Tuisto Earring",       priority=12},	-- 150
		ear2  	= {name="Ethereal Earring",     priority= 3},	-- 15
		body  	= {name="Reverence Surcoat +3", priority=13},	-- 254
		hands 	= {name="Chev. Gauntlets +2",   priority= 5},	-- 54
		ring1 	= {name="Etana Ring",           priority= 9},	-- 60
		ring2 	= "Gurebu's Ring", 
		back  	= gear.CapeDT,            						-- 60
		waist	= {name="Carrier's Sash",       priority= 1},
		legs  	= {name="Chev. Cuisses +2",     priority=10},	-- 117
		feet  	= {name="Chev. Sabatons +3",	priority= 6},	-- 54
	}
	sets.engaged = {
        ammo	= {name="Staunch Tathlum",      priority= 3},
		head  	= {name="Flam. Zucchetto +2",   priority=10},	-- 80
		neck  	= {name="Null Loop",            priority= 7},	-- 50
		ear1  	= {name="Cessance Earring",     priority=12},	-- 150
		ear2	= {name="Eabani Earring", 		priority= 6},	-- 45
		body  	= {name="Reverence Surcoat +3", priority=13},	-- 254
		hands 	= {name="Sulev. Gauntlets +2",  priority= 4},	-- 30
		ring1 	= {name="Etana Ring",           priority= 9},	-- 60
		ring2 	= {name="Rajas Ring",           priority= 2},
		back  	= "Null Shawl",
		waist 	= {name="Sailfi Belt +1",       priority= 1},
		legs  	= {name="Chev. Cuisses +2",     priority=11},	-- 117
		feet  	= {name="Flam. Gambieras +2",   priority= 5},	-- 40
		}
	sets.engaged.Offense = {
        ammo	= {name="Focal Orb",            priority= 3},
		head  	= {name="Flam. Zucchetto +2",   priority=11},	-- 80
		neck  	= {name="Anu Torque",           priority= 8},	-- 50
		ear1  	= {name="Cessance Earring",     priority=12},	-- 150
		ear2  	= {name="Eabani Earring",       priority= 6},	-- 45
		body  	= {name="Reverence Surcoat +3",	priority=13},	-- 254
		hands 	= {name="Sulev. Gauntlets +2",	priority= 4},	-- 30
		ring1 	= {name="Etana Ring",           priority=10},	-- 60
		ring2 	= {name="Rajas Ring",           priority= 2},
		back  	= "Null Shawl",
		waist 	= {name="Sailfi Belt +1",       priority= 1},
		legs  	= {name="Sulev. Cuisses +2", 	priority= 7},	-- 50
		feet  	= {name="Flam. Gambieras +2",   priority= 5},	-- 40
		}
    sets.defense.PDT = {
        ammo	= {name="Staunch Tathlum",		priority= 2},
		head  	= {name="Chev. Armet +2",	    priority=11},	-- 138
		neck  	= {name="Null Loop",            priority= 4},	-- 50
		ear1  	= {name="Tuisto Earring",       priority=12},	-- 150
		ear2  	= {name="Ethereal Earring",     priority= 3},	-- 15
		body  	= {name="Reverence Surcoat +3", priority=13},	-- 254
		hands 	= {name="Chev. Gauntlets +2",   priority= 6},	-- 54
		ring1 	= {name="Etana Ring",           priority= 9},	-- 60
		ring2 	= "Gurebu's Ring", 
		back  	= gear.CapeDT,            						-- 60
		waist	= {name="Plat. Mog. Belt",      priority=14},	-- 10%
		legs  	= {name="Chev. Cuisses +2",     priority=10},	-- 117
		feet  	= {name="Chev. Sabatons +3",    priority= 5},	-- 54
		}
	sets.defense.Block = set_combine(sets.defense.PDT, {})
	sets.defense.MDT = set_combine(sets.defense.PDT, {waist="Carrier's Sash"})
	sets.defense.Resist = sets.defense.MDT
	
    --- Other Sets ---
    sets.idle.Town = set_combine(sets.idle, {ammo="Homiliary",ring1="Warp Ring", ring2="Dim. Ring (Holla)"})	    
	
	sets.buff.Doom = {
        neck="Nicander's Necklace", --30
        ring1="Blenmot's Ring", --5
        ring1="Blenmot's Ring", --5
        waist="Gishdubar Sash", --10
        }
end

function job_post_precast(spell, action, spellMap, eventArgs)
	if spell.type == "WeaponSkill" and player.tp >= 2950 then
		equip({ear2="Ishvara Earring"})	
	end
end
function job_buff_change(buff,gain)
    if buff == "terror" or buff == "petrification" or buff == "stun" then
        if gain then
            equip(sets.defense.PDT)
        end
    elseif buff == "doom" then
        if gain then
            equip(sets.buff.Doom)
            send_command('@input /p Doomed.')
            disable('ring1','ring2','waist','neck')
        else
            send_command('@input /p Doom Removed')
            enable('ring1','ring2','waist','neck')
        end
    end
end
function customize_melee_set()
	equip(sets[state.WeaponSet.current])
	--send_command('@input /p value '..state.DefenseStance.value)
	meleeSet = customize_set()
    return meleeSet
end
function customize_set()
	if state.Stance.value == 'Normal' then
		newSet = sets.engaged
	elseif state.Stance.value == 'Offense' then
		newSet = sets.engaged.Offense
	elseif state.Stance.value == 'PDT' then
		newSet = sets.defense.PDT
	elseif state.Stance.value == 'Block' then
		newSet = sets.defense.Block
	elseif state.Stance.value == 'MDT' then
		newSet = sets.defense.MDT
	elseif state.Stance.value == 'Resist' then
		newSet = sets.defense.Resist
	else
		newSet = sets.idle
	end
	return newSet
end
function job_aftercast(spell, action, spellMap, eventArgs)	
    equip(sets[state.WeaponSet.current])
	equip(customize_set())
end
function job_state_change(field, new_value, old_value)
    if state.WeaponLock.value == true then
        disable('main','sub')
    else
        enable('main','sub')
    end
	if state.WeaponSet.value == "Sword" then
		send_command('send @all bind %1  sta Spikex /SavageBlade')
		send_command('send @all bind !1  sta Spikex /SwiftBlade')
		send_command('send @all bind %2  sta Spikex /ChantDuCygne')
		send_command('send @all bind !2  sta Spikex /Atonement')
	elseif state.WeaponSet.value == "Club" then
		send_command('send @all bind %1  sta Spikex /Realmrazer')
		send_command('send @all bind !1  sta Spikex /HexaStrike')
		send_command('send @all bind %2  sta Spikex /FlashNova')
		send_command('send @all bind !2  sta Spikex /Moonlight')
	end
    equip(sets[state.WeaponSet.current])
end
function job_update(cmdParams, eventArgs)
    equip(sets[state.WeaponSet.current])
end
function job_self_command(cmdParams, eventArgs)
    if cmdParams[1]:lower() == 'rune' then
        send_command('@input /ja '..state.Runes.value..' <me>')
    elseif cmdParams[1]:lower() == 'offense' then    
		if state.Stance.value == 'Normal' then
			send_command('gs c set Stance Offense')
		else
			send_command('gs c set Stance Normal')
		end
    end
end