function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
end

function job_setup()	
	windower.send_command('sta !packets on') -- For SendTarget to work
	
	barstatus = S{'Baramnesra', 'Barvira', 'Barparalyzra', 'Barsilencera', 'Barpetra', 'Barpoisonra', 'Barblindra', 'Barsleepra'} 
	
    state.WeaponLock = M(false, 'Weapon Lock')	
	state.WeaponSet = M{['description']='Weapon Set', 'Heal', 'DPS'}
    state.OffenseMode:options('Defense', 'Normal')
    send_command('bind @w gs c toggle WeaponLock')	
    send_command('bind %capslock gs c cycle WeaponSet')	
    send_command('bind @S gs c cycle OffenseMode')		
end

function user_setup()
	send_command('send @all alias pr5 send Meegs /Protectra5') 
	send_command('send @all alias sh5 send Meegs /Shellra5') 
	send_command('send @all alias ari sta Meegs /Arise <t>')
	send_command('send @all alias reg exec whmregen.txt')
	send_command('send @all alias wstr send Meegs /BoostSTR')
	send_command('send @all alias wdex send Meegs /BoostDEX')
	send_command('send @all alias wagi send Meegs /BoostAGI')
	send_command('send @all alias wint send Meegs /BoostINT')
	send_command('send @all alias wmnd send Meegs /BoostMND')
	send_command('send @all alias wchr send Meegs /BoostCHR')
	send_command('send @all alias whb exec hbwhm.txt') 
	send_command('send @all alias whb2 exec hbwhm2.txt') 
	send_command('send @all alias ben send Meegs gs c spam Benediction') 
	send_command('send @all alias sac send Meegs gs c spam Sacrosanctity') 
	send_command('send @all alias asy send Meegs gs c spam Asylum') 
	
	send_command('wait 5; input /lockstyleset 1')
end

