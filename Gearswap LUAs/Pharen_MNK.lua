function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
end
function job_setup()	
	send_command('lua l Skillchains')
	windower.send_command('sta !packets on') -- For SendTarget to work	
    state.OffenseMode:options('Normal', 'Defense')
    send_command('bind @S gs c cycle OffenseMode')
	weapon_set = 'h2h'
end
-- % Normal	^ Ctrl	! Alt	@ Win	# Apps	~ Shift
function user_setup() 	
	send_command('send @all alias mis send Pharen /InnerStrength')
	send_command('send @all alias mhp send Pharen /Mantra')
	
	send_command('bind @h gs c toggle_hoxne')
	send_command('bind capslock gs c swap')
	send_command('send @all bind @numpad4 send Pharen gs c swap h2h')
	send_command('send @all bind @numpad5 send Pharen gs c swap staff')
	
	send_command('send @all bind  numpad6 send Pharen /Boost') 
	send_command('send @all bind ~numpad4 send Pharen /Provoke') 
	send_command('send @all bind ~numpad5 send Pharen /Chakra') 
	send_command('send @all bind ~numpad6 send Pharen exec MonkDBuffs.txt') 
	send_command('send @all bind ^numpad4 send Pharen /Counterstance') 
	send_command('send @all bind ^numpad5 send Pharen /Impetus') 
	send_command('send @all bind ^numpad6 send Pharen exec MonkOBuffs.txt') 
	
	send_command('send @all bind %pageup send Pharen /ChiBlast ') 
	send_command('wait 5; input /lockstyle on') 
	setup_weapon_keybinds()
	customize_melee_set()
end

