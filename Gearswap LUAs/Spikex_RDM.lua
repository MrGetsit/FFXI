function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
end
--	Ignis	Fire	Ice		Evasion Down	Paralyze 	Frost		Bind
--	Gelus	Ice		Wind	Defense Down	Gravity		Silence		Choke
--	Tellus	Earth	Electr	Magic D Down	Stun 		Shock
--	Sulpor	Electr	Water	Attack Down		Poison		Drown
--	Flabra	Wind	Earth	Accuracy Down	Petrify		Rasp		Slow
--	Unda	Water	Fire	M Attack Down	Amnesia		Plague		Addle		Burn
--	Lux		Light	Dark	M Evasion Down	Dispel 		Sleep		Blind
--	Tenebra Dark	Light	M Accuracy Down	Finale		Lullaby 	Charm	
function job_setup()	
	windower.send_command('sta !packets on') -- For SendTarget to work
	
    rune_enchantments = S{'Lux','Tenebrae', 'Ignis', 'Gelus', 'Flabra', 'Tellus', 'Sulpor', 'Unda' }
	
    state.WeaponLock = M(false, 'Weapon Lock')	
	state.WeaponSet = M{['description']='Weapon Set', 'Sword', 'Dual', 'Enspell', 'EnspellDW'}	
    state.OffenseMode:options('Normal', 'Defense')	
    state.Runes = M{['description']='Runes', 'Lux', 'Tenebrae','Ignis', 'Gelus', 'Flabra', 'Tellus', 'Sulpor', 'Unda' }
    send_command('bind @w gs c toggle WeaponLock')	
    send_command('bind %capslock gs c cycle WeaponSet')	
    --send_command('bind %capslock gs c toggleweapon')	
    send_command('bind @S gs c cycle OffenseMode')
	
	send_command('lua l xipivot')
	send_command('Pivot a NextHD')
end

function user_setup()		
	
	send_command('send @all bind %1   sta Spikex /SavageBlade')
	send_command('send @all bind !1   sta Spikex /SwiftBlade')
	send_command('send @all bind %2   sta Spikex /ChantDuCygne')
	send_command('send @all bind !2   sta Spikex /SeraphBlade')
	send_command('send @all bind %3   sta Spikex /SanguineBlade')
	send_command('send @all bind !3   sta Spikex /CircleBlade')
	send_command('send @all bind %4   sta Spikex /Cure4 <stpc>')
	send_command('send @all bind !4   sta Spikex /Cure3 <stpc>')
	send_command('send @all bind %5  send Spikex /Composure')
	send_command('send @all bind !5  send Spikex /Spontaneity')
	send_command('send @all bind ~%5 send Spikex /Haste2 <stpc>')
	send_command('send @all bind %6   sta Spikex /Regen2 <stpc>')
	send_command('send @all bind ~%6 send Spikex /Refresh3 <stpc>')
	send_command('send @all bind ~%1 send Spikex /Temper2')
	send_command('send @all bind ~%2 send Spikex /Phalanx')
	send_command('send @all bind ^%2 send Spikex /Phalanx2 <stpc>')
	send_command('send @all bind ~%3 send Spikex /GainStr')
	send_command('send @all bind ~%4 send Spikex /Enthunder')
	send_command('send @all bind %7 send Spikex /Blink')
	send_command('send @all bind %8 send Spikex /Stoneskin')
	send_command('send @all bind %9  send Spikex /Protect5 <stpc>')
	send_command('send @all bind %0  send Spikex /Shell5 <stpc>')
	send_command('send @all bind %e   sta Spikex /Dia3')
	send_command('send @all bind ~%e  sta Spikex /Saboteur')
	send_command('send @all bind ~^e  sta Spikex /Stymie')
	
	send_command('send @all bind %q   sta Spikex /Dispel')
	send_command('send @all bind !q   sta Spikex /Slow2')
	send_command('send @all bind ~%q  sta Spikex /Paralyze2')
	send_command('send @all bind ^%q  sta Spikex /Blind2')	
	send_command('send @all bind @%q  sta Spikex /Inundation')	
	send_command('send @all bind %z  send Spikex /Frazzle3')
	send_command('send @all bind !z  send Spikex /Distract3')
	send_command('send @all bind ~%z send Spikex /Silence')
	send_command('send @all bind ^%z send Spikex /Addle2')
	send_command('send @all bind %` send Spikex /Sleep2')
	send_command('send @all bind !` send Spikex /Sleep2 <stnpc>')
	send_command('send @all bind %~` send Spikex /Break')
	
	if player.sub_job == 'SCH' then
		send_command('lua l stna')
		send_command('send @all bind %x send Spikex /Accession')
		send_command('send @all bind !x send Spikex /LightArts')
		send_command('send @all bind @x send Spikex /AddendumWhite')
		send_command('send @all bind @4 send Spikex /Thunderstorm')
		send_command('send @all bind ^x  send Spikex /stna <stpc>')
		send_command('send @all bind %c send Spikex /Manifestation')
		send_command('send @all bind !c send Spikex /DarkArts')
		send_command('send @all bind @c send Spikex /AddendumBlack')
	elseif player.sub_job == 'WAR' then
		send_command('send @all bind !z  send Spikex /Defender')
		send_command('send @all bind %x  send Spikex /Berserk')
		send_command('send @all bind ~%x send Spikex /Warcry')
		send_command('send @all bind !e  sta Spikex /Provoke <stnpc>')
	elseif player.sub_job == 'RUN' then
		send_command('send @all bind !z  send Spikex /Swordplay')
		send_command('send @all bind %x  send Spikex gs c rune')
		send_command('send @all bind ~%x send Spikex gs c cycle Runes')
		send_command('send @all bind ^x  send Spikex gs c cycleback Runes')
		send_command('send @all bind !x  send Spikex /Vallation')
		send_command('send @all bind @x  send Spikex /Pflug')
	elseif player.sub_job == 'NIN' then
		send_command('send @all bind %x  send Spikex /UtsusemiNi')
		send_command('send @all bind !x  send Spikex /UtsusemiIchi')
	end
	
	if player.sub_job == 'NIN' then	
		send_command('gs c set WeaponSet Dual')
	else
		send_command('gs c set WeaponSet Sword')
	end
	
	send_command('wait 5; input /lockstyleset 3')
