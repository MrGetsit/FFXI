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
    state.OffenseMode:options('Normal', 'Defense')
    send_command('bind @w gs c toggle WeaponLock')	
    send_command('bind %capslock gs c cycle WeaponSet')		
    send_command('bind @S gs c cycle OffenseMode')
    send_command('bind ^= gs c cycle treasuremode')
	
	send_command('lua l autora') 
	send_command('sa lua l rolltracker') 
	autora_on = false
end

function user_setup()

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
	send_command('send @all alias sj send Sneaksy /SpectralJig') 

	send_command('send @all bind  numpad1 send Sneaksy /SavageBlade ') 
	send_command('send @all bind  numpad2  sta Sneaksy /LeadenSalute ') 
	send_command('send @all bind  numpad3 send Sneaksy /LightShot ') 
	send_command('send @all bind !numpad1  sta Sneaksy /Requiescat ') 
	send_command('send @all bind !numpad2  sta Sneaksy /LastStand ') 
	send_command('send @all bind !numpad3 send Sneaksy /DarkShot ') 
	send_command('send @all bind ~numpad1 send Sneaksy /SamuraiRoll ') 
	send_command('send @all bind ~numpad2 send Sneaksy /ChaosRoll ') 
	send_command('send @all bind ~numpad3 send Sneaksy /DoubleUp ') 
	send_command('send @all bind @numpad1 send Sneaksy /CrookedCards ') 
	send_command('send @all bind @numpad2 send Sneaksy /Fold ') 
	send_command('send @all bind @numpad3 send Sneaksy /SnakeEye ') 
	--send_command('send @all bind  numpad3 send Sneaksy gs c toggle_autora ') 
	
	if player.sub_job == 'DNC' then
		send_command('send @all bind ^numpad1  sta Sneaksy /HealingWaltz <stpc> ') 
		send_command('send @all bind ^numpad2  sta Sneaksy /CuringWaltz3 <stpc> ') 
		send_command('send @all bind ^numpad3 send Sneaksy /HasteSamba ')  
		--send_command('send @all bind %pageup send Sneaksy /ReverseFlourish ') 
		send_command('send @all bind %pagedown send Sneaksy /Boxstep ') 
		send_command('send @all bind ~pagedown send Sneaksy /Quickstep ') 
		send_command('send @all bind ^pagedown send Sneaksy /StutterStep ') 
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
	send_command('lua u autora') 
	send_command('sa lua u rolltracker') 
end

function init_gear_sets()
    --- Weapon Sets ---
    sets.Sword 	= 	{ main="Naegling", 	sub="Tauret",	range="Anarchy +2",	ammo="Bronze bullet"}
    sets.Dagger = 	{ main="Tauret", 	sub="Naegling",}

	gear.CapeTP = { name="Camulus's Mantle", augments={'DEX+1','Accuracy+20 Attack+20','"Dbl.Atk."+10',} }
	gear.CapeWSD= { name="Camulus's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%',} }
	
    sets.TreasureHunter = {head="Herculean Helm",body="Herculean Vest",ring1="Gorney Ring", waist="Chaac Belt"} 
	
    --- Precast Sets ---
    sets.precast.CorsairRoll = {back="Camulus's Cape",head="Lanun Tricorne", hands="Chasseur's Gants +3",ring1="Barataria Ring",legs="Desultor Tassets"}	

    sets.precast.Waltz = { head="Mummu Bonnet +2", feet="Rawhide Boots" }	
    sets.precast.FC = {}
	sets.precast.RA = {
		feet 	= "Meg. Jam. +1",		
		}
    sets.precast.WS = { 
        neck	= "Rep. Plat. Medal",
		ear1	= "Moonshade earring",
		ear2	= "Ishvara Earring",
		head	= "Meghanada Visor +2",
		body	= "Meg. Cuirie +2",
		hands	= "Chasseur's Gants +3",
		ring1	= "Cornelia's Ring",
		back	= gear.CapeWSD,
		feet 	= "Lanun bottes +4",
		}
    sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {
		waist	= "Prosilio Belt +1",  	
		ring2	= "Vehemence Ring",
	})
    sets.precast.WS['Leaden Salute'] = set_combine(sets.precast.WS, {
		head 	= "Pixie Hairpin +1",
		neck	= "Sibyl Scarf",
		ear2	= "Friomisi Earring",
		body	= "Lanun frac +2",
		ring2	= "Archon Ring",
		waist	= "Eschan Stone",  	
	})

    --- Midcast Sets ---
    sets.midcast.SpellInterrupt = {}
    sets.midcast.Utsusemi = {}
	sets.midcast.CorsairShot = {ammo="Animikii bullet"}
	
	sets.midcast.RA = {
		head 	= "Meghanada Visor +1",
		neck 	= "Marked Gorget",		
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
		legs 	= "Meg. Chausses +2",
		feet 	= "Malignance Boots",
		}

    sets.defense = {
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
		legs 	= "Meg. Chausses +2",
		feet 	= "Malignance Boots",
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
	if spell.type == "WeaponSkill" and player.tp >= 1900 then
		equip({ear1="Ishvara Earring"})	
	end
end
function customize_melee_set(meleeSet)
    equip(sets[state.WeaponSet.current])
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
		send_command('send @all bind  numpad1 send Sneaksy /Exenterator ') 
		send_command('send @all bind !numpad1  sta Sneaksy /Evisceration ') 
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