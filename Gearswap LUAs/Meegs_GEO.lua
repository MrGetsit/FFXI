function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
end

function job_setup()	
    state.WeaponLock = M(false, 'Weapon Lock')
    state.OffenseMode:options('Normal', 'Defense')
    send_command('bind @w gs c toggle WeaponLock')	
    send_command('bind @S gs c cycle OffenseMode')
end

function user_setup()
	send_command('send @all alias gra send Meegs /RadialArcana') 
	send_command('send @all alias gma send Meegs /MendingHalation') 
	send_command('send @all alias gfc send Meegs /FullCircle') 
	send_command('send @all alias snk2 exec sneak2.txt')
	
	send_command('send @all alias imab send Meegs /IndiAcumen') 
	send_command('send @all alias imev send Meegs /IndiAttunement') 
	send_command('send @all alias idef send Meegs /IndiBarrier') 
	send_command('send @all alias imad send Meegs /IndiFade') 
	send_command('send @all alias imde send Meegs /IndiFend') 
	send_command('send @all alias imac send Meegs /IndiFocus') 
	send_command('send @all alias ided send Meegs /IndiFrailty') 
	send_command('send @all alias iatt send Meegs /IndiFury') 
	send_command('send @all alias igra send Meegs /IndiGravity') 
	send_command('send @all alias ihas send Meegs /IndiHaste') 
	send_command('send @all alias imed send Meegs /IndiLanguor') 
	send_command('send @all alias imdd send Meegs /IndiMalaise') 
	send_command('send @all alias ipar send Meegs /IndiParalysis') 
	send_command('send @all alias ipoi send Meegs /IndiPoison') 
	send_command('send @all alias iacc send Meegs /IndiPrecision') 
	send_command('send @all alias iref send Meegs /IndiRefresh') 
	send_command('send @all alias ireg send Meegs /IndiRegen') 
	send_command('send @all alias iacd send Meegs /IndiSlip') 
	send_command('send @all alias islo send Meegs /IndiSlow') 
	send_command('send @all alias ievd send Meegs /IndiTorpor') 
	send_command('send @all alias imcd send Meegs /IndiVex') 
	send_command('send @all alias ieva send Meegs /IndiVoidance') 
	send_command('send @all alias iatd send Meegs /IndiWilt') 
	send_command('send @all alias iagi send Meegs /IndiAgi') 
	send_command('send @all alias ichr send Meegs /IndiChr') 
	send_command('send @all alias idex send Meegs /IndiDex') 
	send_command('send @all alias iint send Meegs /IndiInt') 
	send_command('send @all alias imnd send Meegs /IndiMnd') 
	send_command('send @all alias istr send Meegs /IndiStr') 
	send_command('send @all alias ivit send Meegs /IndiVit') 
	
	send_command('send @all alias gmab send Meegs /GeoAcumen') 
	send_command('send @all alias gmev send Meegs /GeoAttunement') 
	send_command('send @all alias gdef send Meegs /GeoBarrier') 
	send_command('send @all alias gmad send Meegs /GeoFade') 
	send_command('send @all alias gmde send Meegs /GeoFend') 
	send_command('send @all alias gmac send Meegs /GeoFocus') 
	send_command('send @all alias gded send Meegs /GeoFrailty') 
	send_command('send @all alias gatt send Meegs /GeoFury') 
	send_command('send @all alias ggra send Meegs /GeoGravity') 
	send_command('send @all alias ghas send Meegs /GeoHaste') 
	send_command('send @all alias gmed send Meegs /GeoLanguor') 
	send_command('send @all alias gmdd send Meegs /GeoMalaise') 
	send_command('send @all alias gpar send Meegs /GeoParalysis') 
	send_command('send @all alias gpoi send Meegs /GeoPoison') 
	send_command('send @all alias gacc send Meegs /GeoPrecision') 
	send_command('send @all alias gref send Meegs /GeoRefresh') 
	send_command('send @all alias greg send Meegs /GeoRegen') 
	send_command('send @all alias gacd send Meegs /GeoSlip') 
	send_command('send @all alias gslo send Meegs /GeoSlow') 
	send_command('send @all alias gevd send Meegs /GeoTorpor') 
	send_command('send @all alias gmcd send Meegs /GeoVex') 
	send_command('send @all alias geva send Meegs /GeoVoidance') 
	send_command('send @all alias gatd send Meegs /GeoWilt') 
	send_command('send @all alias gagi send Meegs /GeoAgi') 
	send_command('send @all alias gchr send Meegs /GeoChr') 
	send_command('send @all alias gdex send Meegs /GeoDex') 
	send_command('send @all alias gint send Meegs /GeoInt') 
	send_command('send @all alias gmnd send Meegs /GeoMnd') 
	send_command('send @all alias gstr send Meegs /GeoStr') 
	send_command('send @all alias gvit send Meegs /GeoVit')
	
	send_command('send @all alias wbf qa Meegs MA Barfira')
	send_command('send @all alias wbb qa Meegs MA Barblizzara')
	send_command('send @all alias wba qa Meegs MA Baraera')
	send_command('send @all alias wbs qa Meegs MA Barstonra')
	send_command('send @all alias wbt qa Meegs MA Barthundra')
	send_command('send @all alias wbw qa Meegs MA Barwatera')
	
	send_command('send @all alias wbam qa Meegs MA Baramnesra')
	send_command('send @all alias wbpa qa Meegs MA Barparalyzra')
	send_command('send @all alias wbpe qa Meegs MA Barpetra')
	send_command('send @all alias wbpo qa Meegs MA Barpoisonra')
	send_command('send @all alias wbsl qa Meegs MA Barsleepra')
	
	send_command('wait 5; input /lockstyleset 1')
