function get_sets()
	mote_include_version = 2
	include('Mote-Include.lua')
end
function job_setup()
	windower.send_command('sta !packets on') -- For SendTarget to work
	
	rune_enchantments = S{'Lux','Tenebrae', 'Ignis', 'Gelus', 'Flabra', 'Tellus', 'Sulpor', 'Unda' }
	barstatus = S{'Baramnesia', 'Barvirus', 'Barparalyze', 'Barsilence', 'Barpetrify', 'Barpoison', 'Barblind', 'Barsleep'} 
	magic_weaponskills = S{'Aeolian Edge','Burning Blade','Red Lotus Blade','Shining Blade','Seraph Blade','Sanguine Blade'}
	
	state.Runes = M{['description']='Runes', 'Lux', 'Tenebrae','Ignis', 'Gelus', 'Flabra', 'Tellus', 'Sulpor', 'Unda' }
	state.Immunobreak = M(false, 'Immunobreak')	
	state.OffenseMode:options('Normal', 'Hybrid', 'Defense')
	
	state.MainWeapon = M{'Naegling', 'Crocea Mors', 'Maxentius', 'Tauret' }
	state.SubWeapon = M{'Thibron', 'Daybreak' }	
	
	send_command('bind @w gs c lock')
	send_command('bind @e gs c toggle Immunobreak')
	send_command('bind capslock gs c cycle MainWeapon')
	send_command('bind !capslock gs c cycle SubWeapon')
	send_command('bind @S gs c cycle OffenseMode')
	
	send_command('lua u debuffed')
	send_command('lua l debuffgrid')
	send_command('lua l Skillchains')
	send_command('lua l SpamFilter')
	send_command('lua l PartyBuffs')
	send_command('lua l Battlemod')
	send_command('lua l Dressup')
	
	dual_wield = false
	WeaponLock = false
end

function user_setup()
	send_command('send @all alias imp gs c impact') -- exec RDM_Impact.txt
	send_command('send @all alias rb  exec RDM_Buffs.txt')
	send_command('send @all alias rb2 exec RDM_Buffs2.txt')
	send_command('send @all alias av aquaveil')
	
	setup_weapon_keybinds()
	send_command('send @all bind %3   sta Spikex /SanguineBlade')
	send_command('send @all bind !3   sta Spikex /CircleBlade')
	
	send_command('send @all bind %4   sta Spikex /Cure4 <stpc>')
	send_command('send @all bind !4   sta Spikex /Cure3 <stpc>')
	send_command('send @all bind %5  send Spikex /Composure')
	send_command('send @all bind !5  send Spikex /Spontaneity')
	send_command('send @all bind ~%5  sta Spikex /Haste2 <stpc>')
	send_command('send @all bind %6   sta Spikex /Regen2 <stpc>')
	send_command('send @all bind ~%6  sta Spikex /Refresh3 <stpc>')
	send_command('send @all bind ~%1 send Spikex /Temper2')
	send_command('send @all bind ~%2 send Spikex /Phalanx')
	send_command('send @all bind ^%2  sta Spikex /Phalanx2 <stpc>')
	send_command('send @all bind ~%3 send Spikex /GainStr')
	send_command('send @all bind ~%4 send Spikex gs c enspell')
	send_command('send @all bind %7  send Spikex /Blink')
	send_command('send @all bind %8  send Spikex /Stoneskin')
	send_command('send @all bind %9  send Spikex /Protect5 <stpc>')
	send_command('send @all bind %0  send Spikex /Shell5 <stpc>')
	
	send_command('send @all bind %e   sta Spikex /Dia3')
	send_command('send @all bind ~%e send Spikex /Saboteur')
	send_command('send @all bind ~^e send Spikex /Stymie')
	send_command('send @all bind %q   sta Spikex /Dispel')
	send_command('send @all bind !q   sta Spikex /Slow2')
	send_command('send @all bind ~%q  sta Spikex /Paralyze2')
	send_command('send @all bind ^%q  sta Spikex /Blind2')
	send_command('send @all bind @%q  sta Spikex /Inundation')
	send_command('send @all bind %z  send Spikex /Frazzle3')
	send_command('send @all bind !z  send Spikex /Distract3')
	send_command('send @all bind ~%z send Spikex /Silence')
	send_command('send @all bind ^%z send Spikex /Addle2')
	send_command('send @all bind %`   sta Spikex /Sleep2')
	send_command('send @all bind !`   sta Spikex /Sleep2 <stnpc>')
	send_command('send @all bind %~` send Spikex /Break')
	
	if player.sub_job == 'SCH' then
		send_command('lua l StratagemCounter')
		send_command('send @all bind %x send Spikex /Accession')
		send_command('send @all bind !x send Spikex /LightArts')
		send_command('send @all bind @x send Spikex /AddendumWhite')
		send_command('send @all bind @4 send Spikex /Windstorm')
		send_command('send @all bind ^x  sta Spikex /stna <stpc>')
		send_command('send @all bind %c send Spikex /Manifestation')
		send_command('send @all bind !c send Spikex /DarkArts')
		send_command('send @all bind @c send Spikex /AddendumBlack')
	elseif player.sub_job == 'WAR' then
		send_command('send @all bind !z  send Spikex /Defender')
		send_command('send @all bind %x  send Spikex /Berserk')
		send_command('send @all bind ~%x send Spikex /Warcry')
		send_command('send @all bind !e   sta Spikex /Provoke <stnpc>')
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
	if player.sub_job == 'NIN' or player.sub_job == 'DNC' then
		dual_wield = true
	else
		dual_wield = false
	end	
	send_command('wait 5; input /lockstyleset 5')
	send_command('wait 1; gs c startup')
