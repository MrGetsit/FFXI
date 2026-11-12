function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
end
function job_setup()	
	send_command('lua l Skillchains')
    state.OffenseMode:options('Hybrid', 'Defense', 'Offense')
    send_command('bind @S gs c cycle OffenseMode')
	weapon_set = 'h2h'
	
	setup_weapon_keybinds()
	send_command('wait 5; input /lockstyleset 1')
end
-- % Normal	^ Ctrl	! Alt	@ Win	# Apps	~ Shift
function user_setup() 		
	send_command('bind @h gs c toggle_hoxne')
	send_command('bind capslock gs c swap')
	send_command('send @all bind @numpad4 send Pharen gs c swap h2h')
	send_command('send @all bind @numpad5 send Pharen gs c swap staff')
	
	send_command('send @all alias mis qa Pharen JA "Inner Strength"')
	send_command('send @all alias mhf qa Pharen JA "Hundred Fists"')
	send_command('send @all alias mhp qa Pharen JA "Mantra"')
	send_command('send @all alias mfs qa Pharen JA "Formless Strikes"')
	
	send_command('send @all bind  numpad6   qa Pharen JA Boost') 
	send_command('send @all bind ~numpad4   qa Pharen JA Provoke mt') 
	send_command('send @all bind ~numpad5   qa Pharen JA Chakra') 
	send_command('send @all bind ~numpad6 send Pharen exec MonkDBuffs.txt') 
	send_command('send @all bind ^numpad5   qa Pharen JA Impetus') 
	send_command('send @all bind ^numpad6 send Pharen exec MonkOBuffs.txt')
	send_command('send @all bind %pageup    qa Pharen JA "Chi Blast" t') 
end

