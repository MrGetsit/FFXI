--[[			Debuffs by element
	Fire		MAB Down	Burn		Addle		Amnesia	Plague/Virus
	Ice		EVA Down	Frost		Bind		Distract	Paralyze
	Wind		DEF Down	Choke		Gravity	Silence
	Earth		ACC Down	Rasp		Break		Slow
	Lightning	MDB Down	Shock		Stun
	Water		ATT Down	Drown		Poison
	Light		MAC Down	Charm		Dia		Flash		Lullaby	Repose
	Darkness	MEV Down	Bio		Blind		Impact	Sleep	
]]
function get_sets()
	mote_include_version = 2
	include('Mote-Include.lua')
	texts = require('texts') 
end

function job_setup()
	send_command('lua l DebuffGrid')
	send_command('lua l Skillchains')
	send_command('lua l Battlemod')
	send_command('lua l SpamFilter')
	send_command('lua l PartyBuffs')
	
	rune_enchantments = S{'Lux','Tenebrae', 'Ignis', 'Gelus', 'Flabra', 'Tellus', 'Sulpor', 'Unda' }
	barstatus = S{'Baramnesia', 'Barvirus', 'Barparalyze', 'Barsilence', 'Barpetrify', 'Barpoison', 'Barblind', 'Barsleep'}
	magic_weaponskills = S{'Aeolian Edge','Burning Blade','Red Lotus Blade','Shining Blade','Seraph Blade','Sanguine Blade'}
	
	state.Runes = M{['description']='Runes', 'Lux', 'Tenebrae','Ignis', 'Gelus', 'Flabra', 'Tellus', 'Sulpor', 'Unda' }
	state.Immunobreak = M(false, 'Immunobreak')	
	state.OffenseMode:options('Normal', 'Defense', 'Hybrid')
	
	spam_list = {'Thunder', 'Blizzard', 'Fire', 'Water', 'Stone'}
	nextsp = 0
	
	weapon_sets = {
		Physical = {
			A = { main = 'Naegling',	sub = 'Thibron' },
			B = { main = 'Maxentius',	sub = 'Thibron' },
		},
		Magical = {
			A = { main = 'Crocea Mors',	sub = 'Daybreak' },
			B = { main = 'Tauret',		sub = 'Thibron' },
		},
	}
	state.WeaponType = M{['description']='Weapon Type', 'Physical', 'Magical'}
	state.WeaponSet  = M{['description']='Weapon Set', 'A', 'B'}
	
	weapon_lock = false -- Keep from switching out of current Weapon
	free_cast = false -- Allow switching weapons for spells
	
	send_command('gs c startup')
end

function user_setup()
	send_command('bind @w gs c free')
	send_command('bind @a gs c lock')
	send_command('bind @e gs c toggle Immunobreak')
	send_command('bind @h gs c toggle_hoxne')
	send_command('bind %c gs c next_spell 4')
	send_command('bind ~%c gs c next_spell 5')
	send_command('bind capslock  gs c cycle WeaponSet')
	send_command('bind !capslock gs c cycle WeaponType')
	send_command('bind @S gs c cycle OffenseMode')
	
	send_command('send @all bind %4  send Spikex Cure4 <stpc>')
	send_command('send @all bind !4  send Spikex gs c cure_lowest')
	send_command('send @all bind %5  send Spikex Haste2 <stpc>')
	send_command('send @all bind !5  send Spikex Composure')
	send_command('send @all bind ~%5 send Spikex Regen2 <stpc>')
	send_command('send @all bind %6  send Spikex Refresh3 <stpc>')
	send_command('send @all bind ~%1 send Spikex Temper2')
	send_command('send @all bind ~%2 send Spikex Phalanx2 Spikex')
	send_command('send @all bind ^%2 send Spikex Phalanx2 <stpc>')
	send_command('send @all bind ~%3 send Spikex GainStr')
	send_command('send @all bind ~%4 send Spikex gs c enspell')
	send_command('send @all bind %7  send Spikex Blink')
	send_command('send @all bind %8  send Spikex Stoneskin')
	send_command('send @all bind %9  send Spikex Protect5 <stpc>')
	send_command('send @all bind %0  send Spikex Shell5 <stpc>')
	
	send_command('send @all bind %e  send Spikex Dia3')
	send_command('send @all bind !e  send Spikex Diaga')
	send_command('send @all bind ~%e send Spikex Saboteur')
	send_command('send @all bind %q  send Spikex Dispel')
	send_command('send @all bind !q  send Spikex Slow2')
	send_command('send @all bind ~%q send Spikex Paralyze2')
	send_command('send @all bind ^%q send Spikex Blind2')
	send_command('send @all bind @%q send Spikex Inundation')
	send_command('send @all bind %z  send Spikex Frazzle3')
	send_command('send @all bind !z  send Spikex Distract3')
	send_command('send @all bind ~%z send Spikex Silence')
	send_command('send @all bind ^%z send Spikex Addle2')
	send_command('send @all bind %`  send Spikex Sleep2')
	send_command('send @all bind !`  send Spikex Sleep2 <stnpc>')
	send_command('send @all bind %~` send Spikex Break <stnpc>')
	
	if player.sub_job == 'SCH' then
		send_command('lua l StratagemCounter')
		send_command('send @all bind %x send Spikex Accession')
		send_command('send @all bind !x send Spikex LightArts')
		send_command('send @all bind @x send Spikex AddendumWhite')
		send_command('send @all bind @4 send Spikex Windstorm')
		send_command('send @all bind %c send Spikex Manifestation')
		send_command('send @all bind !c send Spikex DarkArts')
		send_command('send @all bind @c send Spikex AddendumBlack')
	elseif player.sub_job == 'WAR' then
		send_command('send @all bind !z  send Spikex Defender')
		send_command('send @all bind %x  send Spikex Berserk')
		send_command('send @all bind ~%x send Spikex Warcry')
		send_command('send @all bind !e  send Spikex Provoke')
	elseif player.sub_job == 'RUN' then
		send_command('send @all bind !z  send Spikex Swordplay')
		send_command('send @all bind %x  send Spikex gs c rune')
		send_command('send @all bind ~%x send Spikex gs c cycle Runes')
		send_command('send @all bind ^x  send Spikex gs c cycleback Runes')
		send_command('send @all bind !x  send Spikex Vallation')
		send_command('send @all bind @x  send Spikex Pflug')
	elseif player.sub_job == 'NIN' then
		send_command('send @all bind %x  send Spikex UtsusemiNi')
		send_command('send @all bind !x  send Spikex UtsusemiIchi')
	end
