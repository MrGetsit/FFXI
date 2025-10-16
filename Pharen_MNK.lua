function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
end

--------------------------------------------------------		
--				4				5				6			--
-- 			AsuranFists	ShijinSpiral	Boost			--
--	ALT		DragonKick		MaruKala		OffBuffs		--
-- 	SHFT	Provoke		Chakra			DefBuffs		--
-- 	CTRL													--
-- 	WIN		ChiBlast						FormlessStr	--
--															--
--------------------------------------------------------	

function job_setup()	
	windower.send_command('sta !packets on') -- For SendTarget to work
	
    state.WeaponLock = M(false, 'Weapon Lock')	
	state.WeaponSet = M{['description']='Weapon Set', 'Condemners', 'Sophistry'}
    state.OffenseMode:options('Normal', 'Defense')
    send_command('bind @w gs c toggle WeaponLock')	
    send_command('bind %capslock gs c cycle WeaponSet')	
    send_command('bind @S gs c cycle OffenseMode')
end

function user_setup()
	send_command('send @all bind  numpad4  sta Pharen /VictorySmite') 
	send_command('send @all bind  numpad5  sta Pharen /ShijinSpiral') 
	send_command('send @all bind !numpad4  sta Pharen /AsuranFists') 
	send_command('send @all bind !numpad5  sta Pharen /MaruKala') 
	send_command('send @all bind  numpad6 send Pharen /boost') 
	send_command('send @all bind !numpad6 send Pharen exec MonkOBuffs.txt') 
	send_command('send @all bind ~numpad4 send Pharen /Provoke') 
	send_command('send @all bind ~numpad5 send Pharen /Chakra') 
	send_command('send @all bind ~numpad6 send Pharen exec MonkDBuffs.txt') 
	send_command('send @all bind @numpad4  sta Pharen /ChiBlast') 
	send_command('send @all bind @numpad6 send Pharen /FormlessStrikes') 
	
	send_command('wait 5; input /lockstyleset 1') 
end

function init_gear_sets()
    --- Weapon Sets ---
    sets.Condemners = 	{ main="Condemners"}
    sets.Sophistry 	= 	{ main="Sophistry"}

	gear.TPCape		=	{ name="Segomo's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','"Dbl.Atk."+10','Damage taken-1%',}}
    --- Precast Sets ---	
    sets.precast.FC = {}
    sets.precast.WS = { 
		ear1	= "Moonshade earring",
		legs  	= "Hiza. Hizayoroi +2",
		}
    sets.precast.WS['Shijin Spiral'] = set_combine(sets.precast.ws, { })

    --- Midcast Sets ---
    sets.midcast = {}

    --- Engaged Sets ---
    sets.engaged = {
		head  	= "Hiza. Somen +2",
		neck  	= "Sanctity necklace",
		ear1  	= "Mache Earring",
		ear2  	= "Eabani Earring",
		body  	= "Hiza. Haramaki +2",
		hands 	= "Mummu Wrists +2",
		ring1 	= "Rajas Ring",
		ring2 	= "Chirich Ring",
		back  	= gear.TPCape,
		waist 	= "Cetl Belt",
		legs  	= "Mummu Kecks +2",
		feet  	= "Mummu Gamash. +2",
		}

    sets.defense = {
		head  	= "Hiza. Somen +2",
		neck  	= "Sanctity necklace",
		ear1  	= "Mache Earring",
		ear2  	= "Eabani Earring",
		body  	= "Hiza. Haramaki +2",
		hands 	= "Mummu Wrists +2",
		ring1 	= "Hizamaru Ring",
		ring2 	= "Chirich Ring",
		back  	= "Segomo's Mantle", 
		waist 	= "Cetl Belt",
		legs  	= "Mummu Kecks +2",
		feet  	= "Mummu Gamash. +2",
        }

    --- Other Sets ---
    sets.idle = sets.defense
    sets.idle.Town = set_combine(sets.idle, {ring1="Warp Ring", ring2="Dim. Ring (Holla)"})	 
end
function customize_melee_set(meleeSet)
    equip(sets[state.WeaponSet.current])
    if state.OffenseMode.value == "Defense" then
		meleeSet = sets.defense
    end	
    return meleeSet
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