end

function init_gear_sets()
    --- Weapon Sets ---
    sets.Sword		= 	{ main="Naegling", 			sub="Diamond Aspis"}
    sets.Dual 		= 	{ main="Naegling", 			sub="Daybreak"}
    sets.Enspell	= 	{ main="Qutrub Knife", 		sub="Diamond Aspis"}
    sets.EnspellDW	= 	{ main="Qutrub Knife", 		sub="Ceremonial Dagger"}
		
	gear.CapeDT = { name="Rudianos's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity+10','Phys. dmg. taken-10%',} }
	gear.CapeFC = { name="Rudianos's Mantle", augments={'"Fast Cast"+10','Spell interruption rate down-10%',} }
	
    --- Precast Sets ---
    sets.precast.JA['Holy Circle'] = {feet="Gallant Leggings"}
    sets.precast.JA['Shield Bash'] = {ear1="Knightly Earring",hands="Cab. Gauntlets +2"}
    sets.precast.JA['Sentinel'] = {feet="Caballarius Leggings"}
    sets.precast.JA['Rampart'] = {head="Valor Coronet +2"}
    sets.precast.JA['Divine Emblem'] = {feet="Chev. Sabatons +3"}
    sets.precast.JA['Chivalry'] = {hands="Cab. Gauntlets +2"} 
    --sets.precast.JA['Invincible'] = {legs="Caballarius Breeches"} 
	
    sets.precast.WS = set_combine(sets.engaged, {})
	sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {
		ammo	= "Oshasha's Treatise",
		head  	= "Leth. Chappel +2",
        neck	= "Rep. Plat. Medal",
		ear2	= "Moonshade earring",
		ring1	= "Ruby Ring",
		--ring2	= "Cornelia's Ring",
		feet  	= "Sulevia's Leggings +1",
		})
	sets.precast.WS['Sanguine Blade'] = set_combine(sets.precast.WS, {neck="Sibyl Scarf"})
	
    sets.precast.FC = {						-- 49 + 38
		ammo  	= "Sapience Orb",			-- 2
		head  	= "Atro. Chapeau +1",		-- 12
		ear1  	= "Malignance Earring",		-- 4
		ear2  	= "Lethargy Earring",		-- 7
		--hands	= "Leyline Gloves",       	-- 7
		ring1	= "Prolix Ring",			-- 2
		ring2	= "Weather. Ring",			-- 5
		back  	= "Sucellos's Cape",		-- 10
		}       
		
    --- Midcast Sets ---					
    sets.midcast = {}					
    sets.midcast['Enfeebling Magic'] = {
        range	= "Ullr",
		head  	= "Null Masque",
		neck  	= "Dls. Torque +2",
		ear1  	= "Malignance Earring",
		ear2  	= "Lethargy Earring",
		body  	= "Lethargy Sayon +2",
		hands 	= "Leth. Ganth. +2",
		ring1 	= "Etana Ring",
		ring2 	= "Metamor. Ring +1",
		back  	= "Sucellos's Cape",
		waist 	= "Null Belt",
		legs  	= "Leth. Fuseau +2",
		feet  	= "Leth. Houseaux +2",
		}						
    sets.midcast['Enhancing Magic'] = {
        ammo	= "Homiliary",
		head  	= "Leth. Chappel +2",
		neck  	= "Dls. Torque +2",
		ear1  	= "Malignance Earring",
		ear2  	= "Lethargy Earring",
		body  	= "Lethargy Sayon +2",
		hands 	= "Leth. Ganth. +2",
		ring1 	= "Etana Ring",
		ring2 	= "Metamor. Ring +1",
		back  	= "Sucellos's Cape",
		waist 	= "Null Belt",
		legs  	= "Leth. Fuseau +2",
		feet  	= "Leth. Houseaux +2",
		}									
    sets.midcast.Cure = set_combine(sets.midcast, {}) 
    sets.midcast['Refresh'] = set_combine(sets.midcast['Enhancing Magic'], {
		body  	= "Atrophy Tabard +3",
	})
	
    --- Engaged Sets ---
    sets.engaged = {
        ammo	= "Homiliary",
		head  	= "Malignance Chapeau",
		neck  	= "Null Loop",
		ear1  	= "Malignance Earring",
		ear2  	= "Lethargy Earring",
		body  	= "Lethargy Sayon +2",
		hands 	= "Leth. Ganth. +2",
		ring1 	= "Gurebu's Ring", 
		ring2 	= "Rajas Ring",
		back  	= "Sucellos's Cape",
		waist 	= "Null Belt",
		legs  	= "Leth. Fuseau +2",
		feet  	= "Leth. Houseaux +2",
		}
		
    sets.defense = {
        ammo	= "Homiliary",
		head  	= "Null Masque",
		neck  	= "Null Loop",
		ear1  	= "Tuisto Earring",
		ear2  	= "Eabani Earring",
		body  	= "Lethargy Sayon +2",
		hands 	= "Leth. Ganth. +2",
		ring1 	= "Gurebu's Ring", 
		ring2 	= "Murky Ring",
		back  	= "Sucellos's Cape",
		waist 	= "Plat. Mog. Belt",
		legs  	= "Leth. Fuseau +2",
		feet  	= "Leth. Houseaux +2",
		}
		
    --- Other Sets ---
    sets.idle = set_combine(sets.defense, { head="Null Masque", ammo="Homiliary"})
    sets.idle.Town = set_combine(sets.idle, {ring1="Warp Ring", ring2="Dim. Ring (Holla)"})	    
	
	sets.buff.Doom = {
        neck="Nicander's Necklace", --30
        ring1="Blenmot's Ring", --5
        ring1="Blenmot's Ring", --5
        waist="Gishdubar Sash", --10
        }