end

function user_unload()
	send_command('lua u debuffgrid')
	send_command('lua l debuffed')
end

function init_gear_sets()
	--- Gear Sets ---
	sets.Immunobreak =	{ legs = "Chironic Hose" }
	
	gear.CapeMND 	= { name="Sucellos's Cape", augments={'MND+20','Mag. Acc+20 /Mag. Dmg.+20','MND+10','"Fast Cast"+10','Phys. dmg. taken-10%',} }
	gear.CapeINT 	= { name="Sucellos's Cape", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','INT+10','"Mag.Atk.Bns."+10',} }
	gear.CapeIWS 	= { name="Sucellos's Cape", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','INT+10','Weapon skill damage +10%',} }
	gear.CapeSWS 	= { name="Sucellos's Cape", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%',} }
	gear.CapeDW 	= { name="Sucellos's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dual Wield"+10','Phys. dmg. taken-10%',} }
	gear.Obi 		= { waist = "Hachirin-no-Obi" }
	
	--- Precast Sets ---
	sets.precast.JA['Chainspell']	= { body="Viti. Tabard +4" }
	sets.precast.JA['Convert']		= { main="Murgleis" }
	sets.precast.JA['Saboteur']		= { sub="Diamond Aspis", hands="Leth. Ganth. +3" }
	
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
	
	--- WS Sets ---
	sets.precast.WS = {
		ammo	= "Oshasha's Treatise",
		head	= "Viti. Chapeau +4",
		neck	= "Sibyl Scarf",
		ear1	= "Malignance earring",
		ear2	= "Friomisi Earring",
		body	= "Lethargy Sayon +3",
		hands	= "Leth. Ganth. +3",
		ring1	= "Cornelia's Ring",
		ring2	= "Metamor. Ring +1",
		back	= gear.CapeSWS,
		waist	= "Sacro Cord",
		legs	= "Leth. Fuseau +3",
		feet	= "Leth. Houseaux +3",
		}
	sets.precast.WS['Savage Blade'] = {
		ammo	= "Oshasha's Treatise",
		head  	= "Leth. Chappel +3",
		neck	= "Rep. Plat. Medal",
		ear1	= "Sherida earring",
		ear2	= "Ishvara earring",
		body	= "Vitiation Tabard +4",
		hands	= "Atrophy Gloves +4",
		ring1	= "Cornelia's Ring",
		ring2	= "Rufescent Ring",
		back	= gear.CapeSWS,
		waist	= "Sailfi Belt +1",
		legs	= "Leth. Fuseau +3",
		feet	= "Leth. Houseaux +3",
		}	
	sets.precast.WS['Death Blossom'] = sets.precast.WS['Savage Blade']
	sets.precast.WS['Black Halo'] = sets.precast.WS['Savage Blade']
	
	sets.precast.WS['Chant du Cygne'] = {
		ammo	= "Yetshila +1",
		head	= "Blistering Sallet +1",
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
		feet	= "Leth. Houseaux +3", 
		}
	sets.precast.WS['Evisceration'] = sets.precast.WS['Chant du Cygne']
	
	sets.precast.WS['Aeolian Edge'] = {
		ammo	= "Sroda Tathlum",
		head	= "Leth. Chappel +3",
		neck	= "Sibyl Scarf",
		ear1	= "Malignance earring",
		ear2	= "Friomisi Earring",
		body	= "Lethargy Sayon +3",
		hands	= "Jhakri Cuffs +2",
		ring1	= "Cornelia's Ring",
		ring2	= "Freke Ring",
		back	= gear.CapeIWS, -- Beats int MAB
		waist	= "Sacro Cord",
		legs	= "Leth. Fuseau +3",
		feet	= "Leth. Houseaux +3",
		}
	sets.precast.WS['Sanguine Blade'] = {
		ammo	= "Sroda Tathlum",
		head	= "Pixie Hairpin +1",
		neck	= "Sibyl Scarf",
		ear1	= "Malignance earring",
		ear2	= "Friomisi Earring",
		body	= "Lethargy Sayon +3",
		hands	= "Leth. Ganth. +3",
		ring1	= "Cornelia's Ring",
		ring2	= "Archon Ring",
		back	= gear.CapeSWS,
		waist	= "Sacro Cord",
		legs	= "Leth. Fuseau +3",
		feet	= "Leth. Houseaux +3",
		}
	sets.precast.WS['Seraph Blade'] = {
		ammo	= "Sroda Tathlum",
		head	= "Leth. Chappel +3",
		neck	= "Fotia Gorget",
		ear1	= "Malignance earring",
		ear2	= "Friomisi Earring",
		body	= "Lethargy Sayon +3",
		hands	= "Jhakri Cuffs +2",
		ring1	= "Cornelia's Ring",
		ring2	= "Weather. Ring",
		back	= gear.CapeSWS,
		waist	= "Sacro Cord",
		legs	= "Leth. Fuseau +3",
		feet	= "Leth. Houseaux +3",
		}
	sets.precast.WS['Red Lotus Blade'] = sets.precast.WS['Seraph Blade']	
	sets.precast.WS['Requiescat'] = set_combine(sets.precast.WS, {neck="Fotia Gorget"})
	
	--- Midcast Sets ---
	sets.midcast['Elemental Magic'] = {
		sub		= "Ammurapi Shield",
		ammo	= "Ghastly Tathlum +1",
		head	= "Leth. Chappel +3",
		neck	= "Sibyl Scarf",
		ear1	= "Malignance Earring",
		ear2	= "Snotra Earring",
		body	= "Lethargy Sayon +3",
		hands	= "Leth. Ganth. +3",
		ring1	= "Freke Ring",
		ring2	= "Metamor. Ring +1",
		back	= gear.CapeINT,
		waist	= "Acuity Belt +1",
		legs	= "Leth. Fuseau +3",
		feet	= "Vitiation boots +4",
		}
		
	sets.midcast['Enfeebling Magic'] = { -- Paralyze/2, Addle/2, Slow/2,
		main	= "Daybreak",
		sub		= "Ammurapi Shield",
		ammo	= "Regal Gem",				-- 10
		head	= "Viti. Chapeau +4",
		neck	= "Dls. Torque +2",			-- 10
		ear1	= "Malignance Earring",
		ear2	= "Snotra Earring",
		body	= "Lethargy Sayon +3",		-- 18
		hands	= "Leth. Ganth. +3",
		ring1	= "Stikini Ring +1",
		ring2	= "Metamor. Ring +1",
		back	= gear.CapeMND,				-- 10
		waist	= "Sacro Cord",
		legs	= "Leth. Fuseau +3",
		feet	= "Vitiation boots +4",		-- 10
		}
		
	sets.midcast.EnfSkill = {
		main	= "Daybreak",
		sub		= "Ammurapi Shield",
		ammo	= "Regal Gem",
		head	= "Viti. Chapeau +4",
		neck	= "Dls. Torque +2",
		ear1	= "Vor Earring",
		ear2	= "Snotra Earring",
		body	= "Atrophy Tabard +4",
		hands	= "Leth. Ganth. +3",
		ring1	= "Stikini Ring +1",
		ring2	= "Stikini Ring +1",
		back	= gear.CapeMND,
		waist	= "Sacro Cord",
		legs	= "Leth. Fuseau +3",
		feet	= "Vitiation boots +4",
		}
	sets.midcast['Distract III'] = sets.midcast.EnfSkill
	sets.midcast['Frazzle III'] = sets.midcast.EnfSkill
	sets.midcast['Poison II'] = sets.midcast.EnfSkill
	
	sets.midcast.EnfAcc = {
		main	= "Crocea Mors",
		sub		= "Ammurapi Shield",
		range	= {name="Ullr",			priority= 1},
		ammo	= {name="Regal Gem",	priority= 2}, -- Equip when locked
		head	= "Viti. Chapeau +4",
		neck	= "Null Loop",
		ear1	= "Vor Earring",
		ear2	= "Snotra Earring",
		body	= "Atrophy Tabard +4",
		hands	= "Leth. Ganth. +3",
		ring1	= "Stikini Ring +1",
		ring2	= "Stikini Ring +1",
		back	= "Aurist's Cape +1",
		waist	= "Null Belt",
		legs	= "Atrophy Tights +4",
		feet	= "Atro. Boots +4",
		}
	sets.midcast['Frazzle II'] = sets.midcast.EnfAcc
	sets.midcast['Dispel'] = sets.midcast.EnfAcc
	sets.midcast['Gravity'] = sets.midcast.EnfAcc
	sets.midcast['Stun'] = sets.midcast.EnfAcc
	sets.midcast['Impact'] = sets.midcast.EnfAcc
	
	sets.midcast.EnfDur = {
		main	= "Crocea Mors",
		sub		= "Ammurapi Shield",	
		range	= {name="Ullr",			priority= 1},
		ammo	= {name="Regal Gem",	priority= 2}, -- Equip when locked
		head	= "Viti. Chapeau +4",
		neck	= "Dls. Torque +2",	
		ear1	= "Vor Earring",
		ear2	= "Snotra Earring",
		body	= "Atrophy Tabard +4",
		hands	= "Leth. Ganth. +3",
		ring1	= "Stikini Ring +1",
		ring2	= "Kishar Ring",
		back	= "Null Shawl",	
		waist	= "Null Belt",
		legs	= "Atrophy Tights +4",
		feet	= "Atro. Boots +4",
		}
	sets.midcast['Sleep'] = sets.midcast.EnfAcc
	sets.midcast['Sleep II'] = sets.midcast.EnfAcc
	sets.midcast['Sleepga'] = sets.midcast.EnfAcc
	sets.midcast['Sleepga II'] = sets.midcast.EnfAcc
	sets.midcast['Bind'] = sets.midcast.EnfAcc
	sets.midcast['Break'] = sets.midcast.EnfAcc
	sets.midcast['Silence'] = sets.midcast.EnfAcc
	sets.midcast['Inundation'] = sets.midcast.EnfAcc
	
	sets.midcast['Enhancing Magic'] = {
		ammo	= "Homiliary",
		head	= "Leth. Chappel +3",	-- 10
		neck	= "Dls. Torque +2",		-- 17/25
		ear1	= "Mimir Earring",
		ear2	= "Lethargy Earring",	-- 7/9
		body	= "Lethargy Sayon +3",	-- 10
		hands	= "Atro. Gloves +4", 	-- 20
		ring1	= "Stikini Ring +1",
		ring2	= "Stikini Ring +1",
		back 	= "Ghostfyre Cape",		-- 16 / 20*
		waist	= "Embla Sash",			-- 10
		legs	= "Leth. Fuseau +3",	-- 10
		feet	= "Leth. Houseaux +3",	-- 40 + 15
		}
	sets.midcast.EnhSkill = { -- Temper/2, Enspells
		main	= "Pukulatmuj +1",		-- 10
		sub		= "Forfend +1",			-- 10
		ammo	= "Homiliary",
		head	= "Befouled Crown",		-- 16
		neck	= "Melic Torque",		-- 10
		ear1	= "Mimir Earring",		-- 10
		ear2	= "Andoaa Earring",		-- 5
		body	= "Vitiation Tabard +4",-- 24
		hands	= "Viti. Gloves +3",  	-- 24 / 25
		ring1	= "Stikini Ring +1",	-- 8
		ring2	= "Stikini Ring +1",	-- 8
		back	= "Ghostfyre Cape",		-- 9 / 10
		waist	= "Olympus Sash",		-- 5
		legs	= "Atrophy Tights +4", 	-- 22 / 22
		feet  	= "Leth. Houseaux +3",	-- 35
		}
	sets.midcast.PhalanxSelf = {
		ammo	= "Homiliary",
		head	= "Merlinic Hood",		-- +4
		neck	= "Dls. Torque +2",
		ear1	= "Mimir Earring",
		ear2	= "Lethargy Earring",
		body	= "Taeon Tabard",		-- +3
		hands	= "Taeon Gloves",  		-- +3
		ring1	= "Stikini Ring +1",
		ring2	= "Murky Ring",
		back	= "Ghostfyre Cape",
		waist	= "Embla Sash",
		legs	= "Chironic Hose", 		-- +4
		feet	= "Taeon Boots",		-- +3
		}
	sets.midcast.PhalanxOther = { 
		ammo	= "Homiliary",
		head	= "Leth. Chappel +3",
		neck	= "Dls. Torque +2",
		ear1	= "Mimir Earring",
		ear2	= "Lethargy Earring",
		body	= "Lethargy Sayon +3",
		hands	= "Atro. Gloves +4",
		ring1	= "Stikini Ring +1",
		ring2	= "Murky Ring",
		back	= "Ghostfyre Cape",		-- 9 / 10
		waist	= "Embla Sash",			-- 10
		legs	= "Leth. Fuseau +3",
		feet	= "Leth. Houseaux +3",
		}
	sets.midcast.SelfProt = set_combine(sets.midcast['Enhancing Magic'], {
		ear1	= "Brachyura Earring", })
	sets.midcast.GainSpell = set_combine(sets.midcast['Enhancing Magic'], {
		hands	= "Viti. Gloves +3", })
	sets.midcast.BarStatus = set_combine(sets.midcast['Enhancing Magic'], { 
		neck	= "Sroda Necklace", }) 
	sets.midcast.BarElement = set_combine(sets.midcast['Enhancing Magic'], { 
		neck	= "Shedir Seraweels", }) 		
	sets.midcast['Refresh'] = set_combine(sets.midcast['Enhancing Magic'], {
		head	= "Amalric Coif +1",		-- +2
		body	= "Atrophy Tabard +4",		-- +2
		legs	= "Leth. Fuseau +3", })		-- +4
	sets.midcast['Stoneskin'] = set_combine(sets.midcast['Enhancing Magic'], {
		neck	= "Nodens Gorget",			-- +30
		--ear1	= "Earthcry Earring",		-- +10
		--hands	= "Stone Mufflers",			-- +30
		waist	= "Siegel Sash",			-- +20
		legs	= "Shedir Seraweels", })	-- +35
	sets.midcast['Aquaveil'] = set_combine(sets.midcast['Enhancing Magic'], {
		head	= "Amalric Coif +1",		-- +2
		hands	= "Regal Cuffs",			-- +2
		waist	= "Emphatikos Rope",		-- +1
		legs	= "Shedir Seraweels", })	-- +1
		
	sets.midcast.Cure = {
		main	= "Daybreak",			-- 30
		ammo	= "Staunch Tathlum",
		head	= "Atrophy Chapeau +3",
		neck	= "Nodens Gorget",		-- 5
		ear1	= "Malignance Earring",
		ear2	= "Alabaster Earring",
		body	= "Vitiation Tabard +4",
		hands	= "Atro. Gloves +4", 
		ring1	= "Stikini Ring +1",
		ring2	= "Stikini Ring +1",
		back 	= "Ghostfyre Cape",		-- 6
		waist	= "Gishdubar Sash",		-- 10 Self
		legs	= "Atrophy Tights +4",
		feet	= "Leth. Houseaux +3",
		}
	sets.midcast.CureWeather = set_combine(sets.midcast.Cure, {
		main	= "Chatoyant Staff",
		sub		= "Enki Strap",
		back	= "Twilight Cape",
		waist	= "Hachirin-no-Obi",
		})
	sets.midcast['Regen II'] = set_combine(sets.midcast.Cure, {
		main	= "Bolelabunga", })	  
		
	--- Engaged Sets ---
	sets.engaged = {
		ammo	= "Coiste Bodhar",
		head	= "Malignance Chapeau",
		neck	= "Anu Torque",
		ear1	= "Sherida Earring",
		ear2	= "Dedition Earring",
		body	= "Malignance Tabard",
		hands	= "Malignance Gloves",
		ring1	= "Chirich Ring +1", 
		ring2	= "Chirich Ring +1",
		back	= "Null Shawl",
		waist	= "Sailfi Belt +1",
		legs	= "Malignance Tights",
		feet	= "Malignance Boots",
		}
	sets.engaged.DW = {
		ammo	= "Coiste Bodhar",
		head	= "Malignance Chapeau",
		neck	= "Anu Torque",
		ear1	= "Sherida Earring",
		ear2	= "Dedition Earring",
		body	= "Malignance Tabard",
		hands	= "Malignance Gloves",
		ring1	= "Chirich Ring +1", 
		ring2	= "Chirich Ring +1",
		back	= gear.CapeDW,
		waist	= "Sailfi Belt +1",
		legs	= "Malignance Tights",
		feet	= "Malignance Boots",
		}
	sets.hybrid = {
		ammo	= "Coiste Bodhar",
		head	= "Malignance Chapeau",
		neck	= "Anu Torque",
		ear1	= "Sherida Earring",
		ear2	= "Dedition Earring",
		body	= "Malignance Tabard",
		hands	= "Malignance Gloves",
		ring1	= "Chirich Ring +1", 
		ring2	= "Murky Ring",
		back	= "Null Shawl",
		waist	= "Sailfi Belt +1",
		legs	= "Malignance Tights",
		feet	= "Malignance Boots",
		}
	sets.hybrid.DW = {
		ammo	= "Coiste Bodhar",
		head	= "Malignance Chapeau",
		neck	= "Anu Torque",
		ear1	= "Sherida Earring",
		ear2	= "Dedition Earring",
		body	= "Malignance Tabard",
		hands	= "Malignance Gloves",
		ring1	= "Chirich Ring +1", 
		ring2	= "Murky Ring",
		back	= gear.CapeDW,
		waist	= "Sailfi Belt +1",
		legs	= "Malignance Tights",
		feet	= "Malignance Boots",
		}
	sets.defense = {
		ammo	= "Homiliary",
		head	= "Null Masque",		-- 10
		neck	= "Warder's Charm +1",	
		ear1	= "Tuisto Earring",
		ear2	= "Alabaster Earring",	-- 10
		body	= "Lethargy Sayon +3",	-- 14
		hands	= "Leth. Ganth. +3",	-- 11
		ring1	= "Fortified Ring", 	-- Gurebu's Ring
		ring2	= "Murky Ring",			-- 10
		back	= "Null Shawl",
		waist	= "Null belt",
		legs	= "Leth. Fuseau +3",
		feet	= "Leth. Houseaux +3",
		}
		
	--- Other Sets ---
	sets.idle = sets.defense
	sets.idle.Town = set_combine(sets.idle, {ring1="Warp Ring", ring2="Dim. Ring (Holla)"})	    
	
	sets.buff.Doom = {
		neck="Nicander's Necklace",	--30
		ring1="Blenmot's Ring",		--5
		ring2="Blenmot's Ring",		--5
		waist="Gishdubar Sash",		--10
	}
end

function setup_weapon_keybinds()
	local main = state.MainWeapon.value
	
	if main == 'Naegling' then
		send_command('send @all bind %1 send Spikex /SavageBlade')
		send_command('send @all bind %2 send Spikex /ChantDuCygne')
		send_command('send @all bind !1 send Spikex /RedLotusBlade')
		send_command('send @all bind !2 send Spikex /SeraphBlade')
	
	elseif main == 'Crocea Mors' then
		send_command('send @all bind %1 send Spikex /RedLotusBlade')
		send_command('send @all bind %2 send Spikex /SeraphBlade')
		send_command('send @all bind !1 send Spikex /SavageBlade')
		send_command('send @all bind !2 send Spikex /ChantDuCygne')
	
	elseif main == 'Maxentius' then
		send_command('send @all bind %1 send Spikex /BlackHalo')
	
	elseif main == 'Tauret' then
		send_command('send @all bind %1 send Spikex /Evisceration')
		send_command('send @all bind %2 send Spikex /AeolianEdge')
	end
end

function check_weapon(bypass)
	if temp_weapons then
		enable('main','sub')
		equip({main = tempmain, sub = tempsub})
		toggle_weapon_lock(true)
		temp_weapons = false
		return
	end

	if not bypass and WeaponLock then return end

	local main_matches = player.equipment.main == state.MainWeapon.value
	local sub_matches = dual_wield and 
		(player.equipment.sub == state.SubWeapon.value) or
		(player.equipment.sub == 'Diamond Aspis')
	
	if bypass or not main_matches or not sub_matches then
		enable('main','sub','range')
		if dual_wield then
			equip({main = state.MainWeapon.value, sub = state.SubWeapon.value})
		else
			equip({main = state.MainWeapon.value, sub = 'Diamond Aspis'})
		end
	end	
end

function customize_melee_set()
	if state.OffenseMode.value == "Defense" or
	player.status == 'Idle' or incapacitated then
		equip(sets.defense)
	elseif state.OffenseMode.value == "Hybrid" then
		if dual_wield then
			equip(sets.hybrid.DW)
		else
			equip(sets.hybrid)
		end
	else
		if dual_wield then
			equip(sets.engaged.DW)
		else
			equip(sets.engaged)
		end
	end
	check_weapon()
end

function job_buff_change(buff,gain)
	if buff == "doom" then
		if gain then
			enable('ring1','ring2','waist','neck')
			equip(sets.buff.Doom)
			send_command('@input /p Doomed.')
			disable('ring1','ring2','waist','neck')
		else
			send_command('@input /p Doom Removed')
			enable('ring1','ring2','waist','neck')
		end
	elseif buff == "charm" then
		if gain then
			send_command('@input /p Charmed.')
		end
	end
	if buff == "sleep" then
		if gain then
			incapacitated = true
			save_temp_weapons()
			enable('main')
			equip({main = 'Caliburnus'})
			toggle_weapon_lock(false)
		else
			incapacitated = false
			if temp_weapons then check_weapon() end
		end
	end
	if buff == "terror" or buff == "petrification" or buff == "stun" then
		if gain then
			incapacitated = true
		else
			incapacitated = false
		end
	end
	customize_melee_set()
end

function job_post_pretarget(spell, action, spellMap, eventArgs)
	cancel = false
	if spell.action_type == 'Magic' then -- Don't change gear on CD
		local recast = windower.ffxi.get_spell_recasts()[spell.recast_id]
		if recast and recast >= 1 then cancel = true end
	elseif spell.type == 'WeaponSkill' then
		if player.tp <= 1000 then cancel = true	end
	end
	if cancel or incapacitated then
		cancel_spell()
		eventArgs.handled = true
		return
	end
	
	if WeaponLock then
		disable('main','sub','range')
	end
end

function job_post_precast(spell, action, spellMap, eventArgs)
	if spell.type == 'WeaponSkill' then
		if spell.name == 'Sanguine Blade' then -- No moonshade for Sanguine
			return
		elseif player.equipment.sub == "Thibron" then
			if player.tp <= 1750 then 
				equip({ear2="Moonshade Earring"})
			end
		elseif player.tp <= 2750 then
			equip({ear2="Moonshade Earring"})
		end
	end
end

function job_post_midcast(spell, action, spellMap, eventArgs)
	local midcast_update = nil
	if spell.action_type == 'Magic' then
		if spell.skill == 'Enhancing Magic' then
			if spell.english:startswith('Gain') then
				midcast_update = sets.midcast.GainSpell
			
			elseif spell.english:startswith('Temper') or 
			spell.english:startswith('En') then
				if WeaponLock and (player.equipment.main ~= state.MainWeapon.value or player.equipment.sub ~= state.SubWeapon.sub) then
					save_temp_weapons()
					toggle_weapon_lock(false)
				end
				midcast_update = sets.midcast.EnhSkill
			
			elseif spell.target.type == 'SELF' and
			(spell.english:startswith('Shell') or 
			spell.english:startswith('Protect')) then
				midcast_update = sets.midcast.SelfProt
				
			elseif spell.english:startswith('Phalanx') then
				if spell.target.type == 'SELF' then
					midcast_update = sets.midcast.PhalanxSelf
				else
					midcast_update = sets.midcast.PhalanxOther
				end
			elseif barstatus:contains(spell.english) then
				midcast_update = sets.midcast.BarStatus
			end
		elseif spell.skill == 'Enfeebling Magic' then
			if state.Immunobreak.value == true then
				midcast_update = sets.Immunobreak
			end
		elseif spell.english:startswith('Cure') then
			if world.weather_element == 'Light' or 
			world.day_element == 'Light' then
				midcast_update = sets.midcast.CureWeather
			end
		elseif spell.skill == 'Elemental Magic' then
			if spell.element == world.weather_element and 
			(get_weather_intensity() == 2 and 
			spell.element ~= elements.weak_to[world.day_element]) then
				midcast_update = gear.Obi
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
				midcast_update = gear.Obi
			end
		end
	elseif spell.type == 'WeaponSkill' then
		if magic_weaponskills:contains(spell.name) then
			if spell.element == world.day_element or 
			spell.element == world.weather_element then
				midcast_update = gear.Obi
			end
		end	
	end
	if midcast_update then equip(midcast_update) end
end

function job_aftercast(spell)
	if casting_impact then casting_impact = false end
	check_weapon()
	--coroutine.schedule(function() check_weapon(3) end, 3)
end

function job_state_change(field, new_value, old_value)
	if field == 'MainWeapon' then 
		setup_weapon_keybinds()
		check_weapon(true)
	end
	if field == 'SubWeapon' then 
		check_weapon(true)
	end
	customize_melee_set()
end

function job_self_command(cmdParams, eventArgs)
	if cmdParams[1]:lower() == 'rune' then
		send_command('@input /ja '..state.Runes.value..' <me>')
	
	elseif cmdParams[1]:lower() == 'startup' then
		customize_melee_set()
		
	elseif cmdParams[1]:lower() == 'impact' then
		local target = windower.ffxi.get_mob_by_target('t')
		if target then	
			enable('head', 'body')
			equip({head = "empty", body = "Crepuscular Cloak"})
			disable('head', 'body')
			attempts = 0
			casting_impact = true
			coroutine.schedule(function() cast_impact() end, 0.5)
		end				
	elseif cmdParams[1]:lower() == 'enspell' then
		if world.day_element == 'Fire' then
			send_command('Enfire')
		elseif world.day_element == 'Earth' then
			send_command('Enstone')
		elseif world.day_element == 'Water' then
			send_command('Enwater')
		elseif world.day_element == 'Wind' then
			send_command('Enaero')
		elseif world.day_element == 'Ice' then
			send_command('Enblizzard')
		else
			send_command('Enthunder')
		end	
	elseif cmdParams[1]:lower() == 'lock' then
		WeaponLock = not WeaponLock
		toggle_weapon_lock(WeaponLock, true)
	end
end

function cast_impact()	
	if casting_impact and attempts < 15 then
		send_command('Impact')
		attempts = attempts + 1
		coroutine.schedule(function() cast_impact() end, 0.5)
	else
		enable('head', 'body')
	end
end

function save_temp_weapons()
	temp_weapons = true
	tempmain = player.equipment.main
	tempsub = player.equipment.sub
end

function toggle_weapon_lock(should_enable, report)
	if should_enable then
		WeaponLock = true
		disable('main','sub','range')
		if report then windower.add_to_chat(206, 'Weapon Lock: On') end
	else
		WeaponLock = false
		enable('main','sub','range')
		if report then 
			windower.add_to_chat(206, 'Weapon Lock: Off') 
			check_weapon()
		end
	end
end

windower.register_event('zone change', function()
	toggle_weapon_lock(false)
end)

function tprint(tbl, indent)
	if not indent then indent = 0 end
	local spaces = string.rep("  ", indent) -- Use two spaces for indentation

	for k, v in pairs(tbl) do
		local key_str
		if type(k) == "number" then
			key_str = "[" .. k .. "]"
		else
			key_str = "['" .. k .. "']"
		end

		if type(v) == "table" then
		   print(2, spaces .. key_str .. " = {") 
			tprint(v, indent + 1)
		   print(2, spaces .. "}")
		else
			local value_str = tostring(v)
			if type(v) == "string" then
				value_str = "'" .. value_str .. "'"
			end
			print(2, spaces .. key_str .. " = " .. value_str .. ",")
		end
	end
end