end

function setup_weapon_keybinds()
	local main = current_weapon().main
	
	if main == 'Naegling' then
		send_command('send @all bind %1 qa Spikex WS "Savage Blade" t')
		send_command('send @all bind %2 qa Spikex WS "Chant du Cygne" t')
		send_command('send @all bind !1 qa Spikex WS "Red Lotus Blade" t')
		send_command('send @all bind !2 qa Spikex WS "Seraph Blade" t')
		send_command('send @all bind %3 qa Spikex WS "Sanguine Blade" t')
		send_command('send @all bind !3 qa Spikex WS "Circle Blade" t')
	
	elseif main == 'Crocea Mors' then
		send_command('send @all bind %1 qa Spikex WS "Red Lotus Blade" t')
		send_command('send @all bind %2 qa Spikex WS "Seraph Blade" t')
		send_command('send @all bind !1 qa Spikex WS "Savage Blade" t')
		send_command('send @all bind !2 qa Spikex WS "Chant du Cygne" t')
	
	elseif main == 'Maxentius' then
		send_command('send @all bind %1 qa Spikex WS "Black Halo" t')
	
	elseif main == 'Tauret' then
		send_command('send @all bind %1 qa Spikex WS "Evisceration" t')
		send_command('send @all bind %2 qa Spikex WS "Aeolian Edge" t')
	end
end

function setup_job_aliases()
	send_command('send @all alias imp gs c impact')
	send_command('send @all alias rb  send Spikex gs c spell_order RDM_Buffs.txt')
	send_command('send @all alias rb2 send Spikex gs c spell_order RDM_Buffs2.txt')
	send_command('send @all alias rb3 send Spikex gs c spell_order RDM_Buffs3.txt')
	send_command('send @all alias rbs send Spikex gs c spell_order RDM_BuffsSelf.txt')
	send_command('send @all alias av "Aquaveil"')
	
	send_command('alias fk input /party << Flaming Kick : WATER >>; qa Spikex MA Water t; qa Cissilea MA "Fire Threnody II" mt')
	send_command('alias ff input /party << Flashflood : THUNDER >>; qa Spikex MA Thunder t; qa Cissilea MA "Water Threnody II" mt')
	send_command('alias ig input /party << Icy Grasp : FIRE >>; qa Spikex MA Fire t; qa Cissilea MA "Ice Threnody II" mt')
	send_command('alias ef input /party << Eroding Flesh : WIND >>; qa Spikex MA Aero t; qa Cissilea MA "Earth Threnody II" mt')
	send_command('alias fs input /party << Fulminous Smash : STONE >>; qa Spikex MA Stone t; qa Cissilea MA "Ltng. Threnody II" mt')
	
	send_command('alias s3 qa Spikex MA "Stone III" t')
	send_command('alias w3 qa Spikex MA "Water III" t')
	send_command('alias a3 qa Spikex MA "Aero III" t')
	send_command('alias f3 qa Spikex MA "Fire III" t')
	send_command('alias b3 qa Spikex MA "Blizzard III" t')
	send_command('alias t3 qa Spikex MA "Thunder III" t')
	send_command('alias s4 qa Spikex MA "Stone IV" t')
	send_command('alias w4 qa Spikex MA "Water IV" t')
	send_command('alias a4 qa Spikex MA "Aero IV" t')
	send_command('alias f4 qa Spikex MA "Fire IV" t')
	send_command('alias b4 qa Spikex MA "Blizzard IV" t')
	send_command('alias t4 qa Spikex MA "Thunder IV" t')
	send_command('alias s5 qa Spikex MA "Stone V" t')
	send_command('alias w5 qa Spikex MA "Water V" t')
	send_command('alias a5 qa Spikex MA "Aero V" t')
	send_command('alias f5 qa Spikex MA "Fire V" t')
	send_command('alias b5 qa Spikex MA "Blizzard V" t')
	send_command('alias t5 qa Spikex MA "Thunder V" t')
