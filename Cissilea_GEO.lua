function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
end

--------------------------------------------------------		
--				7				8				9			--
-- 			HexaStrike		IndiBuff		GeoBuff		--
--	ALT		Moonlight		EntrustBuff	SuperBuff		--
-- 	SHFT	AoE				Refsh/DivineS	Cure4<st>		--
-- 	CTRL	Clnse/Slow		Clns2/Paraly	Bars/Silenc	--
-- 	WIN		Nuke			Haste			Sleep			--
--															--
--------------------------------------------------------	

function job_setup()	
	windower.send_command('sta !packets on') -- For SendTarget to work
	
    state.WeaponLock = M(false, 'Weapon Lock')	
	state.WeaponSet = M{['description']='Weapon Set', 'Solstice', 'Rod'}
    state.OffenseMode:options('Normal', 'Defense')
    send_command('bind @w gs c toggle WeaponLock')	
    send_command('bind %capslock gs c cycle WeaponSet')	
    send_command('bind @S gs c cycle OffenseMode')
	
	indiBuff	= 'IndiHaste'
	entrustBuff = 'IndiFury'
	geoBuff		= 'GeoFrailty'
	cleanse 	= 'Cursna'
	cleanse2 	= 'Paralyna'
	barspellra	= 'Barblizzra'
	nuke		= 'Thunder5'
	
end
function testingu()
	print('testingu')
end
function user_setup()
	send_command('send @all bind  numpad7  sta Cissilea HexaStrike') 
	send_command('send @all bind  numpad8 send Cissilea '..indiBuff) 
	send_command('send @all bind  numpad9 send Cissilea '..geoBuff) 
	send_command('send @all bind !numpad7  sta Cissilea Moonlight') 
	send_command('send @all bind !numpad8 send Cissilea gs c entrustbuff')
	send_command('send @all bind !numpad9 send Cissilea gs c superbuff')	
	send_command('send @all bind ~numpad7 send Cissilea gs c aoe')		
	send_command('send @all bind ~numpad9  sta Cissilea Cure4 <stpc>') 
	send_command('send @all bind @numpad7  sta Cissilea '..nuke) 
	send_command('send @all bind @numpad8  sta Cissilea Haste <stpc>') 
	send_command('send @all bind @numpad9  sta Cissilea Sleep2 <stnpc>') 
	
	if player.sub_job == 'WHM' then 
		send_command('send @all bind ~numpad8 send Cissilea DivineSeal') 	
		send_command('send @all bind ^numpad7  sta Cissilea /'..cleanse..' <stpc>') 
		send_command('send @all bind ^numpad8  sta Cissilea /'..cleanse2..' <stpc>') 
		send_command('send @all bind ^numpad9 send Cissilea '..barspellra) 
	elseif player.sub_job == 'RDM' then
		send_command('send @all bind ~numpad8  sta Cissilea Refresh <stpc>') 
		send_command('send @all bind ^numpad7  sta Cissilea Slow <stnpc>') 
		send_command('send @all bind ^numpad8  sta Cissilea Paralyze <stnpc>') 
		send_command('send @all bind ^numpad9  sta Cissilea Silence <stnpc>') 
	end
	
	send_command('wait 5; input /lockstyleset 1') 
end

function init_gear_sets()
    --- Weapon Sets ---
    sets.Solstice 	= 	{ main="Solstice"}
    sets.Rod 		= 	{ main="Trial Wand"}

    --- Precast Sets ---	
    sets.precast.FC = {
		ring2 	= "Jhakri Ring",
		feet  	= "Jhakri Pigaches +2",
		}
	sets.precast.FC['Elemental Magic'] = set_combine(sets.precast.FC, {
		head  	= "Mallquis Chapeau +1",
		neck	= "Stoicheion Medal",
		body  	= "Jhakri Robe +2",
		hands 	= "Mallquis Cuffs +1",
		legs  	= "Mallquis Trews +1",
		feet  	= "Mallquis Clogs +2",
		ring1	= "Mallquis Ring",
		})
    sets.precast.WS = { 
		ear1	= "Moonshade earring",
		}
    sets.precast.WS['Hexa Strike'] = {}

    --- Midcast Sets ---
    sets.midcast = { 
		ring2  	= "Adoulin ring",
		}
    sets.midcast['Elemental Magic'] = set_combine(sets.midcast, {
		head  	= "Mallquis Chapeau +1",
		neck	= "Stoicheion Medal",
		ear1  	= "Static Earring",
		ear2  	= "Friomisi Earring",
		body  	= "Jhakri Robe +2",
		hands 	= "Mallquis Cuffs +1",
		legs  	= "Mallquis Trews +1",
		feet  	= "Mallquis Clogs +2",
		ring1	= "Mallquis Ring",
		})
    sets.midcast.Cure = set_combine(sets.midcast, {})

    --- Engaged Sets ---
    sets.engaged = {
		range	= "Dunna",
		head  	= "Jhakri Coronal +2",
		neck  	= "Sanctity Necklace",
		ear1  	= "Vor Earring",
		ear2  	= "Flashward Earring",
		body  	= "Jhakri Robe +2",
		hands 	= "Jhakri Cuffs +2",
		ring1 	= "Etana Ring",
		ring2 	= "Rajas Ring",
		back  	= "Nantosuelta's Cape", 
		waist 	= "Witful Belt",
		legs  	= "Jhakri Slops +2",
		feet  	= "Mallquis Clogs +2",
		}

    sets.defense = {
		range	= "Dunna",
		head  	= "Jhakri Coronal +2",
		neck  	= "Sanctity Necklace",
		ear1  	= "Vor Earring",
		ear2  	= "Flashward Earring",
		body  	= "Jhakri Robe +2",
		hands 	= "Jhakri Cuffs +2",
		ring1 	= "Etana Ring",
		ring2  	= "Adoulin ring",
		back  	= "Nantosuelta's Cape", 
		waist 	= "Witful Belt",
		legs  	= "Jhakri Slops +2",
		feet  	= "Mallquis Clogs +2",
		}

    --- Other Sets ---
    sets.idle = sets.defense
    sets.idle.Town = set_combine(sets.idle, {ring1="Warp Ring", ring2="Dim. Ring (Holla)"})	 
end
function job_self_command(cmdParams, eventArgs)
    if cmdParams[1]:lower() == 'entrustbuff' then
		send_command('Entrust')
		send_command('wait 1; '..entrustBuff..' Pharen')
    elseif cmdParams[1]:lower() == 'superbuff' then
		send_command('BlazeOfGlory')
		send_command('wait 1; '..geoBuff..'')
		send_command('wait 5; EclipticAttrition')
		send_command('wait 6; LifeCycle')
		send_command('wait 7; Dematerialize')
    elseif cmdParams[1]:lower() == 'aoe' then
		send_command('Thundara2')
		send_command('wait 1; Blizzara2')
		send_command('wait 2; Fira2')
		send_command('wait 3; Aera2')
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
    end
    equip(sets[state.WeaponSet.current])
end
function job_update(cmdParams, eventArgs)
    equip(sets[state.WeaponSet.current])
end