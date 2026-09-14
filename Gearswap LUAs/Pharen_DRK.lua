function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
end

function job_setup()	
	windower.send_command('sta !packets on') -- For SendTarget to work
	
    state.WeaponLock = M(false, 'Weapon Lock')	
	state.WeaponSet = M{['description']='Weapon Set','Caladbolg','Apocalypse','Lycurgos'}
    state.OffenseMode:options('Normal', 'Defense')
    send_command('bind @w gs c toggle WeaponLock')	
    send_command('bind %capslock gs c cycle WeaponSet')	
    send_command('bind @S gs c cycle OffenseMode')
end

function user_setup()
	setup_weapon_keybinds()
	send_command('send @all alias as send Pharen /Absorb-Str')
	send_command('send @all alias av send Pharen /Absorb-Vit')
	send_command('send @all alias ai send Pharen /Absorb-Int')
	send_command('send @all alias atp send Pharen /Absorb-Tp')
	send_command('send @all alias aat send Pharen /Absorb-Attri') 
	send_command('send @all alias aa send Pharen /Absorb-Acc') 
	send_command('send @all alias ds send Pharen /Dread Spikes')
	send_command('send @all alias sleep send Pharen /Sleep2')
	send_command('send @all alias bio send Pharen /Bio2')
	send_command('send @all alias aspir send Pharen /Aspir2') 
	send_command('send @all alias ed send Pharen /Endark2')
	send_command('send @all alias s send Pharen /Stun')
	send_command('send @all alias f send Pharen /Fire') 
	
	send_command('wait 5; input /lockstyleset 2') 
end


function init_gear_sets()
    --- Weapon Sets ---
	sets.Caladbolg 	= { main="Caladbolg", 	sub="utu grip"}
	sets.Apocalypse = { main="Apocalypse", 	sub="utu grip"}
	sets.Lycurgos	= { main="Lycurgos", 	sub="utu grip"}
	
	gear.TPCape ={ name="Ankou's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','"Dbl.Atk."+10','Phys. dmg. taken-10%',}}
	gear.STRWS  ={ name="Ankou's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%',}}
	gear.OdyFC	={ name="Odyssean Gauntlets", augments={'Accuracy+19','"Fast Cast"+4','Attack+13',}}
    gear.OdyWS  ={ name="Odyssean Gauntlets", augments={'Mag. Acc.+2 "Mag.Atk.Bns."+2','Weapon skill damage +3%','Phalanx +2','Accuracy+15 Attack+15',}}
	
	
   --- Precast Sets ---	
	sets.precast.JA['Dark Seal'] = {head="Fallen's Burgeonet +4"}
	sets.precast.JA['Nether Void'] = {legs="Heathen's Flanchards +3"}
	
    sets.precast.FC = {
		ear1	= "Loquacious earring",		--2
		ear2	= "Malignance Earring", 	--4
		ammo 	= "Sapience Orb",			--2
		hands	= gear.OdyFC,  				--4
		legs	= "Eschite Cuisses",		--5
		feet	= "Odyssean Greaves",		--10
		ring2	= "Kishar ring",			--4
	}
	
    sets.precast.WS = {
		ammo 	= "Knobkierrie",
		head	= "Fallen's burgeonet +4",
		neck 	= "Abyssal bead necklace +2",
		ear1	= "Moonshade Earring",
		ear2	= "Thrud earring",
		body	= "Ignominy cuirass +4",
		hands 	= gear.OdyWS,
		ring1	= "Regal Ring",
		ring2	= "Cornelia's Ring",
		back 	= gear.STRWS,
		waist 	= "Sailfi belt +1",
		legs 	= "Fallen's Flanchard +4",
		feet 	= "Heathen's Sollerets +3",
		}
		
	sets.precast.WS['Catastrophe'] = set_combine(sets.precast.WS, {
		head	= "Ratri Sallet +1",
		})		
	sets.precast.WS['Cross Reaper'] = sets.precast.WS['Catastrophe']

    --- Midcast Sets ---
	sets.midcast['Dark Magic'] = {
		ammo 	= "Sapience Orb",
		head  	= "Fallen's burgeonet +4",
		neck	= "Erra Pendant",
		ear1	= "Malignance earring",
		ear2	= "Crepuscular Earring",
		body	= "Ignominy Cuirass +4",
		hands	= "Fallen's Finger gauntlets +1",
		ring1	= "Evanescence Ring",
		ring2	= "Kishar ring",
		back	= "Niht Mantle",
		waist 	= "Null Belt",
		legs	= "Heathen's Flanchards +3",
		feet	= "Ratri Sollerets",
		}
		
	sets.midcast.Absorb = set_combine(sets.midcast['Dark Magic'], {
		ring2	= "Kishar Ring", })

    --- Engaged Sets ---
    sets.engaged = {
		head  	= "Hjarrandi helm",
		neck  	= "Abyssal bead necklace +2",
		ear1  	= "Alabaster Earring",
		ear2  	= "Cessance Earring",
		body  	= "Hjarrandi breastplate",
		hands 	= "Sakpata's gauntlets",
		ring1 	= "Niqmaddu Ring",
		ring2 	= "Petrov Ring",
		back  	= gear.TPCape,
		waist 	= "Sailfi belt +1",
		legs  	= "Ignominy Flanchard +4",
		feet  	= "Flamma gambieras +2",
		ammo	= "Coiste Bodhar",
		}

    sets.defense = {
		head  	= "Hjarrandi helm",
		neck  	= "Abyssal bead necklace +2",
		ear1  	= "Alabaster Earring",
		ear2  	= "Thrud earring",
		body  	= "Hjarrandi breastplate",
		hands 	= "Sakpata's gauntlets",
		ring1 	= "Niqmaddu Ring",
		ring2 	= "Warden's ring",
		back  	= gear.TPCape,
		waist 	= "Platinum moogle belt",
		legs  	= "Sakpata's cuisses",
		feet  	= "Sakpata's leggings",
		ammo	= "Coiste Bodhar",
        }

    --- Other Sets ---
    sets.idle = sets.defense
    sets.idle.Town = set_combine(sets.idle, {ring1="Warp Ring", ring2="Dim. Ring (Holla)"})	 
end
function setup_weapon_keybinds()
	local main = state.WeaponSet.value
	
	send_command('send @all bind numpad6 send Pharen /Hasso')
	
	if main == 'Caladbolg' then
		send_command('send @all bind  numpad4 send Pharen /Torcleaver')
		send_command('send @all bind  numpad5 send Pharen /Resolution')
		send_command('send @all bind !numpad4 send Pharen /SickleMoon')
	
	elseif main == 'Apocalypse' then
		send_command('send @all bind  numpad4 send Pharen /Catastrophe')
		send_command('send @all bind  numpad5 send Pharen /CrossReaper')
		send_command('send @all bind !numpad4 send Pharen /Insurgency')
	
	elseif main == 'Lycurgos' then
		send_command('send @all bind  numpad4 send Pharen /ArmorBreak')
		send_command('send @all bind  numpad5 send Pharen /WeaponBreak')
		send_command('send @all bind !numpad4 send Pharen /Upheaval')
	
	elseif main == 'Maxentius' then
		send_command('send @all bind  numpad4 send Pharen /BlackHalo')
	end
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
		equip(sets[state.WeaponSet.current])
    end
	if field == 'Weapon Set' then 
		setup_weapon_keybinds()
	end
end
function job_update(cmdParams, eventArgs)
    equip(sets[state.WeaponSet.current])
end