function init_gear_sets()
    --- Weapon Sets ---
    sets.Heal 	= 	{ main="Queller Rod", sub="Ammurapi Shield"}
    sets.DPS 	= 	{ main="Kaja Rod", sub="Ammurapi Shield"}
	
	gear.HeadCP = { name="Vanya Hood", augments={'MP+50','"Cure" potency +7%','Enmity-6'} }
	gear.HeadFC = { name="Vanya Hood", augments={'MP+50','"Fast Cast"+10','Haste+2%'} }
	gear.CapeFC = { name="Alaunus's Cape", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','"Fast Cast"+10','Damage taken-5%',}}
	gear.CapeTP = { name="Alaunus's Cape", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','"Store TP"+10','Damage taken-5%',}}
	gear.CapeWS = { name="Alaunus's Cape", augments={'MND+20','Accuracy+20 Attack+20','MND+10','Weapon skill damage +10%','Damage taken-5%',}}

    --- Precast Sets ---	
	sets.precast.JA['Afflatus Solace']	= { body 	= "Ebers Bliaut +3" }
	sets.precast.JA['Divine Benison']	= { body 	= "Ebers Pant. +3" }
	sets.precast.JA['Divine Caress']	= { body 	= "Ebers Mitts +3" }
	sets.precast.JA['Divine Veil']		= { head 	= "Ebers Cap +3" }
	sets.precast.JA['Sublimation']		= { waist	= "Embla Sash" }
	
    sets.precast.FC = {		
		sub		= "Chanter's Shield",		-- 3%
		head	= "Ebers Cap +3",			-- 10%
		neck	= "Cleric's Torque +2",		-- 1%
		ear1	= "Mendicant's Earring",	-- 5%
		ear2	= "Loquac. Earring",		-- 2%
		body	= "Inyanga Jubbah +2",		-- 14%
		back  	= gear.CapeFC,				-- 10%
		waist 	= "Embla Sash",				-- 5%
		legs	= "Ayanmo cosciales +2",	-- 6%
		}

	sets.precast.FC['Healing Magic'] = set_combine(sets.precast.FC, { legs = "Ebers Pant. +3" })	

    --- Midcast Sets ---
	sets.midcast = {
		sub		= "Ammurapi Shield",
		ammo	= "Pemphredo Tathlum",	
		}
		
	sets.midcast.Cure = set_combine(sets.midcast, {								-- 23% from JP
		main	= "Raetic Rod +1",						-- 23%	10% II	+50 HP Cure
		head	= gear.HeadCP,							-- 17%
		neck	= "Cleric's Torque +2",					-- 10%
		ear1	= "Mendicant's Earring",				-- 5%
		body	= "Vanya Robe",							-- 7%
		hands	= "Vanya Cuffs",						-- 7%
		ring2	= "Janniston Ring",						-- 		5% II
		legs	= "Ebers Pant. +3",						--		MP Restore on Cure
		feet	= "Vanya Clogs",						-- 13%
		})
	sets.midcast['Healing Magic'] = set_combine(sets.midcast, { head = "Ebers Cap +3" })
	sets.midcast['Erase'] = set_combine(sets.midcast, { neck = "Cleric's Torque +2" })	
	sets.midcast.Regen = set_combine(sets.midcast, {
		head	= "Inyanga Tiara +2",
		body	= "Telchine Chas.",		-- 10%
		hands 	= "Ebers Mitts +3",
		legs	= "Telchine Braconi",	-- 10%
		feet	= "Telchine Pigaches",	-- 09%
		})
	
	sets.midcast['Enhancing Magic'] = set_combine(sets.midcast, {
		main	= "Gada",				-- 06%
		sub		= "Ammurapi Shield",	-- 10%
		head	= "Telchine Cap",		-- 09%
		body	= "Telchine Chas.",		-- 10%
		hands	= "Telchine Gloves",	-- 09%
		waist 	= "Embla Sash",			-- 10%
		legs	= "Telchine Braconi",	-- 10%
		feet	= "Telchine Pigaches",	-- 09%
	})
	sets.midcast['Auspice'] = set_combine(sets.midcast['Enhancing Magic'], { feet = "Ebers Duckbills +3" })
	sets.midcast.BarStatus = set_combine(sets.midcast['Enhancing Magic'], { neck = "Sroda Necklace"}) 	
	sets.midcast.BarElement = set_combine(sets.midcast, {
		head	= "Ebers Cap +3",
		body	= "Ebers Bliaut +3",
		hands	= "Ebers Mitts +3",
		legs	= "Piety Pantaloons +3",
		feet	= "Ebers Duckbills +3"
	})

    --- Engaged Sets ---
    sets.engaged = sets.defense

    sets.defense = {					-- DT
		main	= "Queller Rod",		-- Ref
		ammo  	= "Homiliary",
		head	= "Ebers Cap +3",
		neck  	= "Null Loop",
		ear1  	= "Alabaster earring",	-- 5
		ear2  	= "Flashward Earring",
		body  	= "Ebers Bliaut +3",
		hands 	= "Ebers Mitts +3",		-- 10
		ring1 	= "Murky Ring",			-- 10
		ring2 	= "Inyanga Ring",	
		back  	= gear.CapeFC,
		waist 	= "Carrier's Sash",
		legs	= "Ebers Pant. +3",		-- 13
		feet  	= "Ebers Duckbills +3",	-- 10
		}

    --- Other Sets ---
    sets.idle = sets.defense
    sets.idle.Town = set_combine(sets.idle, {ring1="Warp Ring", ring2="Dim. Ring (Holla)"})	 
end
function customize_melee_set(meleeSet)
    equip(sets[state.WeaponSet.current])
    if state.OffenseMode.value == "Defense" or incapacitated then
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

function job_post_midcast(spell, action, spellMap, eventArgs)
	if spell.action_type == 'Magic' then
		if spell.skill == 'Enhancing Magic' then
			if barstatus:contains(spell.english) then
				equip(sets.midcast.BarStatus)
			end
		end
	end
end
function job_aftercast(spell)
	if spell.name == 'Benediction' or spell.name == 'Sacrosanctity' or spell.name == 'Asylum' then
		local recast = windower.ffxi.get_ability_recasts()[spell.recast_id]
		print(recast)
		if recast and recast >= 1 then 
			attempts = 100
		end		
	end
end
function job_self_command(cmdParams, eventArgs)
	if cmdParams[1]:lower() == 'spam' then
		attempts = 0
		use_ability(cmdParams[2])
	end
end

function use_ability(ability_to_use)
	if ability_to_use and attempts < 10 then
		print(attempts..' Using: '..ability_to_use)
		send_command(ability_to_use)
		attempts = attempts + 1
		coroutine.schedule(function() use_ability(ability_to_use) end, 0.5)
	else
		using_ability = false
	end
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
			equip({main = 'Prime Maul'})
		end
    end
end

function auto_echo_drops ()
	if not silenced then return end
	send_command('input /item "Echo Drops" <me>')
	coroutine.schedule(function() auto_echo_drops() end, 2)
end