end

function job_post_precast(spell, action, spellMap, eventArgs)
	if spell.type == "WeaponSkill" and player.tp >= 2950 then
		equip({ear2="Ishvara Earring"})	
	end
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
            send_command('@input /p Doom Removed')
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
	equip(customize_melee_set())
end
function job_state_change(field, new_value, old_value)
    if state.WeaponLock.value == true then
        disable('main','sub')
    else
        enable('main','sub')
    end
	--if state.WeaponSet.value == "DPS" then
	--	send_command('send @all bind %1  sta Spikex /SavageBlade')
	--	send_command('send @all bind !1  sta Spikex /SwiftBlade')
	--	send_command('send @all bind %2  sta Spikex /ChantDuCygne')
	--	send_command('send @all bind !2  sta Spikex /Atonement')
	--elseif state.WeaponSet.value == "Club" then
	--	send_command('send @all bind %1  sta Spikex /BlackHalo')
	--	send_command('send @all bind !1  sta Spikex /HexaStrike')
	--	send_command('send @all bind %2  sta Spikex /FlashNova')
	--	send_command('send @all bind !2  sta Spikex /Moonlight')
	--end
    equip(sets[state.WeaponSet.current])
	equip(customize_melee_set())
end
function job_update(cmdParams, eventArgs)
    equip(sets[state.WeaponSet.current])
end
function job_self_command(cmdParams, eventArgs)
    if cmdParams[1]:lower() == 'rune' then
        send_command('@input /ja '..state.Runes.value..' <me>')
	end
end