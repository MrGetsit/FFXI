function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
end

--------------------------------------------------------		
--				1				2				3			--
-- 						        --
--	ALT							--
-- 	SHFT						--
-- 	CTRL						--
-- 	WIN							--
--								--
--------------------------------------------------------	

function job_setup()	
	windower.send_command('sta !packets on') -- For SendTarget to work
	
    state.WeaponLock = M(false, 'Weapon Lock')	
	state.WeaponSet = M{['description']='Weapon Set', 'Apocalypse', 'Zantetsuken X'}
    state.OffenseMode:options('Normal', 'Defense')
    send_command('bind @w gs c toggle WeaponLock')	
    send_command('bind %capslock gs c cycle WeaponSet')	
    send_command('bind @S gs c cycle OffenseMode')
end
-- % Normal	^ Ctrl	! Alt	@ Win	# Apps	~ Shift

function user_setup()
	send_command('send @all bind  numpad1  sta Pharen /Catastrophe') 
	send_command('send @all bind  numpad3  sta Pharen /Entropy') 
	send_command('send @all bind  numpad2  sta Pharen /Cross Reaper') 
	send_command('send @all bind ~numpad3  sta Pharen /Shell Crusher') 
	send_command('send @all bind ~numpad2 send Pharen /Hasso') 
	send_command('send @all bind !numpad1 send Pharen /Provoke') 
	send_command('send @all bind !numpad2 send Pharen /Chakra') 
	send_command('send @all bind !numpad3 send Pharen exec MonkDBuffs.txt') 
	send_command('send @all bind @numpad1  sta Pharen /ChiBlast') 
	send_command('send @all bind @numpad2 send Pharen /FormlessStrikes') 
	
	send_command('wait 5; input /lockstyleset 2') 
end

function init_gear_sets()
    --- Weapon Sets ---
    sets.Apocalypse = 	{ main="Apocalypse"}
    sets.Zantetsuken 	= 	{ main="Zantetsuken X"}

   
   --- Precast Sets ---	
    sets.precast.FC = {
		ammo 	= "Sapience Orb",	--2
		hands	= "Odyssean Gauntlets",  --4
		legs	= "Odyssean Cuisses",	--5
	}
    sets.precast.WS = set_combine (sets.engaged,{
		neck = "Abyssal bead necklace +2",
		ear1 = "Moonshade Earring",
		ear2 = "Thrud earring",
		body = "Ignominy cuirass +2",
		ammo = "Oshasha's Treatise",
		})
	sets.precast.Chakra = { Body = ""}
	
    sets.precast.WS['Catastrophe'] = set_combine(sets.precast.ws, {
	
		})
	sets.precast.WS[''] = set_combine(sets.precast.ws, {

		})

    --- Midcast Sets ---
    sets.midcast = {}
	sets.midcast['Dark Magic'] = set_combine(sets.midcast, {
		head  	= "Fallen's burgeonet +2",
		neck	= "Erra Pendant",
		ring1	= "Evanescence Ring",
		})

    --- Engaged Sets ---
    sets.engaged = {
		head  	= "Hjarrandi helm",
		neck  	= "Abyssal bead necklace +2",
		ear1  	= "Mache earring +1",
		ear2  	= "Cessance Earring",
		body  	= "Hjarrandi breastplate",
		hands 	= "Sulevia's Gauntlets +2",
		ring1 	= "Chirich ring",
		ring2 	= "Petrov Ring",
		back  	= "Ankou's mantle",
		waist 	= "Sailfi belt +1",
		legs  	= "Sulevia's cuisses +2",
		feet  	= "Flamma gambieras +2",
		ammo	= "Coiste Bodhar",
		}

    sets.defense = {
		head  	= "Hjarrandi helm",
		neck  	= "Abyssal bead necklace +2",
		ear1  	= "Mache earring +1",
		ear2  	= "Thrud earring",
		body  	= "Hjarrandi breastplate",
		hands 	= "Sulevia's Gauntlets +2",
		ring1 	= "Flamma ring",
		ring2 	= "Warden's ring",
		back  	= "Ankou's mantle",
		waist 	= "Null Belt",
		legs  	= "Sulevia's cuisses +2",
		feet  	= "Flamma gambieras +2",
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