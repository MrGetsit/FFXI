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
	barelement = S{'Barfire', 'Barblizzard', 'Baraero', 'Barstone', 'Barthunder', 'Barwater'} 
	
    state.WeaponLock = M(false, 'Weapon Lock')
    state.Immunobreak = M(false, 'Immunobreak')	
    state.BowMode = M(false, 'Bow Mode')	
	state.WeaponSet = M{['description']='Weapon Set', 'Sword', 'Dagger', 'Enspell'}
    state.OffenseMode:options('Normal', 'Defense')
    state.Runes = M{['description']='Runes', 'Lux', 'Tenebrae','Ignis', 'Gelus', 'Flabra', 'Tellus', 'Sulpor', 'Unda' }
    send_command('bind @w gs c toggle WeaponLock')
    send_command('bind @e gs c toggle Immunobreak')
    send_command('bind %b gs c toggle BowMode')
    send_command('bind %capslock gs c cycle WeaponSet')
    send_command('bind ~capslock gs c toggle WeaponLock')
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
	send_command('send @all alias rb send Spikex exec RDM_Buffs.txt')
	send_command('send @all alias rb2 send Spikex exec RDM_Buffs2.txt')
	
	send_command('send @all bind %1   sta Spikex /SavageBlade')
	send_command('send @all bind !1   sta Spikex /EmpyrealArrow')
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
	send_command('send @all bind ~%4 send Spikex /Enaero')
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
		send_command('send @all bind @4 send Spikex /Windstorm')
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
	
	send_command('wait 5; input /lockstyleset 4')
end

