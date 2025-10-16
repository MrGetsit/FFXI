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
	autora_on = false
end

function user_setup()
	send_command('send @all bind  numpad1  sta Sneaksy /SavageBlade ') 
	send_command('send @all bind  numpad2  sta Sneaksy /Detonator ') 
	send_command('send @all bind  numpad3 send Sneaksy gs c toggle_autora ') 
	send_command('send @all bind !numpad1  sta Sneaksy /Requiescat ') 
	send_command('send @all bind !numpad2  sta Sneaksy /LastStand ') 
	send_command('send @all bind !numpad3 send Sneaksy /TripleShot ') 
	send_command('send @all bind ~numpad1 send Sneaksy /SamuraiRoll ') 
	send_command('send @all bind ~numpad2 send Sneaksy /ChaosRoll ') 
	send_command('send @all bind ~numpad3 send Sneaksy /DoubleUp ') 
	send_command('send @all bind ^numpad1  sta Sneaksy /HealingWaltz <stpc> ') 
	send_command('send @all bind ^numpad2  sta Sneaksy /CuringWaltz3 <stpc> ') 
	send_command('send @all bind ^numpad3 send Sneaksy /HasteSamba ') 
	send_command('send @all bind @numpad1 send Sneaksy /CrookedCards ') 
	send_command('send @all bind @numpad2 send Sneaksy /Fold ') 
	send_command('send @all bind @numpad3 send Sneaksy /SnakeEye ') 
	send_command('gs c set treasuremode tag')
	
	send_command('wait 5; input /lockstyleset 1') 
end

function init_gear_sets()
    --- Weapon Sets ---
    sets.Sword 	= 	{ main="Kaja Sword", 		sub="Voluspa Knife"}
    sets.Dagger = 	{ main="Voluspa Knife", 	sub=""}

	gear.CapeTP = { name="Camulus's Mantle", augments={'Accuracy+20 Attack+20','"Dbl.Atk."+10',} }
	gear.CapeWSD= { name="Camulus's Mantle", augments={'STR+20','Accuracy+20 Attack+20','Weapon skill damage +10%',} }
	
    sets.TreasureHunter = {ring1="Gorney Ring", waist="Chaac Belt", ammo="Per. Lucky Egg"} 
	
    --- Precast Sets ---
    sets.precast.CorsairRoll = {back="Gunslinger's Cape",head="Comm. Tricorne", ring1="Barataria Ring",legs="Desultor Tassets "}
	sets.midcast.CorsairRoll = {back="Camulus's Cape"}

    sets.precast.Waltz = { feet="Rawhide Boots" }
    sets.precast.JA['Sneak Attack'] = { feet="Rawhide Boots" }
	
    sets.precast.FC = {}
	sets.precast.RA = {
		feet 	= "Meg. Jam. +1",
		}
    sets.precast.WS = { 
		ear1	= "Moonshade earring",
		hands	= "Meg. Gloves +2",
		back	= gear.CapeWSD,
		}
    sets.precast.WS['Savage Blade'] = set_combine(sets.WS, {})

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
		head 	= "Mummu Bonnet +2",
		neck 	= "Sanctity Necklace",
		ear1 	= "Eabani Earring",
		ear2 	= "Odr Earring",
		body 	= "Mummu Jacket +2",
		hands	= "Mummu Wrists +2",
		ring1	= "Mummu Ring",
		ring2 	= "Rajas Ring",
		back	= gear.CapeTP,
		waist	= "Sailfi Belt +1",  
		legs 	= "Meg. Chausses +2",
		feet 	= "Mummu Gamash. +2",
		}

    sets.defense = {
		head 	= "Mummu Bonnet +2",
		neck 	= "Sanctity Necklace",
		ear1 	= "Eabani Earring",
		ear2 	= "Allegro Earring",
		body 	= "Mummu Jacket +2",
		hands	= "Mummu Wrists +2",
		ring1	= "Mummu Ring",
		ring2	= "Vehemence Ring",
		back	= gear.CapeTP,
		waist	= "Cuchulain's Belt",  
		legs 	= "Meg. Chausses +2",
		feet 	= "Mummu Gamash. +2",
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
    end

    if buff == "doom" then
        if gain then
            equip(sets.buff.Doom)
            send_command('@input /p Doomed.')
            disable('ring1','ring2','waist','neck')
        else
            enable('ring1','ring2','waist','neck')
        end
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
