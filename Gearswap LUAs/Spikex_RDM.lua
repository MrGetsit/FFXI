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
	barstatus = S{'Baramnesia', 'Barvirus', 'Barparalyze', 'Barsilence', 'Barpetrify', 'Barpoison', 'Barblind', 'Barsleep'} 
	
    state.WeaponLock = M(false, 'Weapon Lock')	
	state.WeaponSet = M{['description']='Weapon Set', 'Sword', 'Dual', 'Enspell', 'EnspellDW'}
    state.OffenseMode:options('Normal', 'Defense')
    state.Runes = M{['description']='Runes', 'Lux', 'Tenebrae','Ignis', 'Gelus', 'Flabra', 'Tellus', 'Sulpor', 'Unda' }
    send_command('bind @w gs c toggle WeaponLock')
    send_command('bind %capslock gs c cycle WeaponSet')
    --send_command('bind %capslock gs c toggleweapon')	
    send_command('bind @S gs c cycle OffenseMode')
	
    enfeebling_mnd = S{'Paralyze', 'Paralyze II', 'Addle', 'Addle II', 'Slow', 'Slow II'}
    enfeebling_skill = S{'Distract III', 'Frazzle III', 'Poison', 'Poison II'}
    enfeebling_accuracy = S{'Frazzle II', 'Dispel'}
    enfeebling_duration = S{'Sleep', 'Sleep II', 'Sleepga', 'Bind', 'Break', 'Silence', 'Inundation'}

    skill_spells = S{
        'Temper', 'Temper II', 'Enfire', 'Enfire II', 'Enblizzard', 'Enblizzard II', 'Enaero', 'Enaero II',
        'Enstone', 'Enstone II', 'Enthunder', 'Enthunder II', 'Enwater', 'Enwater II'}
		
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
		send_command('lua l StratagemCounter')
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
		
	gear.CapeMND = { name="Sucellos's Cape", augments={'MND+20','Mag. Acc+20 /Mag. Dmg.+20','MND+10','"Fast Cast"+10','Phys. dmg. taken-10%',} }
	gear.CapeWSD = { name="Sucellos's Cape", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%',} }
	
	sets.precast.WS = {
		ammo	= "Oshasha's Treatise",
		head  	= "Viti. Chapeau +3",
		neck	= "Sibyl Scarf",
		ear1	= "Malignance earring",
		ear2	= "Moonshade earring",
		body	= "Lethargy Sayon +3",
		hands	= "Leth. Ganth. +3",
		ring1	= "Gurebu's Ring",
		ring2 	= "Metamor. Ring +1",
		back	= gear.CapeWSD,
		waist	= "Eschan Stone",
		legs	= "Leth. Fuseau +3",
		feet  	= "Leth. Houseaux +2",
		}
	
	sets.precast.WS['Savage Blade'] = {
		ammo	= "Oshasha's Treatise",
		head  	= "Viti. Chapeau +3",
		neck	= "Rep. Plat. Medal",
		ear1	= "Ishvara earring",
		ear2	= "Moonshade earring",
		body	= "Lethargy Sayon +3",
		hands	= "Jhakri cuffs +2",
		ring1	= "Petrov Ring",
		ring2	= "Rajas Ring",
		back	= gear.CapeWSD,
		waist	= "Sailfi Belt +1",
		legs	= "Leth. Fuseau +3",
		feet  	= "Leth. Houseaux +2",
		})
	sets.precast.WS['Sanguine Blade'] = set_combine(sets.precast.WS, {ear2="Friomisi Earring"})
	
    sets.precast.FC = {						-- 49 + 38
		ammo  	= "Sapience Orb",			-- 2
		head  	= "Atro. Chapeau +1",		-- 12
		ear1  	= "Malignance Earring",		-- 4
		ear2  	= "Lethargy Earring",		-- 7
		--hands	= "Leyline Gloves",       	-- 7
		ring1	= "Prolix Ring",			-- 2
		ring2	= "Weather. Ring",			-- 5
		back  	= gear.CapeMND,		-- 10
		}
		
    --- Midcast Sets ---
    sets.midcast['Elemental Magic'] = {
        sub		= "Ammurapi Shield",
        ammo	= "Ghastly Tathlum +1",
		head  	= "Leth. Chappel +2",
		neck  	= "Sibyl Scarf",
		ear1  	= "Malignance Earring",
		ear2  	= "Snotra Earring",
		body  	= "Lethargy Sayon +3",
		hands 	= "Leth. Ganth. +3",
		ring1 	= "Stikini Ring +1",
		ring2 	= "Metamor. Ring +1",
		back  	= gear.CapeMND,
		waist 	= "Acuity Belt +1",
		legs  	= "Leth. Fuseau +3",
		feet  	= "Vitiation boots +4",
		}
		
	sets.EnfMND = { -- Paralyze, Paralyze II, Addle, Addle II, Slow, Slow II
        main	= "Daybreak",
        sub		= "Ammurapi Shield",
        ammo	= "Regal Gem",
		head  	= "Viti. Chapeau +3",
		neck  	= "Dls. Torque +2",
		ear1  	= "Malignance Earring",
		ear2  	= "Snotra Earring",
		body  	= "Lethargy Sayon +3",
		hands 	= "Leth. Ganth. +3",
		ring1 	= "Stikini Ring +1",
		ring2 	= "Metamor. Ring +1",
		back  	= gear.CapeMND,
		waist 	= "Sacro Cord",
		legs  	= "Leth. Fuseau +3",
		feet  	= "Vitiation boots +4",
		}
	sets.EnfSkill = set_combine(sets.EnfMND, { -- Frazzle III, Distract III, Poison, Poison II 
		ear1  	= "Vor Earring",
		ring2 	= "Stikini Ring +1",
		})
	sets.EnfAcc = set_combine(sets.EnfMND, { -- Frazzle II, Dispel 
		range	= "Ullr",
		neck	= "Null Loop",
		body	= "Atrophy Tabard +3",
		back	= "Null Shawl",
		waist	= "Null Belt",
		})
	sets.EnfDur = set_combine(sets.EnfMND, { -- Sleep, Sleep II, Bind, Break, Silence
		ring2	= "Kishar Ring",
		})
	
    sets.midcast['Enhancing Magic'] = {
        ammo	= "Homiliary",
		head  	= "Leth. Chappel +2",
		neck  	= "Dls. Torque +2",
		ear1  	= "Malignance Earring",
		ear2  	= "Lethargy Earring",
		body  	= "Lethargy Sayon +3",
		hands 	= "Leth. Ganth. +3",
		ring1 	= "Stikini Ring +1",
		ring2 	= "Kishar Ring",
		back  	= gear.CapeMND,
		waist 	= "Null Belt",
		legs  	= "Leth. Fuseau +3",
		feet  	= "Leth. Houseaux +2",
		}
	sets.midcast.GainSpell = set_combine(sets.midcast['Enhancing Magic'], {
		hands	= "Viti. Gloves +2", })
	sets.midcast.BarStatus = set_combine(sets.midcast['Enhancing Magic'], { 
		neck	= "Sroda Necklace", }) 
    sets.midcast['Refresh'] = set_combine(sets.midcast['Enhancing Magic'], {
		head  	= "Amalric Coif +1",		-- +2
		body  	= "Atrophy Tabard +3",		-- +2
		legs  	= "Leth. Fuseau +3", })		-- +4
    sets.midcast['Stoneskin'] = set_combine(sets.midcast['Enhancing Magic'], {
		neck  	= "Nodens Gorget",			-- +30
		ear1	= "Earthcry Earring",		-- +10
		hands	= "Stone Mufflers",			-- +30
		legs  	= "Shedir Seraweels", })	-- +35
    sets.midcast['Aquaveil'] = set_combine(sets.midcast['Enhancing Magic'], {
		head  	= "Amalric Coif +1",		-- +2
		hands  	= "Regal Cuffs",			-- +2
		waist	= "Emphatikos Rope",		-- +1
		legs  	= "Shedir Seraweels", })	-- +1
    sets.midcast.Cure = set_combine(sets.midcast['Enhancing Magic'], {
		neck  	= "Nodens Gorget",
		legs  	= "Chironic Hose", })
	
    --- Engaged Sets ---
    sets.engaged = {
        --ammo	= "Homiliary",
		ammo 	= "Beetle Arrow",
		head  	= "Malignance Chapeau",
		neck  	= "Anu Torque",
		ear1  	= "Cessance Earring",
		ear2  	= "Eabani Earring",
		body  	= "Lethargy Sayon +3",
		hands 	= "Leth. Ganth. +3",
		ring1 	= "Petrov Ring", 
		ring2 	= "Rajas Ring",
		back  	= "Null Shawl",
		waist 	= "Null Belt",
		legs  	= "Leth. Fuseau +3",
		feet  	= "Leth. Houseaux +2",
		}
		
    sets.defense = {
        ammo	= "Homiliary",
		head  	= "Null Masque",
		neck  	= "Null Loop",
		ear1  	= "Tuisto Earring",
		ear2  	= "Eabani Earring",
		body  	= "Lethargy Sayon +3",
		hands 	= "Leth. Ganth. +3",
		ring1 	= "Gurebu's Ring", 
		ring2 	= "Murky Ring",
		back  	= gear.CapeMND,
		waist 	= "Null belt",
		legs  	= "Leth. Fuseau +3",
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

function job_post_midcast(spell, action, spellMap, eventArgs)
    if spell.action_type == 'Magic' then
		if spell.skill == 'Enhancing Magic' then
			if spell.english:startswith('Gain') then
				equip(sets.midcast.GainSpell)
			elseif barstatus:contains(spell.english) then
				equip(sets.midcast.BarStatus)
			end
		elseif spell.skill == 'Enfeebling Magic' then
			if enfeebling_skill:contains(spell.english) then
                equip(sets.EnfSkill)
			elseif enfeebling_accuracy:contains(spell.english) then
                equip(sets.EnfAcc)
			elseif enfeebling_duration:contains(spell.english) then
                equip(sets.EnfDur)
			else
               equip(sets.EnfMND)
            end
        end
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
        disable('main','sub','range')
    else
        enable('main','sub','range')
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