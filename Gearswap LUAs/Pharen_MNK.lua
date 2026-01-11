function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
end
function job_setup()	
	windower.send_command('sta !packets on') -- For SendTarget to work	
    state.OffenseMode:options('Normal', 'Defense')
    send_command('bind @S gs c cycle OffenseMode')
end
-- % Normal	^ Ctrl	! Alt	@ Win	# Apps	~ Shift
function user_setup() 
	send_command('send @all alias mis send Pharen /InnerStrength')
	send_command('send @all alias mhp send Pharen /Mantra')
	
	send_command('send @all bind  numpad4 send Pharen /Victory Smite')
	send_command('send @all bind  numpad5 send Pharen /ShijinSpiral') 
	send_command('send @all bind  numpad6 send Pharen /boost') 
	send_command('send @all bind !numpad4 send Pharen /DragonKick') 
	send_command('send @all bind !numpad5 send Pharen /TornadoKick') 
	send_command('send @all bind !numpad6 send Pharen /AsceticsFury') 
	send_command('send @all bind ~numpad4 send Pharen /Provoke') 
	send_command('send @all bind ~numpad5 send Pharen /Chakra') 
	send_command('send @all bind ~numpad6 send Pharen exec MonkDBuffs.txt') 
	send_command('send @all bind ^numpad4 send Pharen /Counterstance') 
	send_command('send @all bind ^numpad5 send Pharen /Impetus') 
	send_command('send @all bind ^numpad6 send Pharen exec MonkOBuffs.txt') 
	
	send_command('send @all bind %pageup send Pharen /ChiBlast ') 
	
	send_command('wait 5; input /lockstyle on') 
end

function init_gear_sets()
    --- Weapon Sets ---
	gear.TPCape		=	{ name="Segomo's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','"Dbl.Atk."+10','Damage taken-5%',}}
	gear.STRCape	=	{ name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10',}}	
	
   --- Precast Sets ---	
    sets.precast.FC = {}
	sets.precast.JA['Chakra'] = { Body = "Anch. Cyclas +1", "Melee Gloves" }
	sets.precast.JA['Chi Blast'] = { Head = "Hes. Crown" }
	sets.precast.JA['Dodge'] = { Feet = "Anch. Gaiters +3" }
	sets.precast.JA['Focus'] = { Head = "Anch. Crown +4" }
	sets.precast.JA['Footwork'] = { Feet = "Bhikku Gaiters +3" }
	sets.precast.JA['Mantra'] = { Feet = "Hes. Gaiters" }
	
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

    --- Engaged Sets ---					-- SB	DT	ACC	MEV	STP	Mult	
    sets.engaged = {						-- 35					14KA
		main	= "Godhands",
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
	--	feet  	= "Anch. Gaiters +3",		--			56	109		10KA
		}

    sets.defense = {
		ammo	= "Coiste Bodhar",
		head  	= "Bhikku Crown +3",		
		neck  	= "Monk's Nodowa +2",
		ear1  	= "Sherida Earring",		
		ear2  	= "Mache Earring +1",
		body  	= "Mpaca's doublet",		
		hands 	= "Adhemar wristbands +1",
		ring1 	= "Gere Ring",
		ring2 	= "Niqmaddu Ring",			
		back  	= gear.TPCape,				
		waist 	= "Moonbow Belt +1",		
		legs  	= "Bhikku Hose +3",			
		feet  	= "Mpaca's boots",			
        }

    --- Other Sets ---
    sets.idle = sets.defense
    sets.idle.Town = set_combine(sets.idle, {ring1="Warp Ring", ring2="Dim. Ring (Holla)"})	 
end

impetus_active = false
function customize_melee_set(meleeSet)
    if state.OffenseMode.value == "Normal" and player.status == 'Engaged' then
		meleeSet = sets.engaged
	else
		meleeSet = sets.defense
    end	
	if impetus_active then		
		meleeSet = set_combine(meleeSet, {body="Bhikku Cyclas +3",ear2="Schere earring"})
	end
	if footwork_active then		
		meleeSet = set_combine(meleeSet, {feet = "Anch. Gaiters +3" })
	end
    equip(meleeSet)
end
function job_post_precast(spell, action, spellMap, eventArgs)
	if impetus_active and spell.name == 'Victory Smite' then
		equip({body = "Bhikku Cyclas +3" })
	elseif footwork_active and (spell.name == 'Dragon Kick' or spell.name == 'Tornado Kick') then
		equip({feet = "Anch. Gaiters +3" })
	end
end
function job_aftercast(spell, action, spellMap, eventArgs)	
	customize_melee_set()
end
function job_state_change(field, new_value, old_value)
    customize_melee_set()
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
            enable('ring1','ring2','waist','neck')
        end
	elseif buff == "charm" then
		if gain then
			send_command('@input /p Charmed.')
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
	else
		return
    end
	customize_melee_set()
end