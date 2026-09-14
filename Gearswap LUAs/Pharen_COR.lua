function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
end

function job_setup()	
    include('Mote-TreasureHunter')
    info.default_ja_ids = S{35, 204}
    info.default_u_ja_ids = S{201, 202, 203, 205, 207}
	
	windower.send_command('sta !packets on') -- For SendTarget to work
	
    state.WeaponLock = M(false, 'Weapon Lock')	
	state.WeaponSet = M{['description']='Weapon Set', 'Sword', 'Dagger'}
	state.WeaponSetR = M{['description']='Ranged Weapon Set', 'TP', 'WS'}
    state.OffenseMode:options('Normal', 'Defense' )
    send_command('bind @w gs c toggle WeaponLock')	
    send_command('bind %capslock gs c cycle WeaponSet')	
    send_command('bind ~capslock gs c cycle WeaponSetR')		
    send_command('bind @S gs c cycle OffenseMode')
    send_command('bind ^= gs c cycle treasuremode')
	autora_on = false
end

function user_setup()
	send_command('send @all alias r2xp send Pharen /CorsairsRoll') 
	send_command('send @all alias r2tp send Pharen /TacticiansRoll') 
	send_command('send @all alias r2da send Pharen /FightersRoll') 
	send_command('send @all alias r2sb send Pharen /MonksRoll') 
	send_command('send @all alias r2acc send Pharen /HuntersRoll') 
	send_command('send @all alias r2def send Pharen /GallantsRoll') 
	send_command('send @all alias r2mac send Pharen /WarlocksRoll') 
	send_command('send @all alias r2mab send Pharen /WizardsRoll') 
	send_command('send @all alias r2eva send Pharen /NinjaRoll') 
	send_command('send @all alias r2mev send Pharen /RuneistsRoll') 
	send_command('send @all alias r2mde send Pharen /MagussRoll') 
	send_command('send @all alias r2cri send Pharen /RoguesRoll') 
	send_command('send @all alias r2pat send Pharen /BeastRoll') 
	send_command('send @all alias r2pac send Pharen /DrachenRoll') 
	send_command('send @all alias r2pma send Pharen /PuppetRoll') 
	send_command('send @all alias r2att send Pharen /ChaosRoll') 
	
	send_command('send @all bind  numpad4 send Pharen /SavageBlade ') 
	send_command('send @all bind  numpad5  sta Pharen /LeadenSalute ') 
	send_command('send @all bind  numpad6 send Pharen /LightShot ') 
	send_command('send @all bind !numpad4  sta Pharen /Requiescat ') 
	send_command('send @all bind !numpad5  sta Pharen /LastStand ') 
	send_command('send @all bind !numpad6 send Pharen /DarkShot ') 
	send_command('send @all bind ~numpad4 send Pharen /FightersRoll ') 
	send_command('send @all bind ~numpad5 send Pharen /HuntersRoll ') 
	send_command('send @all bind ~numpad6 send Pharen /DoubleUp ') 
	send_command('send @all bind @numpad4 send Pharen /CrookedCards ') 
	send_command('send @all bind @numpad5 send Pharen /Fold ') 
	send_command('send @all bind @numpad6 send Pharen /SnakeEye ') 	
end

function user_unload()
	send_command('lua u autora') 
end