function setup_weapon_keybinds()
	local main = weapon_set
	
	if weapon_set == 'staff' then
		send_command('send @all bind numpad4 qa Pharen WS "Shell Crusher" t')
		send_command('send @all bind numpad5 qa Pharen WS "Shattersoul" t') 
		weapon_text = 'Switched to:  Staff'
		
	else
		send_command('send @all bind  numpad4 qa Pharen WS "Victory Smite" t')
		send_command('send @all bind  numpad5 qa Pharen WS "Shijin Spiral" t') 
		send_command('send @all bind !numpad4 qa Pharen WS "Dragon Kick" t') 
		send_command('send @all bind !numpad5 qa Pharen WS "Raging Fists" t') 
		send_command('send @all bind !numpad6 qa Pharen WS "Howling Fist" t') 
		weapon_text = 'Switched to:  Hand-to-Hand'
	end
	customize_melee_set()
	windower.add_to_chat(209, weapon_text)
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
	sets.precast.JA['Boost']	= { waist= "Ask Sash" }
	sets.precast.JA['Chakra']	= { body = "Anch. Cyclas +1",	hand = "Melee Gloves" }
	sets.precast.JA['Chi Blast']= { head = "Hesychast's Crown",	hands= "Temple Gloves" }
	sets.precast.JA['Dodge']	= { feet = "Anch. Gaiters +4" }
	sets.precast.JA['Focus']	= { head = "Temple Crown" }
	sets.precast.JA['Footwork']	= { feet = "Bhikku Gaiters +3" }
	sets.precast.JA['Mantra']	= { feet = "Hes. Gaiters" }
	
    sets.precast.WS = {
		ammo	= "Knobkierrie",
		head	= "Adhemar Bonnet +1",
		neck	= "Fotia Gorget",
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
		head  	= "Mpaca's Cap",
        neck	= "Rep. Plat. Medal",
		body	= "Bhikku Cyclas +3",
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
	
	--- Engaged Sets	
    --[[							-- SB	DT	MDB	ACC	MEV	STP	Mult	
		ammo	= "Coiste Bodhar",			--						03	03DA
		head	= "Duty Crown",			-- 05	05	05	42~	115		05DA	Aug: 4TA 7STP
		head	= "Mpaca's Cap",			-- 		07	12	40	069		03TA	4 Crit R	Augs: 5DA 15SC Dam
		head	= "Malignance Chapeau",		--		06	05	50	123	08			3 PDL
		head	= "Bhikku Crown +3",		-- 14	11	08	61	098
		head	= "Adhemar Bonnet +1",		-- 08		03		059		04TA	6 Crit D
		head	= "Ryuo Somen +1",			-- 08			35	048 12
		neck	= "Monk's Nodowa +2",		-- 				30			25KA	10 PDL
		ear1	= "Sherida Earring",		-- 05II					05	05DA
		ear2	= "Mache Earring +1",		--				10			02DA
		ear2	= "Schere Earring",		-- 03						06DA
		body	= "Bhikku Cyclas +3",		--		10		64	109		01KA	8 Martial Arts +Impetus
		body	= "Duty Cyclas",			-- 07	07	09	42~	126		07DA	Aug: 5TA 8STP
		body	= "Mpaca's doublet",		--		10	14	40	086		04TA	Augs: 4-8 STP
		body	= "Malignance Tabard",		--		09	08	50	139	11			6 PDL
		body	= "Ken. Samue +1",			-- 12	09	09	52	117		06TA	9 Crit R
		hands	= "Duty Gauntlets",		-- 03	03	05	42~	100		03DA	Aug: 3TA 6STP
		hands	= "Mpaca's Gloves",		--		08	11	40	059		03TA	Augs: TA damage
		hands	= "Malignance Gloves",		--		05	04	50	112	12			4 PDL
		hands	= "Adhemar wristbands +1",	--			02	32	043	07	04TA
		ring1	= "Gere Ring",			--							05TA
		ring2	= "Niqmaddu Ring",			-- 05II						03QA
		back	= gear.TPCape,			--		05		20			10DA
		waist	= "Moonbow Belt +1",		-- 15II	06					08TA
		legs	= "Bhikku Hose +3",		--		14	08	63	119		30KA
		feet	= "Duty Sollerets",		-- 06	06	08	42~	131		06DA	Aug: 3TA 6STP
		feet	= "Mpaca's boots",			--		06	12	40	096		03TA
		feet	= "Malignance Boots",		--		04	05	50	150	09			2 PDL
		feet	= "Anch. Gaiters +4",		--			05	56	109		10KA
    ]]
	--- Offense							-- SB	DT	MDB	ACC	MEV	STP	Mult
	--										-- 66	48	34	277	448	15	26DA/24TA/03QA/69KA
    sets.engaged = {						-- 35						14KA
		ammo	= "Coiste Bodhar",			--						03	03DA
		head	= "Mpaca's Cap",			-- 		07	12	40	069		03TA	4 Crit R	Augs: 5DA 15SC Dam
		neck	= "Monk's Nodowa +2",		-- 				30			25KA	10 PDL
		ear1	= "Sherida Earring",		-- 05II					05	05DA
		ear2	= "Mache Earring +1",		--				10			02DA
		body	= "Mpaca's doublet",		--		10	14	40	086		04TA	Augs: 4-8 STP
		hands	= "Adhemar wristbands +1",	--			02	32	043	07	04TA
		ring1	= "Gere Ring",				--							05TA
		ring2	= "Niqmaddu Ring",			-- 05II						03QA
		back	= gear.TPCape,				--		05		20			10DA
		waist	= "Moonbow Belt +1",		-- 15II	06					08TA
		legs	= "Bhikku Hose +3",			--		14	08	63	119		30KA
		feet	= "Duty Sollerets",			-- 06	06	08	42~	131		06DA	Aug: 3TA 6STP
		}
    --- Hybrid								-- SB	DT	MDB	ACC	MEV	STP	Mult	
	--										-- 78	51	41	259	580	08	38DA/16TA/03QA/69KA
    sets.hybrid = {							-- 35						14KA
		ammo	= "Coiste Bodhar",			--						03	03DA
		head	= "Duty Crown",				-- 05	05	05	42~	115		05DA	Aug: 4TA 7STP
		neck	= "Monk's Nodowa +2",		-- 				30			25KA	10 PDL
		ear1	= "Sherida Earring",		-- 05II					05	05DA
		ear2	= "Mache Earring +1",		--				10			02DA
		body	= "Duty Cyclas",			-- 07	07	09	42~	126		07DA	Aug: 5TA 8STP
		hands	= "Mpaca's Gloves",			--		08	11	40	059		03TA	Augs: TA damage
		ring1	= "Gere Ring",				--							05TA
		ring2	= "Niqmaddu Ring",			-- 05II						03QA
		back	= gear.TPCape,				--		05		20			10DA
		waist	= "Moonbow Belt +1",		-- 15II	06					08TA
		legs	= "Bhikku Hose +3",			--		14	08	63	119		30KA
		feet	= "Duty Sollerets",			-- 06	06	08	42~	131		06DA	Aug: 3TA 6STP
		}
    --- Defense							-- SB	DT	MDB	ACC	MEV	STP	Mult			
    sets.defense = {		
		ammo	= "Coiste Bodhar",
		head	= "Nyame Helm",	
		neck	= "Null Loop",
		ear1	= "Eabani Earring",		
		ear2	= "Alabaster Earring",
		body	= "Nyame Mail",	
		hands	= "Nyame Gauntlets",
		ring1	= "Regal Ring",
		ring2	= "Warden's Ring",			
		back	= gear.TPCape,				
		waist	= "Null Belt",	
		legs	= "Nyame Flanchard",	
		feet	= "Nyame Sollerets",		
        }
end

function customize_melee_set()
	if incapacitated then equip(sets.defense) return end
	local meleeSet = nil
    if state.OffenseMode.value == "Defense" or player.status == 'Idle' then
		meleeSet = sets.defense
    elseif state.OffenseMode.value == "Hybrid" then
		meleeSet = sets.hybrid
	else
		meleeSet = sets.engaged
    end	
	if weapon_set == 'staff' then
		meleeSet = set_combine(meleeSet, sets.Staff)
	else
		meleeSet = set_combine(meleeSet, sets.H2H)
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
    equip(meleeSet)
end

function job_post_precast(spell, action, spellMap, eventArgs)
	if spell.type == 'WeaponSkill' then
		if hoxne_equipped then
			equip({back = gear.CritCape})
		end
		if impetus_active and spell.name == 'Victory Smite' then
			equip({body = "Bhikku Cyclas +3" })
		elseif footwork_active and (spell.name == 'Dragon Kick' or spell.name == 'Tornado Kick') then
			equip({feet = "Anch. Gaiters +4" })
		end
	end
end

function job_aftercast(spell, action, spellMap, eventArgs)
	if spell.name == "Boost" then return end
	customize_melee_set()
end

function job_buff_change(buff,gain)
    if buff == "terror" or buff == "petrification" or buff == "stun" then
        if gain then
            incapacitated = true
		else
            incapacitated = false
        end
	elseif buff == "sleep" then
		if gain then
			incapacitated = true
			enable('main')
			equip({main = 'Varga Purnikawa'})
			disable('main')
			return
		else
			incapacitated = false
			enable('main')
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
	end
end
