function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
end

--------------------------------------------------------		
--				7				8				9			--
-- 			HexaStrike		IndiBuff		GeoBuff			--
--	ALT		Moonlight		EntrustBuff		SuperBuff		--
-- 	SHFT	AoE				Refsh/DivineS	Cure4<st>		--
-- 	CTRL	Clnse/Slow		Clns2/Paraly	Bars/Silenc		--
-- 	WIN		Nuke			Haste			Sleep			--
--															--
--------------------------------------------------------	

function job_setup()	
	windower.send_command('sta !packets on') -- For SendTarget to work
	
    state.WeaponLock = M(false, 'Weapon Lock')	
	state.WeaponSet = M{['description']='Weapon Set', 'Staff', 'Club'}
    state.OffenseMode:options('Normal', 'Defense')
    send_command('bind @w gs c toggle WeaponLock')	
    send_command('bind %capslock gs c cycle WeaponSet')	
    send_command('bind @S gs c cycle OffenseMode')
	
	indiBuff	= 'IndiFury'
	entrustBuff = 'IndiHaste'
	geoBuff		= 'GeoFrailty'
	cleanse 	= 'Cursna'
	cleanse2 	= 'Paralyna'
	barspellra	= 'Barblizzra'
	nuke		= 'Water5'
	
end
function user_setup()

	send_command('send @all alias ra send Cissilea /RadialArcana') 
	send_command('send @all alias ma send Cissilea /MendingHalation') 
	send_command('send @all alias fc send Cissilea /FullCircle') 
	
	send_command('send @all alias imab send Cissilea /IndiAcumen') 
	send_command('send @all alias imev send Cissilea /IndiAttunement') 
	send_command('send @all alias idef send Cissilea /IndiBarrier') 
	send_command('send @all alias imad send Cissilea /IndiFade') 
	send_command('send @all alias imde send Cissilea /IndiFend') 
	send_command('send @all alias imac send Cissilea /IndiFocus') 
	send_command('send @all alias ided send Cissilea /IndiFrailty') 
	send_command('send @all alias iatt send Cissilea /IndiFury') 
	send_command('send @all alias igra send Cissilea /IndiGravity') 
	send_command('send @all alias ihas send Cissilea /IndiHaste') 
	send_command('send @all alias imed send Cissilea /IndiLanguor') 
	send_command('send @all alias imdd send Cissilea /IndiMalaise') 
	send_command('send @all alias ipar send Cissilea /IndiParalysis') 
	send_command('send @all alias ipoi send Cissilea /IndiPoison') 
	send_command('send @all alias iacc send Cissilea /IndiPrecision') 
	send_command('send @all alias iref send Cissilea /IndiRefresh') 
	send_command('send @all alias ireg send Cissilea /IndiRegen') 
	send_command('send @all alias iacd send Cissilea /IndiSlip') 
	send_command('send @all alias islo send Cissilea /IndiSlow') 
	send_command('send @all alias ievd send Cissilea /IndiTorpor') 
	send_command('send @all alias imcd send Cissilea /IndiVex') 
	send_command('send @all alias ieva send Cissilea /IndiVoidance') 
	send_command('send @all alias iatd send Cissilea /IndiWilt') 
	send_command('send @all alias iagi send Cissilea /IndiAgi') 
	send_command('send @all alias ichr send Cissilea /IndiChr') 
	send_command('send @all alias idex send Cissilea /IndiDex') 
	send_command('send @all alias iint send Cissilea /IndiInt') 
	send_command('send @all alias istr send Cissilea /IndiStr') 
	send_command('send @all alias ivit send Cissilea /IndiVit') 
	
	send_command('send @all alias gmab send Cissilea /GeoAcumen') 
	send_command('send @all alias gmev send Cissilea /GeoAttunement') 
	send_command('send @all alias gdef send Cissilea /GeoBarrier') 
	send_command('send @all alias gmad send Cissilea /GeoFade') 
	send_command('send @all alias gmde send Cissilea /GeoFend') 
	send_command('send @all alias gmac send Cissilea /GeoFocus') 
	send_command('send @all alias gded send Cissilea /GeoFrailty') 
	send_command('send @all alias gatt send Cissilea /GeoFury') 
	send_command('send @all alias ggra send Cissilea /GeoGravity') 
	send_command('send @all alias ghas send Cissilea /GeoHaste') 
	send_command('send @all alias gmed send Cissilea /GeoLanguor') 
	send_command('send @all alias gmdd send Cissilea /GeoMalaise') 
	send_command('send @all alias gpar send Cissilea /GeoParalysis') 
	send_command('send @all alias gpoi send Cissilea /GeoPoison') 
	send_command('send @all alias gacc send Cissilea /GeoPrecision') 
	send_command('send @all alias gref send Cissilea /GeoRefresh') 
	send_command('send @all alias greg send Cissilea /GeoRegen') 
	send_command('send @all alias gacd send Cissilea /GeoSlip') 
	send_command('send @all alias gslo send Cissilea /GeoSlow') 
	send_command('send @all alias gevd send Cissilea /GeoTorpor') 
	send_command('send @all alias gmcd send Cissilea /GeoVex') 
	send_command('send @all alias geva send Cissilea /GeoVoidance') 
	send_command('send @all alias gatd send Cissilea /GeoWilt') 
	send_command('send @all alias gagi send Cissilea /GeoAgi') 
	send_command('send @all alias gchr send Cissilea /GeoChr') 
	send_command('send @all alias gdex send Cissilea /GeoDex') 
	send_command('send @all alias gint send Cissilea /GeoInt') 
	send_command('send @all alias gstr send Cissilea /GeoStr') 
	send_command('send @all alias gvit send Cissilea /GeoVit') 
	
	send_command('send @all alias s4 sa /Stone4') 
	send_command('send @all alias s5 sa /Stone5') 
	send_command('send @all alias sga sa /Stonera3') 
	send_command('send @all alias w4 sa /Water4') 
	send_command('send @all alias w5 sa /Water5') 
	send_command('send @all alias wga sa /Watera3') 
	send_command('send @all alias a4 sa /Aero4') 
	send_command('send @all alias a5 sa /Aero5') 
	send_command('send @all alias aga sa /Aera3') 
	send_command('send @all alias f4 sa /Fire4') 
	send_command('send @all alias f5 sa /Fire5') 
	send_command('send @all alias fga sa /Fira3') 
	send_command('send @all alias b4 sa /Blizzard4') 
	send_command('send @all alias b5 sa /Blizzard5') 
	send_command('send @all alias bga sa /Blizzara3') 
	send_command('send @all alias t4 sa /Thunder4') 
	send_command('send @all alias t5 sa /Thunder5') 
	send_command('send @all alias tga sa /Thundara3') 
	
	send_command('send @all bind  numpad7  sta Cissilea ShellCrusher') 
	send_command('send @all bind !numpad7  sta Cissilea SpiritTaker') 
	send_command('send @all bind  numpad8 send Cissilea '..indiBuff) 
	send_command('send @all bind  numpad9  sta Cissilea GeoFrailty') 
	send_command('send @all bind !numpad8 send Cissilea gs c entrustbuff')
	send_command('send @all bind !numpad9 send Cissilea gs c superbuff')	
	send_command('send @all bind ~numpad7  sta Cissilea Dia2')		
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
	elseif player.sub_job == 'SCH' then
		send_command('lua l StratagemCounter')
		send_command('send @all bind ^numpad7 send Cissilea gs c sleep') 
		send_command('send @all bind ^numpad8  sta Cissilea Windstorm <stpc>') 
		send_command('send @all bind ^numpad9 send Cissilea gs c aoecure') 
	end
	
	send_command('wait 5; input /lockstyleset 1')