function init_gear_sets()
    --- Weapon Sets ---
	sets.H2H		=	{ main = "Godhands" }
	sets.Staff		=	{ main = "Malignance Pole", sub = "Daduchos Grip" }
	
	gear.TPCape		=	{ name="Segomo's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','"Dbl.Atk."+10','Damage taken-5%',}}
	gear.STRCape	=	{ name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10',}}	
	gear.STPCape	=	{ name="Segomo's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','"Store TP"+10','Damage taken-5%',}}
	gear.CritCape	=	{ name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Crit.hit rate+10','Damage taken-5%',}}
	
   --- Precast Sets ---	
	sets.precast.JA['Boost']	= { waist 	= "Ask Sash" }
	sets.precast.JA['Chakra']	= { Body 	= "Anch. Cyclas +1", "Melee Gloves" }
	sets.precast.JA['Chi Blast']= { Hands 	= "Temple Gloves" }
	sets.precast.JA['Dodge']	= { Feet 	= "Anch. Gaiters +4" }
	sets.precast.JA['Focus']	= { Head 	= "Temple Crown" }
	sets.precast.JA['Footwork']	= { Feet 	= "Bhikku Gaiters +3" }
	sets.precast.JA['Mantra']	= { Feet 	= "Hes. Gaiters" }
	
    sets.precast.WS = {
		ammo	= "Knobkierrie",
		head	= "Adhemar Bonnet +1",
		neck	= "Monk's Nodowa +2",
		ear1  	= "Sherida Earring",
		ear2  	= "Schere Earring",	
		body	= "Mpaca's Doublet",
		hands	= "Bhikku gloves +3",
		ring1 	= "Gere Ring",
		ring2 	= "Niqmaddu Ring",	
		back	= gear.STRCape,
		waist 	= "Moonbow Belt +1",	
		legs  	= "Mpaca's Hose",	
		feet	= "Mpaca's Boots",
		}
		
    sets.precast.WS['Shijin Spiral'] = set_combine(sets.precast.WS, {
		neck	= "Fotia Gorget",
		body	= "Bhikku Cyclas +3",
		back	= gear.TPCape,
		})
    sets.precast.WS['Dragon Kick'] = set_combine(sets.precast.WS, {
		neck	= "Fotia Gorget",
		body	= "Bhikku Cyclas +3",
		head  	= "Mpaca's Cap",
		})
    sets.precast.WS['Tornado Kick'] = sets.precast.WS['Dragon Kick']
	sets.precast.WS['Shell Crusher'] = { -- ACC/MACC
			ammo	= "Knobkierrie",
			head	= "Bhikku Crown +3",
			neck	= "Null Loop",
			ear1  	= "Mache Earring +1",
			ear2  	= "Crep. Earring",	
			body	= "Bhikku Cyclas +3",
			hands	= "Bhikku gloves +3",
			ring1 	= "Crepuscular Ring",		
			ring2 	= "Cornelia's Ring",	
			back	= gear.TPCape,
			waist 	= "Null Belt",	
			legs  	= "Bhikku Hose +3",	
			feet	= "Bhikku Gaiters +3",
		}
		
    --- Engaged Sets ---					-- SB	DT	ACC	MEV	STP	Mult	
    sets.engaged = {						-- 35					14KA
		ammo	= "Coiste Bodhar",			--					03	03DA
		head  	= "Bhikku Crown +3",		-- 14	11	61	098
	--	head  	= "Ryuo Somen +1",			-- 08		35	048 12
		neck  	= "Monk's Nodowa +2",		-- 						25KA
		ear1  	= "Sherida Earring",		-- 05x				05	05DA
		ear2  	= "Mache Earring +1",		--			10			02DA
	--	ear2  	= "Schere Earring",			-- 03					06DA
		body  	= "Mpaca's doublet",		--		10	40	086		04TA
	--	body  	= "Ken. Samue +1",			-- 12		52	117		06TA
		hands 	= "Adhemar wristbands +1",	--			32	043	07	04TA
	--	hands 	= "Malignance Gloves",		--		05	50	112	12
		ring1 	= "Gere Ring",				--						05TA
		ring2 	= "Niqmaddu Ring",			-- 05x					03QA
		back  	= gear.TPCape,				--		05	20			10DA
		waist 	= "Moonbow Belt +1",		-- 15x	06				08TA
		legs  	= "Bhikku Hose +3",			--		14	63	119		30KA
		feet  	= "Mpaca's boots",			--		06	40	096		03TA
	--	feet  	= "Anch. Gaiters +4",		--			56	109		10KA
		}

    sets.defense = {		
		ammo	= "Coiste Bodhar",
		head	= "Nyame Helm",	
		neck  	= "Null Loop",
		ear1  	= "Eabani Earring",		
		ear2  	= "Alabaster Earring",
		body	= "Nyame Mail",	
		hands	= "Nyame Gauntlets",
		ring1 	= "Regal Ring",
		ring2 	= "Warden's Ring",			
		back  	= gear.TPCape,				
		waist 	= "Null Belt",	
		legs	= "Nyame Flanchard",	
		feet	= "Nyame Sollerets",		
        }

    --- Other Sets ---
    sets.idle = sets.defense
    sets.idle.Town = set_combine(sets.idle, {ring1="Warp Ring", ring2="Dim. Ring (Holla)"})	 
end
function job_self_command(cmdParams, eventArgs)
	if cmdParams[1]:lower() == 'toggle_hoxne' then
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
	elseif cmdParams[1]:lower() == 'swap' then
		if not cmdParams[2] then
			if weapon_set == 'staff' then
				weapon_set = 'h2h'
			else
				weapon_set = 'staff'
			end
		elseif cmdParams[2]:lower() == 'staff' then
			weapon_set = 'staff'
		else
			weapon_set = 'h2h'
		end
		setup_weapon_keybinds()
		customize_melee_set()
	end
end
function job_post_precast(spell, action, spellMap, eventArgs)
	if spell.type == 'WeaponSkill' then
		if hoxne_equipped then
			equip({back = gear.CritCape})
		end
	end
end
function customize_melee_set(meleeSet)
    if state.OffenseMode.value == "Defense" or player.status == 'Idle' or incapacitated then
		meleeSet = sets.defense
	else
		meleeSet = sets.engaged
    end	
	if impetus_active then		
		meleeSet = set_combine(meleeSet, { body = "Bhikku Cyclas +3", ear2 = "Schere earring"})
	end
	if footwork_active then		
		meleeSet = set_combine(meleeSet, { feet = "Anch. Gaiters +4" })
	end
	if boost_active then
		meleeSet = set_combine(meleeSet, { waist = "Ask Sash" })
	end
	if hoxne_equipped then
		meleeSet = set_combine(meleeSet, { back = gear.STPCape })
	end
	if weapon_set == 'staff' then
		meleeSet = set_combine(meleeSet, sets.Staff)
	else
		meleeSet = set_combine(meleeSet, sets.H2H)
	end
    equip(meleeSet)
end
function job_post_precast(spell, action, spellMap, eventArgs)
	if impetus_active and spell.name == 'Victory Smite' then
		equip({body = "Bhikku Cyclas +3" })
	elseif footwork_active and (spell.name == 'Dragon Kick' or spell.name == 'Tornado Kick') then
		equip({feet = "Anch. Gaiters +4" })
	end
end
function job_aftercast(spell, action, spellMap, eventArgs)	
	customize_melee_set()
end
function setup_weapon_keybinds()
	if weapon_set == 'staff' then
		send_command('send @all bind numpad4 send Pharen /ShellCrusher')
		send_command('send @all bind numpad5 send Pharen /Cataclysm') 
		weapon_text = 'Switched to:  Staff'
		
	else
		send_command('send @all bind numpad4 send Pharen /Victory Smite')
		send_command('send @all bind numpad5 send Pharen /ShijinSpiral') 
		send_command('send @all bind !numpad4 send Pharen /DragonKick') 
		send_command('send @all bind !numpad5 send Pharen /RagingFists') 
		send_command('send @all bind !numpad6 send Pharen /HowlingFist') 
		weapon_text = 'Switched to:  Hand-to-Hand'
	end
	windower.add_to_chat(209, weapon_text)
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
			send_command('cm')
		end
    elseif buff == 'Footwork' then
        if gain then
            footwork_active = true 
        else
            footwork_active = false 
        end
    elseif buff == 'Impetus' then
        if gain then
            impetus_active = true 
        else
            impetus_active = false 
        end
    elseif buff == 'Boost' then
        if gain then
			boost_active = true
		else
			boost_active = false
		end
    end
	customize_melee_set()
end

windower.register_event('hpp change', function(new_hpp, old_hpp)
    if new_hpp < 10 then
		send_command('input /ja "Chakra" <me>')
    end
end)