function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
end

function job_setup()	
	windower.send_command('sta !packets on') -- For SendTarget to work
	
    state.WeaponLock = M(false, 'Weapon Lock')	
	state.WeaponSet = M{['description']='Weapon Set', 'DPS', 'Tank', 'Club'}	
    state.OffenseMode:options('Normal', 'Defense')
    send_command('bind @w gs c toggle WeaponLock')	
    send_command('bind %capslock gs c cycle WeaponSet')	
    send_command('bind @S gs c cycle OffenseMode')
end

function user_setup()
	
	send_command('send @all bind %1  sta Spikex /SavageBlade')
	send_command('send @all bind !1  sta Spikex /SwiftBlade')
	send_command('send @all bind %2  sta Spikex /ChantDuCygne')
	send_command('send @all bind !2  sta Spikex /Atonement')
	send_command('send @all bind %3  sta Spikex /CircleBlade')
	send_command('send @all bind !3  sta Spikex /SanguineBlade')
	send_command('send @all bind %4  sta Spikex /Cure4 <stpc>')
	send_command('send @all bind !4  sta Spikex /Cure3 <stpc>')
	send_command('send @all bind %5 send Spikex /Majesty')
	send_command('send @all bind !5 send Spikex /Chivalry')
	send_command('send @all bind %e  sta Spikex /Flash <stnpc>')
	send_command('send @all bind ~e  sta Spikex /DivineEmblem')
	send_command('send @all bind ~1 send Spikex /Crusade')
	send_command('send @all bind ~2 send Spikex /Phalanx')
	send_command('send @all bind ~3 send Spikex /Reprisal')
	send_command('send @all bind ~4 send Spikex /Enlight2')
	send_command('send @all bind %9 send Spikex /Protect5')
	send_command('send @all bind %0 send Spikex /Shell4')
	send_command('send @all bind %q  sta Spikex /ShieldBash')
	send_command('send @all bind !q  sta Spikex /FlatBlade')
	send_command('send @all bind %z send Spikex /Sentinel')
	send_command('send @all bind ~z send Spikex /Rampart')
	send_command('send @all bind ^z send Spikex /Palisade')
	send_command('send @all bind %c  sta Spikex /Cover <stpc>')
	send_command('send @all bind !c send Spikex /Invincible')
	send_command('send @all bind ~c send Spikex /Intervene')
	
	if player.sub_job == 'WAR' then
		send_command('send @all bind !z send Spikex /Defender')
		send_command('send @all bind %x send Spikex /Berserk')
		send_command('send @all bind ~x send Spikex /Warcry')
		send_command('send @all bind !e  sta Spikex /Provoke <stnpc>')
	elseif player.sub_job == 'BLU' then
		send_command('send @all bind !z send Spikex /Cocoon')
		send_command('send @all bind !e send Spikex /Jettatura')
		send_command('send @all bind %x send Spikex /CursedSphere')
	elseif player.sub_job == 'NIN' then
		send_command('send @all bind %x send Spikex /UtsusemiNi')
		send_command('send @all bind !x send Spikex /UtsusemiIchi')
	end
	
	send_command('wait 5; input /lockstyleset 1')
end

function init_gear_sets()
    --- Weapon Sets ---
    sets.DPS 	= 	{ main="Kaja Sword", 	sub="Priwen"}
    sets.Tank 	= 	{ main="Nixxer", 		sub="Priwen"}
    sets.Club 	= 	{ main="Brass Jadagna", sub="Priwen"}	
	
    --- Precast Sets ---
    sets.precast.JA['Invincible'] = {legs="Caballarius Breeches"}
    sets.precast.JA['Holy Circle'] = {feet="Reverence Leggings +1"}
    sets.precast.JA['Shield Bash'] = {ear1="Knightly Earring"}
    sets.precast.JA['Sentinel'] = {feet="Caballarius Leggings"}
    sets.precast.JA['Rampart'] = {head="Caballarius Coronet"}
    sets.precast.JA['Fealty'] = {body="Caballarius Surcoat"}
    sets.precast.JA['Divine Emblem'] = {feet="Creed Sabatons +2"}
    sets.precast.JA['Cover'] = {head="Reverence Coronet +1"}    
    sets.precast.JA['Chivalry'] = { }  -- add mnd for Chivalry 
    sets.precast.WS = {
		ear1	= "Moonshade earring",
		feet  	= "Sulevia's Leggings +1",
		}
	sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {})
    sets.precast.FC = {
		ring1	= "Prolix Ring",			-- 2
		ring2	= "Weather. Ring",			-- 5
		back	= "Rudianos's Mantle",		-- 5
		feet	= "Odyssean Greaves",		-- 7
		}       
		
    --- Midcast Sets ---
    sets.midcast = {						-- 95 + 10
        ammo	= "Staunch Tathlum",		-- 10
        head	= "Eschite Helm",			-- 15
        neck	= "Moonbeam Necklace",		-- 10
		ear1	= "Knightly Earring",		-- 9
		back	= "Rudianos's Mantle",		-- 10
		waist	= "Tarutaru sash",			-- 6
		legs	= "Eschite Cuisses",		-- 15
		feet	= "Odyssean Greaves",		-- 20
		}
    sets.midcast.Cure = set_combine(sets.midcast, {})
    sets.midcast['Phalanx'] = set_combine(sets.midcast, {})
	
    --- Engaged Sets ---
    sets.engaged = {
        ammo	= "Staunch Tathlum",
		head  	= "Flam. Zucchetto +2",
		neck  	= "Sanctity Necklace",
		ear1  	= "Eabani Earring",
		ear2  	= "Bloodbead Earring",
		body  	= "Sulevia's Plate. +2",
		hands 	= "Sulevia's Gauntlets +2",
		ring1 	= "Sulevia's Ring",
		ring2 	= "Rajas Ring",
		back  	= "Rudianos's mantle",
		waist 	= "Sailfi Belt +1",
		legs  	= "Sulevia's Cuisses +2",
		feet  	= "Flam. Gambieras +2",
		}
		
    sets.defense = {
        ammo	= "Staunch Tathlum",
		head  	= "Sulevia's Mask +1",
		neck  	= "Sanctity Necklace",
		ear1  	= "Eabani Earring",
		ear2  	= "Ethereal Earring",
		body  	= "Sulevia's Plate. +2",
		hands 	= "Sulevia's Gauntlets +2",
		ring1 	= "Sulevia's Ring",
		ring2 	= "Etana Ring",
		back  	= "Rudianos's mantle",
		waist 	= "Creed Baudrier",
		legs  	= "Sulevia's Cuisses +2",
		feet  	= "Sulevia's Leggings +1",
		}
		
    --- Other Sets ---
    sets.idle = sets.defense
    sets.idle.Town = set_combine(sets.engaged, {ring1="Warp Ring", ring2="Dim. Ring (Holla)"})	    
	
	sets.buff.Doom = {
        neck="Nicander's Necklace", --30
        ring1="Blenmot's Ring", --5
        ring1="Blenmot's Ring", --5
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