end

function init_gear_sets()
    --- Weapon Sets ---
    sets.Club 	= 	{ main="Daybreak", sub="Culminus"}
    sets.Staff 	= 	{ main="Malignance Pole", sub="Enki Strap"}
	
	gear.REGENCape = { name="Nantosuelta's Cape", augments={'HP+60','Accuracy+20 Attack+20','Pet: "Regen"+10','Pet: "Regen"+5',}}
	gear.MDCape = { name="Nantosuelta's Cape", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','Magic Damage +10','"Mag.Atk.Bns."+10',}}
	gear.FCcape = { name="Nantosuelta's Cape", augments={'MND+20','Mag. Acc+20 /Mag. Dmg.+20','"Fast Cast"+10',}}
	
    --- Precast Sets ---	
	sets.precast.JA['Full Circle'] = { head = "Azimuth hood +3" }
	sets.precast.JA['Bolster'] = { body = "Bagua Tunic" }
	
    sets.precast.FC = {
		head	= "Nahtirah Hat",
		neck	= "Orunmila's Torque",
		ring1 	= "Kishar Ring",
		ring2 	= "Jhakri Ring",
		legs	= "Geomancy Pants +2",
		feet  	= "Jhakri Pigaches +2",
		back	= gear.FCcape,
		}
	sets.precast.FC['Elemental Magic'] = set_combine(sets.precast.FC, {
		head  	= "Mallquis Chapeau +1",
		neck	= "Orunmila's Torque",
		body  	= "Azimuth Coat +3",
		hands 	= "Mallquis Cuffs +1",
		legs  	= "Mallquis Trews +1",
		feet  	= "Azimuth Gaiters +3",
		ring1	= "Mallquis Ring",
		})
	sets.precast.FC['Healing Magic'] = set_combine(sets.precast.FC, {
		neck	="Orunmila's Torque",
		head	= "Vanya Hood",
		legs	= "Vanya Slops",
		feet	= "Vanya Clogs",
		})
		
    sets.precast.WS = { 
		ear1	= "Moonshade earring",
		}
    sets.precast.WS['Hexa Strike'] = {}

    --- Midcast Sets ---
    sets.midcast = { 
		ring2  	= "Adoulin ring",
		}
	sets.midcast['Geomancy'] = set_combine(sets.midcast, {
        neck     = "Bagua Charm +2",
		})
	sets.midcast['Indicolure'] = set_combine(sets.midcast, { 
		main	= "Gada",
		back	= "Lifestream Cape",
		legs	= "Bagua Pants +3",
		feet	= "Azimuth Gaiters +3" 
		})
    sets.midcast['Elemental Magic'] = set_combine(sets.midcast, {
		head  	= "Azimuth hood +3",
		neck	= "Mizu. Kubikazari",
		ear1  	= "Static Earring",
		ear2  	= "Friomisi Earring",
		body  	= "Azimuth Coat +3",
		hands 	= "Jhakri cuffs +2",
		legs  	= "Jhakri Slops +2",
		feet  	= "Jhakri Pigaches +2",
		ring1	= "Mallquis Ring",
		ring2	= "Jhakri ring",
		back	= gear.MDcape,
		})
		
	sets.midcast['Enfeebling Magic'] = set_combine(sets.midcast, {
		head	= "Geomancy Galero +2",
		body	= "Geomancy Tunic +2",
		hands	= "Geomancy mitaines +4",
		legs	= "Geomancy Pants +2",
		feet	= "Geomancy Sandals +2",
		ear1	= "Vor Earring",
		ear2	= "Malignance Earring",
		ring1	= "Etana Ring",
		ring2	= "Jhakri Ring",
		back	= gear.MDcape,
    })	
	
	sets.midcast.Cure = set_combine(sets.midcast, {
		head	= "Vanya Hood",
		legs	= "Vanya Slops",
		feet	= "Vanya Clogs",
		})

    --- Engaged Sets ---
    sets.engaged = {
		range	= "Dunna",
		head  	= "Azimuth hood +3",
		neck  	= "Null Loop",
		ear1  	= "Alabaster Earring",
		ear2  	= "Flashward Earring",
		body  	= "Azimuth Coat +3",
		hands 	= "Geomancy mitaines +4",
		ring1 	= "Gurebu's Ring",
		ring2 	= "Rajas Ring",
		back  	= gear.REGENCape,
		waist 	= "Null Belt",
		legs  	= "Geomancy Pants +2",
		feet  	= "Azimuth Gaiters +3",
		}

    sets.defense = {
		range	= "Dunna",
		head  	= "Azimuth hood +3",
		neck  	= "Sanctity Necklace",
		ear1  	= "Vor Earring",
		ear2  	= "Flashward Earring",
		body  	= "Geomancy Tunic +2",
		hands 	= "Geomancy mitaines +4",
		ring1 	= "Etana Ring",
		ring2  	= "Gurebu's Ring",
		back  	= gear.REGENCape, 
		waist 	= "Witful Belt",
		legs  	= "Geomancy Pants +2",
		feet  	= "Geomancy Sandals +2",
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
    elseif cmdParams[1]:lower() == 'sleep' then
		if buffactive["Dark Arts"] == 1 then
			local recasts = windower.ffxi.get_spell_recasts()
			if recasts[253] > 0 and recasts[259] > 0 then return end
			if buffactive["Manifestation"] == 1 then
				if recasts[259] <= 0 then -- Sleep 2
					send_command('Sleep2')
				else
					send_command('Sleep')
				end
			else
				send_command('Manifestation')
			end
		else
			send_command('DarkArts')
		end
    elseif cmdParams[1]:lower() == 'aoecure' then
		if buffactive["Light Arts"] == 1 then
			if buffactive["Accession"] == 1 then
				send_command('Cure4')				
			else
				send_command('Accession')
			end
		else
			send_command('LightArts')
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
	if state.WeaponSet.value == "Club" then
		send_command('send @all bind  numpad7  sta Cissilea Realmrazer') 
		send_command('send @all bind !numpad7  sta Cissilea Moonlight') 
	elseif state.WeaponSet.value == "Staff" then
		send_command('send @all bind  numpad7  sta Cissilea ShellCrusher') 
		send_command('send @all bind !numpad7  sta Cissilea SpiritTaker') 
	end
    equip(sets[state.WeaponSet.current])
    equip(sets[state.WeaponSet.current])
end
function job_update(cmdParams, eventArgs)
    equip(sets[state.WeaponSet.current])
end