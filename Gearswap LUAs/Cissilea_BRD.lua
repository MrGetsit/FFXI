function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
end

function job_setup()	
	windower.send_command('sta !packets on') -- For SendTarget to work
	
    state.WeaponLock = M(false, 'Weapon Lock')	
	state.WeaponSet = M{['description']='Weapon Set','Club', 'Dagger'}
    state.OffenseMode:options('Normal', 'Defense')
    send_command('bind @w gs c toggle WeaponLock')	
    send_command('bind %capslock gs c cycle WeaponSet')	
    send_command('bind @S gs c cycle OffenseMode')
end
-- % Normal	^ Ctrl	! Alt	@ Win	# Apps	~ Shift

function user_setup()
	--send_command('send @all bind  numpad7 send Cissilea /Victory March') 
	send_command('send @all bind  numpad7 send Cissilea /Herculean Etude') 
	send_command('send @all bind  numpad8 send Cissilea /Valor Minuet 5')
	send_command('send @all bind  numpad9 send Cissilea /Valor Minuet 4')
	send_command('send @all bind ~numpad.  sta Cissilea /Horde Lullaby')
	send_command('send @all bind ^numpad.  sta Cissilea /Horde Lullaby 2')
	
	send_command('wait 5; input /lockstyleset 2') 
end


function init_gear_sets()
    --- Weapon Sets ---
	sets.Dagger	=	{ main="Kali", sub="Culminus"}
	sets.Club 	= 	{ main="Daybreak", sub="Culminus"}

	gear.FCcape	={ name="Intarabus's Cape", augments={'CHR+20','Mag. Acc+20 /Mag. Dmg.+20','"Fast Cast"+10',}}	
	
   --- Precast Sets ---	
    sets.precast.FC = {
		head	= "Fili Calot +3",				--16
		body	= "Inyanga Jubbah +2",			--14
		legs	= "Ayanmo Cosciales +2",		--6
		ring2	= "Kishar ring",				--4
		feet	= "Fili Cothurnes +2",			-- 10
		back	= gear.FCcape,					--10
	}
	
	sets.precast.FC['Healing Magic'] = set_combine(sets.precast.FC, {
		neck	= "Orunmila's Torque",
		ear2	= "Malignance earring",
		head	= "Vanya Hood",
		legs	= "Vanya Slops",
		feet	= "Vanya Clogs",
		})
	
    sets.precast.WS = {	}	

    --- Midcast Sets ---	
	sets.midcast = {
		range	= "Miracle Cheer",
		head	= "Fili Calot +3",
		neck	= "Mnbw. Whistle +1",
		body	= "Fili Hongreline +2",
		hands	= "Fili Manchettes +2",
		legs	= "Inyanga Shalwar +2",
		feet	= "Brioso Slippers +3",
		}

	sets.midcast['Lullaby'] = set_combine(sets.midcast, {
		range	= "Blurred Harp",
		head	= "Brioso Roundlet +3",
		ear1	= "Gersemi Earring",
		body	= "Brioso Justaucorps +3",
		hands	= "Brioso cuffs +3",
		legs	= "Inyanga Shalwar +2",
		feet	= "Brioso Slippers +3",
		})

	sets.midcast['Healing Magic'] = set_combine(sets.midcast, {
		head	= "Vanya Hood",
		legs	= "Vanya Slops",
		feet	= "Vanya Clogs",
		})

    --- Engaged Sets ---
    sets.engaged = {
		head	="Fili Calot +3",
		body	="Fili Hongreline +2",
		hands	="Fili Manchettes +2",
		legs	="Aya. Cosciales +2",
		feet	="Coalrake Sabots",
		neck	="Null Loop",
		waist	="Null Belt",
		ear1	="Alabaster Earring",
		ear2	="Fili earring +1",
		ring1	="Rajas Ring",
		ring2	="Gurebu's Ring",
		back	=gear.FCcape,
		}

    sets.defense = {
		head	="Null Masque",
		body	="Fili Hongreline +2",
		hands	="Fili Manchettes",
		legs	="Aya. Cosciales +2",
		feet	="Coalrake Sabots",
		neck	="Null Loop",
		waist	="Null Belt",
		ear1	="Alabaster Earring",
		ear2	="Fili earring +1",
		ring1	="Adoulin ring",
		ring2	="Gurebu's Ring",
		back	=gear.FCcape,
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