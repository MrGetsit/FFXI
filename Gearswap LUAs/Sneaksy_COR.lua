function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
end

--------------------------------------------------------		
--				1				2				3			--
-- 			MeleeWS1		RangeWS1		ToggleRange	--
--	ALT		MeleeWS2		RangeWS2		TripleShot		--
-- 	SHFT	Roll1			Roll2			DoubleUp		--
-- 	CTRL	Cleanse<st>	Heal<st>		HasteSamba		--
-- 	WIN		CrookedCrds	Fold			SnakeEye		--
--															--
--------------------------------------------------------	

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
	
	send_command('sa lua l rolltracker') 
	
	engaged_ammo = 'Corsair Bullet'
	ammo_case = 'Cor. Bull. Pouch'
	
	auto = false
	autofire = nil
	last_shot_time = 0
end

function user_setup()

	send_command('send @all alias sj send Sneaksy /SpectralJig') 
	send_command('send @all alias rxp send Sneaksy /CorsairsRoll') 
	send_command('send @all alias rtp send Sneaksy /TacticiansRoll') 
	send_command('send @all alias rda send Sneaksy /FightersRoll') 
	send_command('send @all alias rsb send Sneaksy /MonksRoll') 
	send_command('send @all alias racc send Sneaksy /HuntersRoll') 
	send_command('send @all alias rdef send Sneaksy /GallantsRoll') 
	send_command('send @all alias rmac send Sneaksy /WarlocksRoll') 
	send_command('send @all alias rmab send Sneaksy /WizardsRoll') 
	send_command('send @all alias reva send Sneaksy /NinjaRoll') 
	send_command('send @all alias rmev send Sneaksy /RuneistsRoll') 
	send_command('send @all alias rmde send Sneaksy /MagussRoll') 
	send_command('send @all alias rcri send Sneaksy /RoguesRoll') 
	send_command('send @all alias rpat send Sneaksy /BeastRoll') 
	send_command('send @all alias rpac send Sneaksy /DrachenRoll') 
	send_command('send @all alias rpma send Sneaksy /PuppetRoll') 

	send_command('send @all bind  numpad1 send Sneaksy /SavageBlade ') 
	send_command('send @all bind  numpad2  sta Sneaksy /LeadenSalute ') 
	--send_command('send @all bind  numpad3 send Sneaksy /LightShot ') 
	send_command('send @all bind !numpad1  sta Sneaksy /Requiescat ') 
	send_command('send @all bind !numpad2  sta Sneaksy /HotShot ') 
	send_command('send @all bind !numpad3 send Sneaksy /DarkShot ') 
	send_command('send @all bind ~numpad1 send Sneaksy /ChaosRoll ') 
	send_command('send @all bind ~numpad2 send Sneaksy /SamuraiRoll ') 
	send_command('send @all bind ~numpad3 send Sneaksy /DoubleUp ') 
	send_command('send @all bind @numpad1 send Sneaksy /CrookedCards ') 
	send_command('send @all bind @numpad2 send Sneaksy /Fold ') 
	send_command('send @all bind @numpad3 send Sneaksy /SnakeEye ') 
	send_command('send @all bind  numpad3 send Sneaksy gs c auto ') 
	
	if player.sub_job == 'DNC' then
		send_command('send @all bind ^numpad1  sta Sneaksy /HealingWaltz <stpc> ') 
		send_command('send @all bind ^numpad2  sta Sneaksy /CuringWaltz3 <stpc> ') 
		send_command('send @all bind ^numpad3 send Sneaksy /HasteSamba ')  
		--send_command('send @all bind %pageup send Sneaksy /ReverseFlourish ') 
		send_command('send @all bind %pagedown send Sneaksy /Boxstep ') 
		send_command('send @all bind ~pagedown send Sneaksy /Quickstep ') 
		send_command('send @all bind ^pagedown send Sneaksy /StutterStep ') 
		send_command('send @all bind %end send Sneaksy /BuildingFlourish ') 
	elseif player.sub_job == 'THF' then
		send_command('send @all bind ^numpad1 send Sneaksy /Steal ') 
		send_command('send @all bind ^numpad2 send Sneaksy /TrickAttack ') 
		send_command('send @all bind ^numpad3 send Sneaksy /SneakAttack ') 
	elseif player.sub_job == 'WAR' then
		send_command('send @all bind ^numpad1 send Sneaksy /Berserk ') 
		send_command('send @all bind ^numpad2 send Sneaksy /Warcry ') 
		send_command('send @all bind ^numpad3 send Sneaksy /Aggressor ') 
	end
	
	send_command('gs c set treasuremode tag')
	send_command('wait 5; input /lockstyleset 2') 