function init_gear_sets()
    --- Weapon Sets ---
    sets.Sword 	= { main	= "Naegling", 		sub	= "Tauret" }
    sets.Dagger = { main	= "Tauret", 		sub	= "Naegling" }
    sets.TP 	= { range	= "Anarchy +2", 	ammo= "Bronze Bullet" }
    sets.WS 	= { range	= "Death Penalty",	ammo= "Bronze Bullet" }

	sets.Comp	= { range	= "Compensator" }
	
	gear.CapeTP = { name="Camulus's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','"Dbl.Atk."+10','Phys. dmg. taken-10%',} }
	gear.CapeSTR= { name="Camulus's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%',} }
	gear.CapeAGI= { name="Camulus's Mantle", augments={'AGI+20','Mag. Acc+20 /Mag. Dmg.+20','AGI+10','Weapon skill damage +10%',} }
	
    sets.TreasureHunter = {head="Herculean Helm",body="Herculean Vest",ring1="Gorney Ring", waist="Chaac Belt"} 
	
    --- Precast Sets ---
    sets.precast.JA['Tactician\'s Roll']= { body  = "Chasseur's Frac" 		}
    sets.precast.JA['Blitzer\'s Roll'] 	= { head  = "Chasseur's Tricorne" 	}
    sets.precast.JA['Allies\' Roll'] 	= { hands = "Chasseur's Gants" 		}
    sets.precast.JA['Caster\'s Roll'] 	= { legs  = "Chasseur's Culottes" 	}
    sets.precast.JA['Courser\'s Roll'] 	= { feet  = "Chasseur's Bottes" 	}
	
    sets.precast.CorsairRoll = {
		head	= "Lanun Tricorne", 
		neck	= "Regal Necklace",
		hands	= "Chasseur's Gants +3",
		back	= "Camulus's Mantle",
		legs	= "Desultor Tassets"
	}	
    sets.precast.Waltz = { head="Mummu Bonnet +2", feet="Rawhide Boots" }	
    sets.precast.FC = {}
	sets.precast.RA = {
		body	= "Laksa. Frac +4",
		feet 	= "Meg. Jam. +1",		
		}
    sets.precast.WS = { 
        neck	= "Rep. Plat. Medal",
		ear1	= "Ishvara Earring",
		head	= "Meghanada Visor +2",
		body	= "Meg. Cuirie +2",
		hands	= "Chasseur's Gants +3",
		ring1	= "Cornelia's Ring",
		ring2	= "Dingir",
		back	= gear.CapeAGI,
		feet 	= "Lanun bottes +4",
		}
    sets.precast.WS['Savage Blade'] = {	
		head 	= "Meghanada Visor +2",
        neck	= "Rep. Plat. Medal",
		ear1 	= "Alabaster Earring",
		ear2 	= "Ishvara Earring",
		body	= "Laksa. Frac +4",
		hands	= "Chasseur's Gants +3",
		ring1	= "Cornelia's Ring",
		ring2	= "Ilibrat Ring",
		back	= gear.CapeSTR,
		waist	= "Prosilio Belt +1",  
		legs 	= "Meg. Chausses +2",
		feet 	= "Lanun Bottes +4",
	}
    sets.precast.WS['Hot Shot'] = set_combine(sets.precast.WS, {
		neck	= "Sibyl Scarf",
		ear2	= "Friomisi Earring",
		body	= "Lanun frac +4",
		waist	= "Eschan Stone",  	
	})
    sets.precast.WS['Leaden Salute'] = set_combine(sets.precast.WS['Hot Shot'], {
		head 	= "Pixie Hairpin +1",
	})
    sets.precast.WS['Aeolian Edge'] = sets.precast.WS['Hot Shot']

    --- Midcast Sets ---
    sets.midcast.SpellInterrupt = {}
    sets.midcast.Utsusemi = {}
	sets.midcast.CorsairShot = {ammo="Animikii bullet"}
	
	sets.midcast.RA = {
		head 	= "Malignance Chapeau",
		neck 	= "Iskur Gorget",
		ear1 	= "Eabani Earring",
		ear2 	= "Alabaster Earring",
		body 	= "Malignance Tabard",
		hands	= "Malignance Gloves",
		ring1	= "Chirich Ring +1",
		ring2 	= "Rajas Ring",
		back	= "Null Shawl",
		waist	= "Null Belt",  
		legs 	= "Malignance Tights",
		feet 	= "Malignance Boots",
		}
    --- Engaged Sets ---
    sets.engaged = {
		ammo 	= "Bronze Bullet",
		head 	= "Malignance Chapeau",
		neck 	= "Iskur Gorget",
		ear1 	= "Eabani Earring",
		ear2 	= "Suppanomimi",
		body 	= "Malignance Tabard",
		hands	= "Adhemar Wrist. +1",
		ring1	= "Chirich Ring +1",
		ring2 	= "Rajas Ring",
		back	= "Null Shawl",
		waist	= "Sailfi Belt +1",  
		legs 	= "Malignance Tights",
		feet 	= "Malignance Boots",
		}

    sets.defense = {
		ammo 	= "Bronze Bullet",
		head 	= "Malignance Chapeau",
		neck 	= "Null Loop",
		ear1 	= "Eabani Earring",
		ear2 	= "Alabaster Earring",
		body 	= "Malignance Tabard",
		hands	= "Malignance Gloves",
		ring1	= "Chirich Ring +1",
		ring2 	= "Murky Ring",
		back	= "Null Shawl",
		waist	= "Plat. Mog. Belt",  
		legs 	= "Malignance Tights",
		feet 	= "Malignance Boots",
        }

    --- Other Sets ---
	sets.idle = sets.defense
    sets.idle.Town = set_combine(sets.idle, {ring1="Warp Ring", ring2="Dim. Ring (Holla)"})	 
	
	sets.buff.Doom = {
        neck	= "Nicander's Necklace", --30
        ring1	= "Saida Ring", --15
        waist	= "Gishdubar Sash", --10
        }
end

function job_buff_change(buff,gain)
    if buff == "terror" or buff == "petrification" or buff == "stun" then
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
	if spell.type == "WeaponSkill" then
		if (state.WeaponSetR.current == 'WS' and player.tp <= 2750) 
		or player.tp <= 1750 then
			equip({ear1="Moonshade Earring"})	
		end
	end
	if not WeaponLock then
		if player.tp <= 350 and spell.english:endswith('Roll') then
			send_command('gs equip sets.Comp')
		end
	end
end
function customize_melee_set(meleeSet)
    equip(sets[state.WeaponSet.current])
    equip(sets[state.WeaponSetR.current])
    if state.OffenseMode.value == "Defense" then
		meleeSet = sets.defense
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
    equip(sets[state.WeaponSetR.current])
end
function job_state_change(field, new_value, old_value)
    if state.WeaponLock.value == true then
        disable('main','sub')
    else
        enable('main','sub')
	end
	if state.WeaponSet.value == "Sword" then	
		if player.equipment.main == "Tauret" then
			send_command('input /equip main')
		end
		send_command('send @all bind  numpad1 send Sneaksy /SavageBlade ') 
		send_command('send @all bind !numpad1  sta Sneaksy /Requiescat ')
	elseif state.WeaponSet.value == "Dagger" then
		if player.equipment.main == "Naegling" then
			send_command('input /equip main')
		end
		send_command('send @all bind  numpad1 send Sneaksy /AeolianEdge ') 
		send_command('send @all bind !numpad1  sta Sneaksy /Evisceration ') 
	end
    equip(sets[state.WeaponSet.current])
    equip(sets[state.WeaponSetR.current])
end
function job_update(cmdParams, eventArgs)
    equip(sets[state.WeaponSet.current])
    equip(sets[state.WeaponSetR.current])
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