end

function job_update(cmdParams, eventArgs) -- Runs on subjob change, and all the time randomly, needed to keep dual wield accurate
	check_dual_wield()
	casting = false
	customize_melee_set()
end

function user_unload()
	send_command('lua u debuffgrid')
end

function init_gear_sets()
	--- Gear Sets ---	
	gear.CapeMND 	= { name = "Sucellos's Cape", augments={'MND+20','Mag. Acc+20 /Mag. Dmg.+20','MND+10','"Fast Cast"+10','Phys. dmg. taken-10%',} }
	gear.CapeINT 	= { name = "Sucellos's Cape", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','INT+10','"Mag.Atk.Bns."+10',} }
	gear.CapeIWS 	= { name = "Sucellos's Cape", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','INT+10','Weapon skill damage +10%',} }
	gear.CapeSWS 	= { name = "Sucellos's Cape", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%',} }
	gear.CapeDW 	= { name = "Sucellos's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Dual Wield"+10','Phys. dmg. taken-10%',} }
	gear.Obi 		= { waist= "Hachirin-no-Obi" }
	gear.Immunobreak= { legs = "Chironic Hose" }
	
	--- Precast Sets ---
	sets.precast.JA['Chainspell']	= { body="Viti. Tabard +4" }
	--sets.precast.JA['Convert']		= { main="Murgleis" }
	sets.precast.JA['Saboteur']		= { hands="Leth. Ganth. +3" } -- sub="Diamond Aspis" but lose tp
	
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
	sets.precast.WS = {						-- 2378 HP
		ammo	= "Oshasha's Treatise",
		head	= "Viti. Chapeau +4",
		neck	= "Rep. Plat. Medal",
		ear1	= "Sherida earring",
		ear2	= "Ishvara earring",
		body	= "Egbesu Frock",	-- Vitiation Tabard +4
		hands	= "Atrophy Gloves +4",
		ring1	= "Cornelia's Ring",
		ring2	= "Epaminondas's Ring",
		back	= gear.CapeSWS,
		waist	= "Sailfi Belt +1",
		legs	= "Nyame Flanchard",
		feet	= "Leth. Houseaux +3",
		}	
	sets.precast.WS['Chant du Cygne'] = {
		ammo	= "Yetshila +1",
		head	= "Blistering Sallet +1",
		neck	= "Fotia Gorget",
		ear1	= "Sherida Earring",
		ear2	= "Cessance Earring",
		body	= "Malignance Tabard", -- For PDL
		hands	= "Malignance Gloves",
		ring1	= "Begrudging Ring",
		ring2	= "Ilabrat Ring",
		back	= gear.CapeSWS,
		waist	= "Sailfi Belt +1",
		legs	= "Zoar Subligar +1",
		feet	= "Leth. Houseaux +3", 
		}
	sets.precast.WS['Evisceration'] = sets.precast.WS['Chant du Cygne']
		
	sets.precast.WS['Aeolian Edge'] = {		-- 2358 HP
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
		waist	= "Orpheus's Sash",
		legs	= "Leth. Fuseau +3",
		feet	= "Leth. Houseaux +3",
		}
	sets.precast.WS['Sanguine Blade'] = {	-- 2312 HP
		ammo	= "Sroda Tathlum",
		head	= "Pixie Hairpin +1",
		neck	= "Sibyl Scarf",
		ear1	= "Malignance earring",
		ear2	= "Friomisi Earring",
		body	= "Lethargy Sayon +3",
		hands	= "Leth. Ganth. +3",
		ring1	= "Cornelia's Ring",
		ring2	= "Archon Ring",
		waist	= "Orpheus's Sash",
		legs	= "Leth. Fuseau +3",
		feet	= "Leth. Houseaux +3",
		}
	sets.precast.WS['Seraph Blade'] = {		-- 2358 HP
		ammo	= "Sroda Tathlum",
		head	= "Leth. Chappel +3",
		neck	= "Fotia Gorget",
		ear1	= "Malignance earring",
		ear2	= "Regal Earring",
		body	= "Lethargy Sayon +3",
		hands	= "Jhakri Cuffs +2",
		ring1	= "Cornelia's Ring",
		ring2	= "Weather. Ring",
		back	= gear.CapeSWS,
		waist	= "Orpheus's Sash",
		legs	= "Leth. Fuseau +3",
		feet	= "Leth. Houseaux +3",
		}
	sets.precast.WS['Red Lotus Blade'] = sets.precast.WS['Seraph Blade']	
	sets.precast.WS['Requiescat'] = set_combine(sets.precast.WS, {neck="Fotia Gorget"})
	
	--- Midcast Sets ---
	sets.midcast['Elemental Magic'] = {		-- 2340 HP
		ammo	= "Ghastly Tathlum +1",
		head	= "Leth. Chappel +3",
		neck	= "Sibyl Scarf",
		ear1	= "Malignance Earring",
		ear2	= "Friomisi Earring",
		body	= "Lethargy Sayon +3",
		hands	= "Leth. Ganth. +3",
		ring1	= "Freke Ring",
		ring2	= "Metamor. Ring +1",
		back	= gear.CapeINT,
		waist	= "Acuity Belt +1",
		legs	= "Leth. Fuseau +3",
		feet	= "Vitiation boots +4",
		}
		
	sets.midcast['Elemental Magic'].MB = {		-- 2340 HP
		ammo	= "Ghastly Tathlum +1",
		head	= "Ea Hat +1",
		neck	= "Sibyl Scarf",
		ear1	= "Malignance Earring",
		ear2	= "Friomisi Earring",
		body	= "Ea Houppe. +1",
		hands	= "Leth. Ganth. +3",
		ring1	= "Freke Ring",
		ring2	= "Metamor. Ring +1",
		back	= gear.CapeINT,
		waist	= "Acuity Belt +1",
		legs	= "Leth. Fuseau +3",
		feet	= "Vitiation boots +4",
		}
		
	sets.midcast['Enfeebling Magic'] = { -- Paralyze/2, Addle/2, Slow/2,	2378 HP
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
	sets.midcast.Dia = set_combine(sets.defense, {
		ammo	= "Regal Gem",				-- 10
		neck	= "Dls. Torque +2",			-- 10
		body	= "Lethargy Sayon +3",		-- 18
		back	= gear.CapeMND,				-- 10
		feet	= "Vitiation boots +4",		-- 10
		})
	sets.midcast['Dia'] = sets.midcast.Dia
	sets.midcast['Dia II'] = sets.midcast.Dia
	sets.midcast['Dia III'] = sets.midcast.Dia
	sets.midcast['Diaga'] = sets.midcast.Dia
		
	sets.midcast.EnfSkill = {
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
	sets.midcast['Gravity'] = sets.midcast.EnfAcc
	sets.midcast['Gravity II'] = sets.midcast.EnfAcc
	sets.midcast['Stun'] = sets.midcast.EnfAcc
	sets.midcast['Impact'] = sets.midcast.EnfAcc
	sets.midcast['Dispel'] = set_combine(sets.midcast.EnfAcc, {neck="Dls. Torque +2"})
	
	sets.midcast.EnfDur = {
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
		ammo	= "Staunch Tathlum +1",
		head	= "Leth. Chappel +3",	-- 10
		neck	= "Dls. Torque +2",		-- 25
		ear1	= "Alabaster Earring",
		ear2	= "Lethargy Earring",	-- 7/9
		body	= "Vitiation Tabard +4",-- 15
		hands	= "Atro. Gloves +4", 	-- 20
		ring1	= "Eihwaz Ring",		-- HP
		ring2	= "Etana Ring",			-- HP
		back 	= "Ghostfyre Cape",		-- 20
		waist	= "Embla Sash",			-- 10
		legs	= "Leth. Fuseau +3",	-- 10
		feet	= "Leth. Houseaux +3",	-- 55
		}
	sets.midcast.EnhOther = set_combine(sets.midcast['Enhancing Magic'], {
		body	= "Lethargy Sayon +3",
		hands	= "Lethargy Gantherots +3",
		})
	
	sets.midcast.EnhSkill = { 			-- 700	2624 HP Temper/2, Enspells
		main	= "Pukulatmuj +1",		-- 11
		sub		= "Forfend +1",			-- 10
		ammo	= "Homiliary",
		head	= "Befouled Crown",		-- 16
		neck	= "Melic Torque",		-- 10
		ear1	= "Mimir Earring",		-- 10
		ear2	= "Andoaa Earring",		-- 5
		body	= "Vitiation Tabard +4",-- 24
		hands	= "Viti. Gloves +4",  	-- 25
		ring1	= "Stikini Ring +1",	-- 8
		ring2	= "Stikini Ring +1",	-- 8
		back	= "Ghostfyre Cape",		-- 10 / 10
		waist	= {name="Plat. Mog. Belt",	priority= 1},	-- HP	Olympus Sash 5
		legs	= "Atrophy Tights +4", 	-- 22 / 22
		feet  	= "Leth. Houseaux +3",	-- 35
		}
	sets.midcast['Temper'] = sets.midcast.EnhSkill
	sets.midcast['Temper II'] = sets.midcast.EnhSkill
	sets.midcast['Enthunder'] = sets.midcast.EnhSkill
	sets.midcast['Enstone'] = sets.midcast.EnhSkill
	sets.midcast['Enaero'] = sets.midcast.EnhSkill
	sets.midcast['Enblizzard'] = sets.midcast.EnhSkill
	sets.midcast['Enfire'] = sets.midcast.EnhSkill
	sets.midcast['Enwater'] = sets.midcast.EnhSkill
	
	sets.midcast['Phalanx'] = {			-- 2593 HP
		ammo	= "Homiliary",
		head	= "Merlinic Hood",		-- +4
		neck	= "Dls. Torque +2",
		ear1	= {name="Tuisto Earring",	priority= 3},
		ear2	= "Lethargy Earring",
		body	= "Taeon Tabard",		-- +3
		hands	= "Taeon Gloves",  		-- +3
		ring1	= {name="Eihwaz Ring",		priority= 1},
		ring2	= {name="Etana Ring",		priority= 2},
		back	= "Ghostfyre Cape",
		waist	= "Embla Sash",
		legs	= "Chironic Hose", 		-- +4
		feet	= "Taeon Boots",		-- +3
		}
	sets.midcast['Phalanx II'] = sets.midcast['Phalanx']
	sets.midcast.SelfProt = set_combine(sets.midcast['Enhancing Magic'], {
		ear1	= "Brachyura Earring", })
	sets.midcast.GainSpell = set_combine(sets.midcast['Enhancing Magic'], {
		hands	= "Viti. Gloves +4", })
	sets.midcast.BarStatus = set_combine(sets.midcast['Enhancing Magic'], { 
		neck	= "Sroda Necklace", }) 
	sets.midcast.BarElement = set_combine(sets.midcast['Enhancing Magic'], { 
		legs	= "Shedir Seraweels", }) 		
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
	sets.midcast['Regen II'] = set_combine(sets.midcast['Enhancing Magic'], {
		main	= "Bolelabunga", })	  
		
	sets.midcast.Cure = {
		ammo	= "Staunch Tathlum +1",
		head	= "Nyame Helm",			-- HP
		neck	= "Nodens Gorget",		-- 5
		ear1	= "Malignance Earring",
		ear2	= "Alabaster Earring",
		body	= "Bunzi's Robe",		-- 15
		hands	= "Atro. Gloves +4", 
		ring1	= "Eihwaz Ring",		-- HP
		ring2	= "Etana Ring",			-- HP
		back 	= "Ghostfyre Cape",		-- 6
		--waist	= "Gishdubar Sash",		-- 10 Self
		waist	= "Plat. Mog. Belt",	-- HP
		legs	= "Atrophy Tights +4",
		feet	= "Atro. Boots +4",		-- HP
		}
	sets.midcast.CureWeather = set_combine(sets.midcast.Cure, {
		--main	= "Chatoyant Staff",
		--sub		= "Enki Strap",
		back	= "Twilight Cape",
		waist	= "Hachirin-no-Obi",
		})
		
	--- Engaged Sets ---
	sets.engaged = {						-- 35	2312 HP
		ammo	= "Coiste Bodhar",
		head	= "Malignance Chapeau",		-- 6%
		neck	= "Anu Torque",
		ear1	= "Sherida Earring",
		ear2	= "Alabaster Earring",		-- Dedition
		body	= "Malignance Tabard",		-- 4%
		hands	= "Malignance Gloves",		-- 4%
		ring1	= "Chirich Ring +1", 
		ring2	= "Chirich Ring +1",
		back	= "Null Shawl",
		waist	= "Sailfi Belt +1",			-- 9%
		legs	= "Malignance Tights",		-- 9%
		feet	= "Malignance Boots",		-- 3%
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
		waist	= "Plat. Mog. Belt",
		legs	= "Malignance Tights",
		feet	= "Malignance Boots",
		}
	sets.defense = {
		ammo	= "Staunch Tathlum +1",
		head	= "Null Masque",		-- 10
		neck	= "Warder's Charm +1",	
		ear1	= "Eabani Earring",
		ear2	= "Alabaster Earring",	-- 05
		body	= "Nyame Mail",			-- 09
		hands	= "Nyame Gauntlets",	-- 07
		ring1	= "Fortified Ring", 	-- Gurebu's Ring
		ring2	= "Murky Ring",			-- 10
		back	= "Null Shawl",
		waist	= "Null Belt",
		legs	= "Nyame Flanchard",	-- 08
		feet	= "Nyame Sollerets",	-- 07
		}
		
	--- Other Sets ---
	sets.hoxne = { ammo = "Hoxne Ampulla", waist = "Plat. Mog. Belt", }
	sets.idle = sets.defense
	
	sets.buff.Doom = {
		neck	= "Nicander's Necklace",	--30
		ring1	= "Blenmot's Ring",			--5
		ring2	= "Blenmot's Ring",			--5
		waist	= "Gishdubar Sash",			--10
	}
end

function customize_melee_set()
	local meleeSet = nil
	if incapacitated then equip(sets.defense) return end
	
	-- Set base set
	if state.OffenseMode.value == "Defense" or player.status == 'Idle' then
		meleeSet = sets.defense
	else
		if state.OffenseMode.value == "Hybrid" then
			meleeSet = sets.hybrid
		else
			meleeSet = sets.engaged
		end
	
		-- Haste update
		-- Haste:		0	10	15	30	45	Samba:	0	10	15	30	45
		-- DW Needed:	49	45	42	31	11			47	42	39	25	0
		if current_haste <= 35 then meleeSet = set_combine(meleeSet, {
			ear2	= "Suppanomimi",	-- Dual Wield +5%
			ear1	= "Eabani Earring",	-- Dual Wield +4%
			waist	= "Reiki Yotai",	-- Dual Wield +7%
			back	= gear.CapeDW,		-- Dual Wield +10%
			})
		elseif current_haste <= 40 then meleeSet = set_combine(meleeSet, {
			waist	= "Reiki Yotai",	-- Dual Wield +7%
			back	= gear.CapeDW,		-- Dual Wield +10%
			})
		elseif current_haste <= 45 then meleeSet = set_combine(meleeSet, {
			back	= gear.CapeDW,		-- Dual Wield +10%
			})
		end
	end	
	
	-- Weapon update
	local weapon_update = check_weapon()
	if weapon_update then
		meleeSet = set_combine(meleeSet, weapon_update)
	end
	
	-- Hoxne update
	if hoxne_equipped then meleeSet = set_combine(meleeSet, sets.hoxne)	end
	
	equip(meleeSet)
	
	if temp_weapons then
		temp_weapons = false
		toggle_weapon_lock(true)
	end
end

function current_weapon()
	return weapon_sets[state.WeaponType.value][state.WeaponSet.value]
end

function check_weapon()
	local WeaponUpdate = nil
	if temp_weapons then
		enable('main','sub')
		WeaponUpdate = {main = tempmain, sub = tempsub}

	elseif not weapon_lock then
		local weapon = current_weapon()
		local main_matches = player.equipment.main == weapon.main
		local sub_matches = player.equipment.sub == weapon.sub
		
		if not main_matches or not sub_matches then
			if dual_wield then
				WeaponUpdate = {main = weapon.main, sub = weapon.sub}
			else
				WeaponUpdate = {main = weapon.main, sub = "Diamond Aspis"}
			end
		end
	end
	
	if WeaponUpdate then 
		return WeaponUpdate
	else 
		return false 
	end
end

function update_haste()	
	local h = 0	
	
	if buffactive[33] then h = h + 30 end -- Haste - Asssumed II	
	if buffactive[580] then h = h + 35 end -- Geo-Haste - Assumed Dunna(35) Idris around (40)	
	if buffactive[604] then h = h + 15 end -- Mighty Guard
	if buffactive.march then -- 214 Marches
		if buffactive.march == 1 then h = h + 15 -- Asssumed Honor March
		elseif buffactive.march == 2 then h = h + 40 end -- Asssumed Honor March + Victory March
	end	
	
	if buffactive[1] then h = h - 100 end -- Weakness	
	if buffactive[13] then h = h - 25 end -- Slow - Guessed mid range, somewhere 7~40	
	if buffactive[565] then h = h - 20 end -- Geo-Slow - Assumed max potency 1~20
	if buffactive[194] then h = h - 25 end -- Elegy - Assumed I, II would be 50
	
	if h > 45 then h = 45 end -- Can't have more than 45 magic haste, samba is ability haste though
	if samba_active then h = h + 5 end -- 370
	--print('Current Haste: '..h)
	current_haste = h
	customize_melee_set()
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
	elseif buff == "sleep" then
		if gain then
			incapacitated = true
			if weapon_lock then save_temp_weapons() end
			enable('main')
			equip({main = 'Caliburnus'})
			disable('main')
			return
		else
			if not weapon_lock then enable('main') end
			incapacitated = false
			customize_melee_set()
		end
	elseif buff == "terror" or buff == "petrification" or buff == "stun" then
		if gain then
			incapacitated = true
		else
			incapacitated = false
		end
		customize_melee_set()
	elseif buff == "silence" then
		if gain then
			send_command('@input /p Silenced.')
			silenced = true
			if not echo_running then auto_echo_drops() end
		else
			silenced = false
		end
	elseif buff == "Spontaneity" and casting_impact then
		if gain then send_command('qa Spikex MA "Impact" t') casting_impact = false end
		
	elseif buff == "Composure" then
		if start_order then send_command('qa Spikex MA "Haste II"') end
		
	elseif buff == "Haste" and gain then
		if start_order then
			coroutine.schedule(function() send_command('exec '..use_file) end, 4)	
			start_order = false
		end
	end
	
	if S{'weakness', 'slow', 'Haste', 'Elegy', 'March', 'Haste Daze', 'Mighty Guard'}:contains(buff) then update_haste() end
end

function job_post_pretarget(spell, action, spellMap, eventArgs)
	local cancel = false
	if incapacitated or midaction() or casting then
		cancel = true
		
	elseif spell.action_type == 'Magic' then -- Don't change gear on CD
		local recast = windower.ffxi.get_spell_recasts()[spell.recast_id]
		if recast and recast >= 1 then cancel = true end
		
	elseif spell.type == 'WeaponSkill' then
		if player.tp <= 1000 then cancel = true	end
	end
	
	if cancel then
		cancel_spell()
		eventArgs.cancel = true
		eventArgs.handled = true
		return
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
	casting = true
	cast_timer_id = (cast_timer_id or 0) + 1
	local this_timer = cast_timer_id
	coroutine.schedule(function()
		if this_timer ~= cast_timer_id then return end
		casting = false
	end, 4)
end

function job_post_midcast(spell, action, spellMap, eventArgs)
	local midcast_update = nil
	if spell.action_type == 'Magic' then
		if spell.skill == 'Enhancing Magic' then
			if spell.target.type ~= 'SELF' then
				midcast_update = sets.midcast.EnhOther
				
			elseif spell.english:startswith('Phalanx') then
				if dual_wield then
					midcast_update = {main="Sakpata's Sword",sub="Colada"}
				else
					midcast_update = {main="Sakpata's Sword",sub="Forfend +1"}
				end
			elseif spell.english:startswith('Gain') then
				midcast_update = sets.midcast.GainSpell
			
			elseif (spell.english:startswith('Shell') or 
				spell.english:startswith('Protect')) then
					midcast_update = sets.midcast.SelfProt
					
			elseif barstatus:contains(spell.english) then
				midcast_update = sets.midcast.BarStatus
			end
			if free_cast then
				midcast_update = set_combine(midcast_update, {sub="Ammurapi Shield"})
			end
		elseif spell.skill == 'Enfeebling Magic' then
			if free_cast then
				if S{'Paralyze II','Slow II','Addle II','Distract III','Frazzle III','Poison II'}:contains(spell.english) then
					midcast_update = {main="Daybreak",sub="Ammurapi Shield"}
				else
					midcast_update = {main="Crocea Mors",sub="Ammurapi Shield"}
				end
			end
			if S{'Frazzle II','Gravity','Gravity II','Stun','Impact','Dispel','Sleep','Sleep II','Sleepga','Sleepga II','Bind','Break','Silence','Inundation'}:contains(spell.english) and free_cast then
				midcast_update = set_combine(midcast_update, {range="Ullr"})
			else
				midcast_update = set_combine(midcast_update, {ammo="Regal Gem"})
			end
			if state.Immunobreak.value == true then
				midcast_update = set_combine(midcast_update, gear.Immunobreak)
			end
		elseif spell.english:startswith('Cure') then
			if free_cast then
				midcast_update = {main="Daybreak",sub="Ammurapi Shield"}
			end
			if world.weather_element == 'Light' or 
			world.day_element == 'Light' then
				midcast_update = set_combine(midcast_update, sets.midcast.CureWeather)
			end
		elseif spell.skill == 'Elemental Magic' then
			if free_cast then
				if dual_wield then
					midcast_update = {main="Bunzi's Rod",sub="Daybreak"}
				else
					midcast_update = {main="Bunzi's Rod",sub="Ammurapi Shield"}
				end
			end
			if magic_bursting then
				midcast_update = set_combine(midcast_update, sets.midcast['Elemental Magic'].MB)
			end
			if spell.element == world.weather_element and 
			(get_weather_intensity() == 2 and 
			spell.element ~= elements.weak_to[world.day_element]) then
				midcast_update = set_combine(midcast_update, gear.Obi)
			-- Target distance under 1.7 yalms.
			elseif spell.target.distance < (1.7 + spell.target.model_size) then
				midcast_update = set_combine(midcast_update, {waist="Orpheus's Sash"})
			-- Matching day and weather.
			elseif spell.element == world.day_element and spell.element == world.weather_element then
				midcast_update = set_combine(midcast_update, gear.Obi)
			-- Target distance under 8 yalms.
			elseif spell.target.distance < (8 + spell.target.model_size) then
				midcast_update = set_combine(midcast_update, {waist="Orpheus's Sash"})
			-- Match day or weather.
			elseif spell.element == world.day_element or 
			spell.element == world.weather_element then
				midcast_update = set_combine(midcast_update, gear.Obi)
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
	casting = false
	cast_timer_id = (cast_timer_id or 0) + 1
	if spell.name == 'Impact' then
		enable('head', 'body')
	end
	customize_melee_set()
end

function job_state_change(field, new_value, old_value)
	if field == 'Weapon Type' or field == 'Weapon Set' then 
		if field == 'Weapon Type' then
			state.WeaponSet:set('A')
		end
		setup_weapon_keybinds()
		if weapon_lock then toggle_weapon_lock(false) end
	end
end

function job_self_command(cmdParams, eventArgs)	
	if cmdParams[1] == 'startup' then
		toggle_weapon_lock(false)
		free_cast = false
		setup_job_aliases()
		check_dual_wield()
		update_haste()
		setup_weapon_keybinds()
		coroutine.schedule( function() send_command('input /lockstyleset 4') end, 5)
		
	elseif cmdParams[1] == 'samba' then
		if cmdParams[2] then samba_active = true
		else samba_active = false end
		update_haste()
		
	elseif cmdParams[1] == 'toggle_hoxne' then
		if hoxne_equipped then
			enable('range', 'ammo')
			hoxne_equipped = false
			msg = 'Unequipped'
		else
			equip({ammo = "Hoxne Ampulla"})
			disable('range', 'ammo')
			hoxne_equipped = true
			msg = 'Equipped'
			coroutine.schedule( function() 
				windower.add_to_chat(210, '<< Hoxne Ready to Use >>')
				send_command('@input /item "Hoxne Ampulla" <me>')
			end, 6)
		end
		windower.add_to_chat(210, '<< Hoxne '..msg.. ' >>')
		customize_melee_set()
		
	elseif cmdParams[1] == 'next_spell' then
		send_command(spam_list[nextsp] .. cmdParams[2])
		nextsp = nextsp % #spam_list + 1
		
	elseif cmdParams[1] == 'burst' then
		--print('Magic burst detected')
		if burst_timer then
			coroutine.close(burst_timer)
			burst_timer = nil
		end
		
		magic_bursting = true
		burst_timer = coroutine.schedule(function() 
			magic_bursting = false
			burst_timer = nil
		end, 8)
			
	elseif cmdParams[1] == 'impact' then
		local target = windower.ffxi.get_mob_by_target('t')
		if target then	
			enable('head', 'body')
			equip({head = "empty", body = "Crepuscular Cloak"})
			disable('head', 'body')
			local spontaneity_recast = windower.ffxi.get_ability_recasts()[37]
			if spontaneity_recast > 0 then
				send_command('qa Spikex MA "Impact" t')
			else
				casting_impact = true
				send_command('qa Spikex JA "Spontaneity"')
			end
		end
	elseif cmdParams[1] == 'enspell' then
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
			
	elseif cmdParams[1] == 'lock' then
		weapon_lock = not weapon_lock
		toggle_weapon_lock(weapon_lock)
		if not weapon_lock then customize_melee_set() end
		windower.add_to_chat(210, '<< Weapon Lock: '..tostring(weapon_lock).. ' >>')
		
	elseif cmdParams[1] == 'free' then
		free_cast = not free_cast
		if weapon_lock then toggle_weapon_lock(false) end
		windower.add_to_chat(210, '<< Free Cast: '..tostring(free_cast).. ' >>')
		
	elseif cmdParams[1] == 'rune' then
		send_command('@input /ja '..state.Runes.value..' <me>')
		
	elseif cmdParams[1] == 'cure_lowest' then
		send_command('Cure4 '..get_lowest_hp_member().id)
		
	elseif cmdParams[1] == 'spell_order' then
		use_file = cmdParams[2]
		start_order = true
		send_command('cancel haste')
		if windower.ffxi.get_ability_recasts()[50] > 0 then
			send_command('qa Spikex MA "Haste II"')
			
		else
			send_command('cancel Composure')
			coroutine.schedule(function() send_command('qa Spikex JA Composure') end, 1)				
		end
	end
end

function get_lowest_hp_member()
	local party = windower.ffxi.get_party()
	local lowest_member = nil
	local lowest_hpp = 101 -- Anything real will be <= 100
	
	for key, member in pairs(party) do
		if type(member) == 'table' and key:match('^p%d') and member.hpp then
			if member.hpp < lowest_hpp then
				lowest_hpp = member.hpp
				lowest_member = member
			end
		end
	end
	
	return lowest_member
end

function save_temp_weapons()
	temp_weapons = true
	tempmain = player.equipment.main
	tempsub = player.equipment.sub
	toggle_weapon_lock(false)
end

function toggle_weapon_lock(should_enable)
	if should_enable then
		weapon_lock = true
		disable('main','sub','range')
	else
		weapon_lock = false
		enable('main','sub')
		if not hoxne_equipped then enable('range', 'ammo') end
	end
end

function auto_echo_drops ()
    if not silenced then echo_running = false return end
    echo_running = true
	send_command('input /item "Echo Drops" <me>')
	coroutine.schedule(function() auto_echo_drops() end, 2)
end

function check_dual_wield()
	if player.sub_job and player.sub_job_level >= 20 then
		if player.sub_job == 'NIN' or player.sub_job == 'DNC' then
			dual_wield = true
		return end
	end
	dual_wield = false
end