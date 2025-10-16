function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
end

--------------------------------------------------------		
--				1				2				3			--
-- 			SharkBite		RudrasStorm	SneakAttack	--
--	ALT		MandalicStab	Evisceration	TrickAttack	--
-- 	SHFT	Feint			Conspirator	Collaborator	--
-- 	CTRL	HealingWaltz	CuringWaltz3	HasteSamba		--
-- 	WIN						Steal			Bully			--
--															--
--------------------------------------------------------	

function job_setup()	
    include('Mote-TreasureHunter')
	skip = true
    info.default_ja_ids = S{35, 204}
    info.default_u_ja_ids = S{201, 202, 203, 205, 207}
	
	windower.send_command('sta !packets on') -- For SendTarget to work
	windower.send_command('lua l thtracker') -- For SendTarget to work
	
    state.WeaponLock = M(false, 'Weapon Lock')	
	state.WeaponSet = M{['description']='Weapon Set', 'Dagger', 'Sword'}
    state.OffenseMode:options('Normal', 'Defense')
    send_command('bind @w gs c toggle WeaponLock')	
    send_command('bind %capslock gs c cycle WeaponSet')		
    send_command('bind @S gs c cycle OffenseMode')
    send_command('bind ^= gs c cycle treasuremode')
end

function user_setup()
	send_command('send @all alias sj send Sneaksy /SpectralJig') 
	
	send_command('send @all bind  numpad1  sta Sneaksy /SharkBite ') 
	send_command('send @all bind  numpad2  sta Sneaksy /RudrasStorm ') 
	send_command('send @all bind  numpad3 send Sneaksy /SneakAttack ') 
	send_command('send @all bind !numpad1  sta Sneaksy /MandalicStab ') 
	send_command('send @all bind !numpad2  sta Sneaksy /Evisceration ') 
	send_command('send @all bind !numpad3 send Sneaksy /TrickAttack ') 
	send_command('send @all bind ~numpad1 send Sneaksy /Feint ') 
	send_command('send @all bind ~numpad2 send Sneaksy /Conspirator ') 
	send_command('send @all bind ~numpad3  sta Sneaksy /Collaborator <stpc> ') 
	send_command('send @all bind ^numpad1  sta Sneaksy /HealingWaltz <stpc> ') 
	send_command('send @all bind ^numpad2  sta Sneaksy /CuringWaltz3 <stpc> ') 
	send_command('send @all bind ^numpad3 send Sneaksy /HasteSamba ') 
	send_command('send @all bind @numpad2 send Sneaksy /Steal ') 
	send_command('send @all bind @numpad3 send Sneaksy /Bully ') 
	send_command('send @all bind %pageup send  Sneaksy /ReverseFlourish ') 
	send_command('send @all bind %pagedown send Sneaksy /Boxstep ') 
	send_command('send @all bind ~pagedown send Sneaksy /Quickstep ') 
	send_command('send @all bind ^pagedown send Sneaksy /StutterStep ') 
	send_command('gs c set treasuremode tag')
	
	send_command('wait 5; input /lockstyleset 1') 
end

function user_unload()
	send_command('lua u thtracker') 
end