end

function init_gear_sets()
    --- Gear Sets ---
	gear.CapePT = { name = "Nantosuelta's Cape", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Pet: "Regen"+10','Pet: "Regen"+5'} }
	gear.CapeMA = { name = "Nantosuelta's Cape", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','Magic Damage +10','"Mag.Atk.Bns."+10'} }
	gear.CapeFC	= { name = "Nantosuelta's Cape", augments={'"Fast Cast"+10'} }
	gear.CapeWS	= { name = "Nantosuelta's Cape", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%'} }
	
    --- Precast Sets ---	
	sets.precast.JA['Bolster']			= { body = "Bagua Tunic" }
	sets.precast.JA['Full Circle']		= { head = "Azimuth Hood +3" }
	sets.precast.JA['Life Cycle']		= { body = "Geomancy Tunic", back = gear.CapePT }
	sets.precast.JA['Mending Halation']	= { legs = "Bagua Pants +3" }
	sets.precast.JA['Radial Arcana']	= { feet = "Bagua Sandals +4" }
	
    sets.precast.FC = {					-- 54
		range  	= "Dunna",				-- 3
		head	= { name="Vanya Hood", augments={'MP+50','"Fast Cast"+10','Haste+2%',}},
		--neck	= "Orunmila's Torque",	-- 5
		--ear1	= "Malignance Earring",	-- 4
		ear2	= "Etiolation Earring",	-- 1
		body  	= "Agwu's Robe",		-- 8
		hands 	= "Agwu's Gages",		-- 6
		--ring2	= "Kishar Ring",		-- 4
		waist 	= "Embla Sash",			-- 5
		back	= gear.CapeFC,			-- 10
		legs	= "Agwu's Slops",		-- 7
		feet  	= "Agwu's Pigaches",	-- 4
		}
	sets.precast.FC['Elemental Magic'] = set_combine(sets.precast.FC, { 
		hands	= "Bagua Mitaines",		-- 11%
		})	
	sets.precast.FC['Healing Magic'] = set_combine(sets.precast.FC, { 
		ear2	= "Mendicant's Earring",	-- 5%
		})	
		
	sets.precast.WS = {
		ammo	= "Oshasha's Treatise",
		head	= "Agwu's Cap",
		neck	= "Rep. Plat. Medal",
		ear1	= "Alabaster earring",
		ear2	= "Moonshade earring",
		body	= "Agwu's Robe",
		hands	= "Agwu's Gages",
		ring1	= "Murky Ring",
		ring2	= "Gurebu's Ring",
		back	= gear.CapeWS,
		waist	= "Null Belt",
		legs	= "Nyame Flanchard",
		feet	= "Agwu's Pigaches",
		}	

    --- Midcast Sets ---
	sets.midcast['Geomancy'] = {
		--main	= "Idris",
		range	= "Dunna",
		head	= "Azimuth Hood +3",
        neck	= "Bagua Charm +2",
		hands	= "Geo. Mitaines +4",
		back	= "Lifestream Cape",
		legs	= "Bagua Pants +3",
		feet	= "Azimuth Gaiters +3",
		}
		
    sets.midcast['Elemental Magic'] = {
		head	= "Azimuth Hood +3",
		body	= "Azimuth Coat +3",
		hands	= "Azimuth Gloves +3",
		legs	= "Azimuth Tights +3",
		feet	= "Azimuth Gaiters +3",
		}
	
	sets.midcast['Enfeebling Magic'] = {}
	
	sets.midcast['Healing Magic'] = {
		head	= "Vanya Hood",
		ring2	= "Janniston Ring",
		legs	= "Vanya Slops",
		feet	= "Vanya Clogs",
		}

    --- Engaged Sets ---
    sets.engaged = {
		main	= "Daybreak",
		sub		= "Culminus",
		range	= "Dunna",
		head  	= "Azimuth Hood +3",
		neck  	= "Null Loop",
		ear1  	= "Alabaster Earring",
		ear2  	= "Etiolation Earring",
		body  	= "Nyame Mail",
		hands 	= "Geo. Mitaines +4",
		ring1 	= "Murky Ring",
		ring2  	= "Gurebu's Ring",
		back  	= gear.CapePT, 
		waist 	= "Isa Belt",
		legs  	= "Nyame Flanchard",
		feet  	= "Bagua Sandals +4",
		}

    sets.defense = {
		main	= "Daybreak",
		sub		= "Culminus",
		range	= "Dunna",
		head  	= "Azimuth Hood +3",	-- 12
		neck  	= "Null Loop",			-- 5
		ear1  	= "Alabaster Earring",	-- 5
		ear2  	= "Etiolation Earring",
		body  	= "Azimuth Coat +3",
		hands 	= "Geo. Mitaines +4",
		ring1 	= "Murky Ring",			-- 10
		ring2  	= "Gurebu's Ring",
		back  	= gear.CapePT, 			-- 10
		waist 	= "Isa Belt",
		legs  	= "Nyame Flanchard",	-- 8
		feet  	= "Bagua Sandals +4",
		}

    --- Other Sets ---
    sets.idle = sets.defense
end

function customize_melee_set()
	meleeSet = nil
    if state.OffenseMode.value == "Defense" or incapacitated then
		meleeSet = sets.defense
	else
		meleeSet = sets.engaged
    end	
    equip(meleeSet)
end

function job_buff_change(buff,gain)
    if buff == "terror" or buff == "petrification" or buff == "stun" then
        if gain then
            incapacitated = true
		else
            incapacitated = false
        end
    elseif buff == "doom" then
        if gain then
            equip(sets.buff.Doom)
            send_command('@input /p Doomed.')
            disable('ring1','ring2','waist','neck')
        else
            enable('ring1','ring2','waist','neck')
        end
	elseif buff == "charm" then
		if gain then
			send_command('@input /p Charmed.')
		end
	elseif buff == "silence" then
		if gain then
			send_command('@input /p Silenced.')
			silenced = true
			auto_echo_drops()
		else
			silenced = false
		end
	elseif buff == "sleep" then
		if gain then
			incapacitated = true
			enable('main')
			equip({main = 'Lorg Mor'})
			disable('main')
		else
			enable('main')
			incapacitated = false
			customize_melee_set()
		end
	end
end

function job_aftercast(spell, action, spellMap, eventArgs)
	customize_melee_set()
end