function init_gear_sets()
    --- Weapon Sets ---
    sets.Sword		= 	{ main="Naegling", 			sub="Diamond Aspis"}
    sets.Dagger		= 	{ main="Tauret", 			sub="Ammurapi Shield"}
    sets.Enspell	= 	{ main="Qutrub Knife", 		sub="Diamond Aspis"}
    sets.Dual 		= 	{ main="Naegling", 			sub="Daybreak"}
    sets.EnspellDW	= 	{ main="Qutrub Knife", 		sub="Ceremonial Dagger"}
    sets.Bow		= 	{ range="Ullr", 			ammo="Stone Arrow"}
		
	gear.CapeMND 	= { name="Sucellos's Cape", augments={'MND+20','Mag. Acc+20 /Mag. Dmg.+20','MND+10','"Fast Cast"+10','Phys. dmg. taken-10%',} }
	gear.CapeINT 	= { name="Sucellos's Cape", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','INT+10','"Mag.Atk.Bns."+10',} }
	gear.CapeIWS 	= { name="Sucellos's Cape", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','INT+10','Weapon skill damage +10%',} }
	gear.CapeSWS 	= { name="Sucellos's Cape", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%',} }	
    gear.Obi 		= { waist = "Hachirin-no-Obi" }
	
    sets.precast.JA['Saboteur'] = { sub = "Diamond Aspis" }
	
	sets.precast.WS = {
		ammo	= "Oshasha's Treatise",
		head  	= "Viti. Chapeau +4",
		neck	= "Sibyl Scarf",
		ear1	= "Malignance earring",
		ear2	= "Friomisi Earring",
		body	= "Lethargy Sayon +3",
		hands	= "Leth. Ganth. +3",
		ring1	= "Cornelia's Ring",
		ring2 	= "Metamor. Ring +1",
		back	= gear.CapeSWS,
		waist	= "Eschan Stone",
		legs	= "Leth. Fuseau +3",
		feet  	= "Leth. Houseaux +3",
		}
	
	sets.precast.WS['Savage Blade'] = {
		ammo	= "Oshasha's Treatise",
		head  	= "Viti. Chapeau +4",
		neck	= "Rep. Plat. Medal",
		ear1	= "Sherida earring",
		ear2	= "Ishvara earring",
		body  	= "Vitiation Tabard +4",
		hands	= "Atrophy Gloves +4",
		ring1	= "Cornelia's Ring",
		ring2	= "Rufescent Ring",
		back	= gear.CapeSWS,
		waist	= "Sailfi Belt +1",
		legs	= "Leth. Fuseau +3",
		feet  	= "Leth. Houseaux +3",
		}
			
	sets.precast.WS['Aeolian Edge'] = {
		ammo	= "Sroda Tathlum",
		head  	= "Leth. Chappel +2",
		neck	= "Sibyl Scarf",
		ear1	= "Malignance earring",
		ear2	= "Friomisi Earring",
		body	= "Lethargy Sayon +3",
		hands	= "Jhakri Cuffs +2",
		ring1	= "Cornelia's Ring",
		ring2 	= "Freke Ring",
		back	= gear.CapeIWS, -- Beats int MAB
		waist	= "Sacro Cord",
		legs	= "Leth. Fuseau +3",
		feet  	= "Leth. Houseaux +3",
		}
	sets.precast.WS['Seraph Blade'] = set_combine(sets.precast.WS['Aeolian Edge'], { neck	= "Fotia Gorget", })
	
	sets.precast.WS['Chant du Cygne'] = {
		ammo	= "Yetshila +1",
		head  	= "Blistering Sallet +1",
		neck	= "Fotia Gorget",
		ear1	= "Sherida Earring",
		ear2	= "Cessance Earring",
		body	= "Lethargy Sayon +3",
		hands	= "Leth. Ganth. +3",
		ring1	= "Begrudging Ring",
		ring2	= "Ilabrat Ring",
		back	= gear.CapeSWS,
		waist	= "Sailfi Belt +1",
		legs	= "Leth. Fuseau +3",
		feet  	= "Leth. Houseaux +3", 
		}		
	sets.precast.WS['Evisceration'] = sets.precast.WS['Chant du Cygne']
	sets.precast.WS['Sanguine Blade'] = set_combine(sets.precast.WS['Aeolian Edge'], { head = "Pixie Hairpin +1" })
	
    sets.precast.FC = {						-- 43 + 38
		ammo  	= "Sapience Orb",			-- 2
		head  	= "Atrophy Chapeau +3",		-- 16
		ear1  	= "Tuisto Earring",			-- HP
		body  	= "Vitiation Tabard +4",	-- 15
		ring1	= "Eihwaz Ring",			-- HP
		ring2	= "Etana Ring",				-- HP
		back  	= gear.CapeMND,				-- 10
		waist	= "Plat. Mog. Belt",		-- HP
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
		ring1 	= "Freke Ring",
		ring2 	= "Metamor. Ring +1",
		back  	= gear.CapeINT,
		waist 	= "Sacro Cord",
		legs  	= "Leth. Fuseau +3",
		feet  	= "Vitiation boots +4",
		}
		
	sets.Immunobreak = { legs = "Chironic Hose" }
		
	sets.EnfMND = { -- Paralyze, Paralyze II, Addle, Addle II, Slow, Slow II
        main	= "Daybreak",
        sub		= "Ammurapi Shield",
        ammo	= "Regal Gem",
		head  	= "Viti. Chapeau +4",
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
		body	= "Atrophy Tabard +4",
		--ring2 	= "Stikini Ring +1",
		})
	sets.EnfAcc = set_combine(sets.EnfMND, { -- Frazzle II, Dispel 
        range	= {name="Ullr",			priority= 1},
        ammo	= {name="Regal Gem",	priority= 2}, -- Equip if weapon locked
		--neck	= "Null Loop",
		body	= "Atrophy Tabard +4",
		back	= "Null Shawl",
		legs	= "Atrophy Tights +4",
		waist	= "Null Belt",
		feet  	= "Atro. Boots +4",
		})
	sets.EnfDur = set_combine(sets.EnfAcc, { -- Sleep, Sleep II, Bind, Break, Silence
        main	= "Naegling",
		ring2	= "Kishar Ring",
		})
	
    sets.midcast['Enhancing Magic'] = {
		sub		= "Forfend +1",
        ammo	= "Homiliary",
		head  	= "Leth. Chappel +2",
		neck  	= "Dls. Torque +2",
		ear1  	= "Mimir Earring",
		ear2  	= "Lethargy Earring",
		body  	= "Lethargy Sayon +3",
		hands	= "Leth. Ganth. +3", 
		ring1 	= "Stikini Ring +1",
		ring2 	= "Kishar Ring",
		back  	= gear.CapeMND,
		waist 	= "Embla Sash",
		legs  	= "Leth. Fuseau +3",
		feet  	= "Leth. Houseaux +3",
		}
	sets.midcast.EnhSkill = set_combine(sets.midcast['Enhancing Magic'], {
		neck  	= "Melic Torque",		-- 10
		body  	= "Vitiation Tabard +4",-- 23 / 24
		hands	= "Viti. Gloves +3",  	-- 24 / 25
		back  	= "Ghostfyre Cape",		-- 9 / 10
		waist 	= "Olympus Sash",		-- 5
		legs	= "Atrophy Tights +4", 	-- 22 / 22
		})
	sets.midcast.GainSpell = set_combine(sets.midcast['Enhancing Magic'], {
		hands	= "Viti. Gloves +3", })
	sets.midcast.BarStatus = set_combine(sets.midcast['Enhancing Magic'], { 
		neck	= "Sroda Necklace", }) 
	sets.midcast.BarElement = set_combine(sets.midcast['Enhancing Magic'], { 
		neck	= "Shedir Seraweels", }) 
		
    sets.midcast['Refresh'] = set_combine(sets.midcast['Enhancing Magic'], {
		head  	= "Amalric Coif +1",		-- +2
		body  	= "Atrophy Tabard +4",		-- +2
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
        main	= "Daybreak",			-- 30
        sub		= "Ammurapi Shield",	-- 
		neck  	= "Nodens Gorget",		-- 5
		legs  	= "Atrophy Tights +4",})-- 12
	
    sets.midcast.CureWeather = set_combine(sets.midcast.Cure, {
        main	= "Chatoyant Staff",
        sub		= "Enki Strap",
        back	= "Twilight Cape",
        waist	= "Hachirin-no-Obi",
        })
		
    --- Engaged Sets ---
    sets.engaged = {
		ammo 	= "Coiste Bodhar",
		head  	= "Malignance Chapeau",
		neck  	= "Anu Torque",
		ear1  	= "Sherida Earring",
		ear2  	= "Dedition Earring",
		body  	= "Malignance Tabard",
		hands 	= "Leth. Ganth. +3",
		ring1 	= "Petrov Ring", 
		ring2 	= "Rajas Ring",
		back  	= "Null Shawl",
		waist	= "Sailfi Belt +1",
		legs  	= "Malignance Tights",
		feet  	= "Leth. Houseaux +3",
		}
		
    sets.defense = {
        ammo	= "Homiliary",
		head  	= "Null Masque",		-- 10
		neck  	= "Warder's Charm +1",	
		ear1  	= "Tuisto Earring",
		ear2  	= "Alabaster Earring",	-- 10
		body  	= "Lethargy Sayon +3",	-- 14
		hands 	= "Leth. Ganth. +3",	-- 11
		ring1 	= "Stikini Ring +1", 	-- Gurebu's Ring
		ring2 	= "Murky Ring",			-- 10
		back  	= "Null Shawl",
		waist 	= "Null belt",
		legs  	= "Leth. Fuseau +3",
		feet  	= "Leth. Houseaux +3",
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
	if spell.type == "WeaponSkill" and player.tp >= 2750 then
		equip({ear2="Moonshade Earring"})
	end
end

function job_post_midcast(spell, action, spellMap, eventArgs)
    if spell.action_type == 'Magic' then
		if spell.skill == 'Enhancing Magic' then
			if spell.english:startswith('Gain') then
				equip(sets.midcast.GainSpell)
			elseif spell.english:startswith('Phalanx') or
			spell.english:startswith('Temper') then
				equip(sets.midcast.EnhSkill)
			elseif barstatus:contains(spell.english) then
				equip(sets.midcast.BarStatus)
			elseif barelement:contains(spell.english) then
				equip(sets.midcast.BarElement)
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
			if state.Immunobreak.value == true then
				equip(sets.Immunobreak)
			end			
		elseif spell.skill == 'Healing Magic' then
            if world.weather_element == 'Light' or 
			world.day_element == 'Light' then
				equip(sets.midcast.CureWeather)
            end
        elseif spell.skill == 'Elemental Magic' then
            if spell.element == world.weather_element and 
			(get_weather_intensity() == 2 and 
			spell.element ~= elements.weak_to[world.day_element]) then
                equip(gear.Obi)
            --[[ Target distance under 1.7 yalms.
            elseif spell.target.distance < (1.7 + spell.target.model_size) then
                equip({waist="Orpheus's Sash"})
            -- Matching day and weather.
            elseif spell.element == world.day_element and spell.element == world.weather_element then
                equip(gear)
            -- Target distance under 8 yalms.
            elseif spell.target.distance < (8 + spell.target.model_size) then
                equip({waist="Orpheus's Sash"})
            ]]-- Match day or weather.
            elseif spell.element == world.day_element or 
			spell.element == world.weather_element then
                equip(gear.Obi)
            end
        end
    elseif spell.type == 'WeaponSkill' then
		if spell.name == "Aeolian Edge" or
		spell.name == "Seraph Blade" or
		spell.name == "Red Lotus Blade" or
		spell.name == "Sanguine Blade" then
			if spell.element == world.day_element or 
			spell.element == world.weather_element then
				equip(gear.Obi)
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
		if state.WeaponSet.value == "Sword" then	
			if player.equipment.main == "Tauret" then
				send_command('input /equip main')
			end
			send_command('send @all bind %1 send Spikex /SavageBlade ') 
			send_command('send @all bind %2 send Spikex /ChantDuCygne ') 
		elseif state.WeaponSet.value == "Dagger" then
			if player.equipment.main == "Naegling" then
				send_command('input /equip main')
			end
			send_command('send @all bind %1 send Spikex /Evisceration ') 
			send_command('send @all bind %2 send Spikex /AeolianEdge ') 
		end
    end
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