function init_gear_sets()
    --- Weapon Sets ---
    sets.Dagger = 	{ main= "Tauret", 		sub= "Skinflayer"}
    sets.Sword 	= 	{ main= "Naegling", 	sub= "Skinflayer"}
	
    sets.TreasureHunter = {
		--ring1	= "Gorney Ring", 			-- 1
		waist	= "Chaac Belt", 			-- 1
		hands	= "Plun. Armlets +1", 		-- 3
		feet	= "Skulk. Poulaines +3", 	-- 4
		ammo	= "Per. Lucky Egg"			-- 1
	} 
	
    --- Precast Sets ---
    sets.precast.JA['Feint'] = {legs="Plun. Culottes"}
    sets.precast.JA['Conspirator'] = {legs="Raider's Vest +1"}
	
    sets.precast.Waltz = { head="Mummu Bonnet +2", feet="Rawhide Boots" }	
	
    sets.precast.WS = { 
		ammo	= "Oshasha's Treatise",
        neck	= "Rep. Plat. Medal",
		ear1	= "Moonshade earring",
		hands	= "Meg. Gloves +2",
		back	= "Toutatis's Cape",
		}
    sets.precast.WS['Savage Blade'] = set_combine(sets.WS, {
		neck 	= "Anu Torque",	
		ear2 	= "Ishvara Earring",
	})
    sets.precast.WS['Aeolian Edge'] = set_combine(sets.WS, {
		neck	= "Sibyl Scarf",
		ear2 	= "Friomisi Earring",
		waist	= "Eschan Stone",  		
	})
	
    --- Engaged Sets ---
    sets.engaged = {	-- Subtle blow 	-- 28 + 10 + 13
		ammo	= "Ginsen",
		head 	= "Malignance Chapeau",	--  	Adhemar Bonnet +1 8
		neck 	= "Anu Torque",			--  	Erudit. Necklace  6
		ear1 	= "Odr Earring",
		ear2 	= "Skulker's Earring",	-- 5
		body 	= "Malignance Tabard",
		hands	= "Adhemar Wrist. +1",	-- 8
		ring1 	= "Rajas Ring",			-- 5
		ring2	= "Chirich Ring +1",	-- 10
		back	= "Null Shawl",
		waist	= "Sailfi Belt +1",  
		legs 	= "Meg. Chausses +2",
		feet 	= "Skulk. Poulaines +3",
		}

    sets.defense = {
		head 	= "Malignance Chapeau",
		neck 	= "Null Loop",
		ear1 	= "Eabani Earring",
		ear2 	= "Allegro Earring",
		body 	= "Malignance Tabard",
		hands	= "Malignance Gloves",
		ring1	= "Vehemence Ring",
		ring2	= "Chirich Ring +1",
		back	= "Null Shawl",
		waist	= "Plat. Mog. Belt",  
		legs 	= "Meg. Chausses +2",
		feet 	= "Skulk. Poulaines +3",
        }

    --- Other Sets ---
	sets.idle = sets.defense
    sets.idle.Town = set_combine(sets.idle, {ring1="Warp Ring", ring2="Dim. Ring (Holla)"})	 
	
	sets.buff.Doom = {
        neck="Nicander's Necklace", --30
        ring1="Saida Ring", --15
        waist="Gishdubar Sash", --10
        }
end

function job_buff_change(buff,gain)
    if buff == "terror" then
        if gain then
            equip(sets.defense)
        end
    elseif buff == "doom" then
        if gain then
            equip(sets.buff.Doom)
            send_command('@input /p Doomed.')
            disable('ring1','ring2','waist','neck')
        else
            enable('ring1','ring2','waist','neck')
        end
    end
end
function job_post_precast(spell, action, spellMap, eventArgs)
	if spell.type == "WeaponSkill" and player.tp >= 1900 then
		equip({ear1="Ishvara Earring"})	
	end
end
function customize_melee_set(meleeSet)
    equip(sets[state.WeaponSet.current])
    if state.OffenseMode.value == "Defense" then
		meleeSet = sets.defense
		
    elseif state.TreasureMode.value == 'Fulltime' then
        meleeSet = set_combine(meleeSet, sets.TreasureHunter)
    end
    return meleeSet
end
function job_self_command(command, eventArgs)
	if command[1]:lower() == 'toggle_autora' then
		if autora_on == false then
			send_command('ara start') 
			autora_on = true
			windower.add_to_chat(160, 'AutoRA starting')
		else
			send_command('ara stop') 
			autora_on = false
			windower.add_to_chat(160, 'AutoRA stopping')
		end
	end
end
function job_aftercast(spell, action, spellMap, eventArgs)	
    equip(sets[state.WeaponSet.current])
end
function job_state_change(field, new_value, old_value)
    if state.WeaponLock.value == true then
        disable('main','sub')
    else
        enable('main','sub')
    end
	if state.WeaponSet.value == "Sword" then
		if player.equipment.main == "Skinflayer" then
			send_command('input /equip main')
		end
		send_command('send @all bind  numpad1  sta Sneaksy /SavageBlade ') 
		send_command('send @all bind  numpad2  sta Sneaksy /Requiescat ') 
	elseif state.WeaponSet.value == "Dagger" then
		if player.equipment.main == "Skinflayer" then
			send_command('input /equip main')
		end
		send_command('send @all bind  numpad1  sta Sneaksy /SharkBite ') 
		send_command('send @all bind !numpad1  sta Sneaksy /MandalicStab ') 
		send_command('send @all bind  numpad2  sta Sneaksy /RudrasStorm ') 
		send_command('send @all bind !numpad2  sta Sneaksy /Evisceration ') 
	end
    equip(sets[state.WeaponSet.current])
end
function job_update(cmdParams, eventArgs)
    equip(sets[state.WeaponSet.current])
end
function th_action_check(category, param)
    if category == 2 or -- any ranged attack
        --category == 4 or -- any magic action
        (category == 3 and param == 30) or -- Aeolian Edge
        (category == 6 and info.default_ja_ids:contains(param)) or -- Provoke, Animated Flourish
        (category == 14 and info.default_u_ja_ids:contains(param)) -- Quick/Box/Stutter Step, Desperate/Violent Flourish
        then return true
    end
end