end

function user_unload()
	send_command('sa lua u rolltracker') 
end

function init_gear_sets()
    --- Weapon Sets ---
    sets.Sword 	= { main	= "Naegling", 		sub	= "Gleti's Knife" }
    sets.Dagger = { main	= "Tauret", 		sub	= "Naegling" }
    sets.TP 	= { range	= "Anarchy +2", 	ammo= engaged_ammo }
    sets.WS 	= { range	= "Fomalhaut",		ammo= "Chrono Bullet" }

	sets.Comp	= { range	= "Compensator" }
	
	gear.CapeTP = { name="Camulus's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','"Dbl.Atk."+10','Phys. dmg. taken-10%',} }
	gear.CapeSTR= { name="Camulus's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%',} }
	gear.CapeAGI= { name="Camulus's Mantle", augments={'AGI+20','Mag. Acc+20 /Mag. Dmg.+20','AGI+10','Weapon skill damage +10%',} }
	
    sets.TreasureHunter = {head="Herculean Helm",body="Herculean Vest",ring1="Gorney Ring", waist="Chaac Belt"} 
	
    --- Precast Sets ---
    sets.precast.JA['Tactician\'s Roll']= { body  = "Chasseur's Frac" 		}
    sets.precast.JA['Blitzer\'s Roll'] 	= { head  = "Chasseur's Tricorne" 	}
    sets.precast.JA['Allies\' Roll'] 	= { hands = "Chasseur's Gants +3" 	}
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
			
    sets.precast.WS = { 
		ammo	= "Chrono Bullet",
		head	= "Nyame Helm",
		neck	= "Sibyl Scarf",
		ear1	= "Ishvara Earring",
		ear2	= "Friomisi Earring",
		body	= "Lanun frac +4",
		hands	= "Chasseur's Gants +3",
		ring1	= "Cornelia's Ring",
		ring2	= "Dingir Ring",
		back	= gear.CapeAGI,
		waist	= "Eschan Stone",  
		legs	= "Nyame Flanchard",  	
		feet 	= "Lanun bottes +4",
		}
    --sets.precast.WS['Leaden Salute'] = set_combine(sets.precast.WS, {
	--	head 	= "Pixie Hairpin +1",
	--})
    sets.precast.WS['Aeolian Edge'] = sets.precast.WS['Hot Shot']
    sets.precast.WS['Savage Blade'] = {	
		head 	= "Meghanada Visor +2",
        neck	= "Rep. Plat. Medal",
		ear1 	= "Telos Earring",
		ear2 	= "Ishvara Earring",
		body	= "Laksa. Frac +4",
		hands	= "Chasseur's Gants +3",
		ring1	= "Cornelia's Ring",
		ring2	= "Regal Ring",
		back	= gear.CapeSTR,
		waist	= "Sailfi Belt +1",  
		legs 	= "Lanun Trews +4",
		feet 	= "Lanun Bottes +4",
	}

	sets.precast.RA = {					-- SNP	RPD
		head	= "Ikenga's Hat",		-- 06
		body	= "Laksa. Frac +4",		--		20
		hands	= "Ikenga's Gloves",	-- 07
		ring1	= "Crepuscular Ring",	-- 03
		waist	= "Yemaya Belt",		-- 		05
		legs	= "Lanun Trews +4",		-- 10
		feet 	= "Meg. Jam. +2",		-- 10
		}
		
    --- Midcast Sets ---
	sets.midcast.CorsairShot = {ammo="Animikii bullet"}
	
	sets.midcast.RA = {
		--head 	= "Malignance Chapeau",
		head 	= "Ikenga's Hat",
		neck 	= "Iskur Gorget",
		ear1 	= "Crep. Earring",
		ear2 	= "Telos Earring",
		--body 	= "Malignance Tabard",
		body 	= "Ikenga's Vest",
		hands	= "Malignance Gloves",
		--hands	= "Ikenga's Gloves",
		ring1	= "Chirich Ring +1",
		ring2 	= "Crepuscular Ring",
		back	= "Null Shawl",
		waist	= "Yemaya Belt",
		--legs 	= "Malignance Tights",
		legs 	= "Ikenga's Trousers",
		feet 	= "Malignance Boots",
		--feet 	= "Ikenga's Clogs",
		}
    --- Engaged Sets ---
    sets.engaged = {
		ammo 	= engaged_ammo,
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
		ammo 	= engaged_ammo,
		head	= "Nyame Helm",
		neck 	= "Null Loop",
		ear1 	= "Eabani Earring",
		ear2 	= "Alabaster Earring",
		body	= "Nyame Mail",
		hands	= "Nyame Gauntlets",
		ring1	= "Chirich Ring +1",
		ring2 	= "Murky Ring",
		back	= "Null Shawl",
		waist	= "Plat. Mog. Belt",  
		legs	= "Nyame Flanchard",
		feet	= "Nyame Sollerets",
        }

    --- Other Sets ---
	sets.idle = sets.defense
    sets.idle.Town = set_combine(sets.idle, {ring1="Warp Ring", ring2="Dim. Ring (Holla)"})	 
	
	sets.buff.Doom = {
        neck	= "Nicander's Necklace", --30
        ring1	= "Saida Ring", --15
        ring2	= "Purity Ring", --07
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
	elseif buff == "charm" then
		if gain then
			send_command('@input /p Charmed.')
		end
    end
end
function job_post_pretarget(spell, action, spellMap, eventArgs)
	if spell.type == "WeaponSkill" then
		if player.equipment.ammo == 'Hauksbok Bullet' then
			equip({ammo="empty"})
		end
		if auto then auto = false end
		if player.tp <= 1000 then
			cancel_spell()
			eventArgs.handled = true
		end
	end
	if not WeaponLock then
		if player.tp <= 350 and spell.english:endswith('Roll') then
			send_command('gs equip sets.Comp')
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
end
function customize_melee_set(meleeSet)
    equip(sets[state.WeaponSet.current])
    equip(sets[state.WeaponSetR.current])
    if state.OffenseMode.value == "Defense" then
		meleeSet = sets.defense
    end	
    return meleeSet
end

function job_aftercast(spell, action, spellMap, eventArgs)	
	if player.equipment.ammo == 'Hauksbok Bullet' then
		equip({ammo="empty"})
	end
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

function job_self_command(command, eventArgs)
	if command[1]:lower() == 'auto' then
		auto = not auto
		if auto then
			windower.add_to_chat(160, 'Autofire On')
			target()
			
			autofire = windower.register_event('action', function(action)
				if not auto then stop_shooting() return end
				if (action.actor_id == player.id and action.category == 2) or os.clock() - last_shot_time > 5 then
					target()
				end
			end)
		else
			stop_shooting()
		end
	elseif command[1]:lower() == 'test' then
		tprint(data)
	end
end

function target()
    if not auto then stop_shooting() return end 
	
	if not player.equipment or
	player.equipment.ammo == 'empty' then 
		windower.send_command('input /party Out of ammo')
		windower.send_command('input /item "'.. ammo_case ..'" ' .. player.name)
		stop_shooting()
	return end
	
    local tar = windower.ffxi.get_mob_by_target('t')
    if not tar or tar.hpp == 0 then 
		stop_shooting()
	return end
	windower.ffxi.turn(math.atan2(tar.x - player.x, tar.y - player.y) - 1.5708)
	shoot:schedule(1.5)
	
	local recast = windower.ffxi.get_ability_recasts()[84]
	if recast == 0 then
		windower.send_command('/TripleShot')
	end
end

function shoot()
	last_shot_time = os.clock()
    windower.send_command('input /shoot <t>')
end

function stop_shooting()
	auto = false
	if autofire then
		windower.add_to_chat(160, 'Autofire Off')
		windower.unregister_event(autofire)
		autofire = nil
	end
end
function tprint(tbl, indent)
	if not indent then indent = 0 end
	local spaces = string.rep("  ", indent) -- Use two spaces for indentation

	for k, v in pairs(tbl) do
		local key_str
		if type(k) == "number" then
			key_str = "[" .. k .. "]"
		else
			key_str = "['" .. k .. "']"
		end

		if type(v) == "table" then
		   print(2, spaces .. key_str .. " = {") 
			tprint(v, indent + 1)
		   print(2, spaces .. "}")
		else
			local value_str = tostring(v)
			if type(v) == "string" then
				value_str = "'" .. value_str .. "'"
			end
			print(2, spaces .. key_str .. " = " .. value_str .. ",")
		end
	end
end