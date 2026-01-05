function get_sets()
	mote_include_version = 2
	include('Mote-Include.lua')
end

function job_setup()	
	windower.send_command('sta !packets on') -- For SendTarget to work
	
	state.WeaponLock = M(false, 'Weapon Lock')
	state.WeaponSet = M{'Sword', 'Club', 'Dagger'}
	state.OffenseMode:options('Normal', 'Defense')
	send_command('bind @S gs c cycle OffenseMode')
    send_command('bind %capslock gs c change_weapon')
    send_command('bind @w gs c lock')
    send_command('gs c change_weapon')
	WeaponLock = false
end
-- % Normal	^ Ctrl	! Alt	@ Win	# Apps	~ Shift
function user_setup() 
	send_command('send @all alias brd1 exec BRD1.txt')
	send_command('send @all alias brd2 exec BRD2.txt')
	send_command('send @all alias brdsv exec BRDSV.txt')
	
	send_command('send @all alias sst send Cissilea /Pianissimo')
	
	send_command('send @all alias sreg  send Cissilea /ArmysPaeon6') 
	send_command('send @all alias sreg2 send Cissilea /ArmysPaeon5') 
	send_command('send @all alias sreg3 send Cissilea /ArmysPaeon4') 
	send_command('send @all alias sref  send Cissilea /MagesBallad3') 
	send_command('send @all alias sref2 send Cissilea /MagesBallad2') 
	send_command('send @all alias sref3 send Cissilea /MagesBallad') 
	
	send_command('send @all alias satt  send Cissilea /ValorMinuet5') 
	send_command('send @all alias satt2 send Cissilea /ValorMinuet4') 
	send_command('send @all alias satt3 send Cissilea /ValorMinuet3') 
	send_command('send @all alias sdef  send Cissilea /KnightsMinne5') 
	send_command('send @all alias sdef2 send Cissilea /KnightsMinne4') 
	send_command('send @all alias sdef3 send Cissilea /KnightsMinne3') 
	send_command('send @all alias sacc  send Cissilea /BladeMadrigal') 
	send_command('send @all alias sacc2 send Cissilea /SwordMadrigal') 
	send_command('send @all alias seva  send Cissilea /SheepfoeMambo') 
	send_command('send @all alias seva2 send Cissilea /DragonfoeMambo') 
	send_command('send @all alias shas  send Cissilea /AdvancingMarch') 
	send_command('send @all alias shas2 send Cissilea /VictoryMarch') 
	
	send_command('send @all alias sstr  send Cissilea /HerculeanEtude') 
	send_command('send @all alias sdex  send Cissilea /UncannyEtude') 
	send_command('send @all alias svit  send Cissilea /VitalEtude') 
	send_command('send @all alias sagi  send Cissilea /SwiftEtude') 
	send_command('send @all alias sint  send Cissilea /SageEtude') 
	send_command('send @all alias smnd  send Cissilea /LogicalEtude')
	
	send_command('send @all alias sfc  send Cissilea /FireCarol2')
	send_command('send @all alias sfc2 send Cissilea /FireCarol')
	send_command('send @all alias sic  send Cissilea /IceCarol2')
	send_command('send @all alias sic2 send Cissilea /IceCarol')
	send_command('send @all alias sac  send Cissilea /WindCarol2')
	send_command('send @all alias sac2 send Cissilea /WindCarol')
	send_command('send @all alias sec  send Cissilea /EarthCarol2')
	send_command('send @all alias sec2 send Cissilea /EarthCarol')
	send_command('send @all alias swc  send Cissilea /WaterCarol2')
	send_command('send @all alias swc2 send Cissilea /WaterCarol')
	send_command('send @all alias stc  send Cissilea /LightningCarol2')
	send_command('send @all alias stc2 send Cissilea /LightningCarol')
	send_command('send @all alias sdc  send Cissilea /DarkCarol2')
	send_command('send @all alias sdc2 send Cissilea /DarkCarol')
	send_command('send @all alias slc  send Cissilea /LightCarol2')
	send_command('send @all alias slc2 send Cissilea /LightCarol')
	
	send_command('send @all alias sfd send Cissilea /FireThrenody2')
	send_command('send @all alias sid send Cissilea /IceThrenody2')
	send_command('send @all alias sad send Cissilea /WindThrenody2')
	send_command('send @all alias sed send Cissilea /EarthThrenody2')
	send_command('send @all alias swd send Cissilea /WaterThrenody2')
	send_command('send @all alias std send Cissilea /LightningThrenody2')
	send_command('send @all alias sld send Cissilea /LightThrenody2')
	send_command('send @all alias sdd send Cissilea /DarkThrenody2')
	
	send_command('send @all bind  numpad7  sta Cissilea /SavageBlade')
	send_command('send @all bind  numpad8  sta Cissilea /HordeLullaby')
	send_command('send @all bind ~numpad8  sta Cissilea /HordeLullaby2')
	send_command('send @all bind  numpad9  sta Cissilea /MagicFinale')
	send_command('send @all bind ~numpad7 send Cissilea /SentinelsScherzo')
	send_command('send @all bind !numpad8 exec Brd_Refresh.txt')
	send_command('send @all bind ~numpad9 send Cissilea /DarkCarol2')
	send_command('send @all bind !numpad9 exec Brd1.txt')
	
	send_command('wait 5; input /lockstyleset 2') 
end


function init_gear_sets()
	--- Weapon Sets ---
	sets.Sword	=	{ main = "Kaja Sword", sub="Culminus" }
	sets.Dagger	=	{ main = "Kali", sub="Culminus"}
	sets.Club	=	{ main = "Daybreak", sub="Culminus"}

	gear.CapeFC	={ name="Intarabus's Cape", augments={'CHR+20','Mag. Acc+20 /Mag. Dmg.+20','"Fast Cast"+10',}}
	gear.CapeSR =	{ name="Intarabus's Cape", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity-10','Occ. inc. resist. to stat. ailments+10',}}
	
   --- Precast Sets ---	
	sets.precast.FC = {							-- 79
		main	= "Kali",						-- 07
		head	= "Fili Calot +3",				-- 16
		neck	= "Orunmila's Torque",			-- 05
		ear1	= "Alabaster earring",
		ear2	= "Malignance earring",			-- 04
		body	= "Inyanga Jubbah +2",			-- 14
		hands	= "Fili Manchettes +3",
		ring1	= "Etana ring",
		ring2	= "Kishar ring",				-- 04
		back	= gear.CapeFC,					-- 10
		waist	= "Plat. Mog. Belt",
		legs	= "Ayanmo Cosciales +2",
		feet	= "Fili Cothurnes +3",			-- 13
	}

	sets.precast.FC['Healing Magic'] = {
		main	= "Kali",						-- 07			-- 10
		head	= "Vanya Hood",
		neck	= "Orunmila's Torque",			-- 05
		ear1	= "Alabaster earring",
		ear2	= "Malignance earring",			-- 04
		body	= "Inyanga Jubbah +2",			-- 14
		hands	= "Fili Manchettes +3",
		ring1	= {name="Etana ring",			priority= 1},
		ring2	= "Kishar ring",				-- 04
		back	= gear.CapeFC,		
		waist	= "Plat. Mog. Belt",
		legs	= "Vanya Slops",
		feet	= "Fili Cothurnes +3",			-- 13
		}

	sets.precast.WS = {	}

	--- Midcast Sets ---
	sets.midcast = {
		range	= "Miracle Cheer",
		head	= "Fili Calot +3",
		neck	= "Mnbw. Whistle +1",
		body	= "Fili Hongreline +3",
		hands	= "Fili Manchettes +3",
		ring1	= "Etana Ring",
		waist	= "Plat. Mog. Belt",
		legs	= "Fili Rhingrave +3",
		feet	= "Fili Cothurnes +3",
		}

	sets.midcast['Lullaby'] = set_combine(sets.midcast, {
		range	= "Blurred Harp",
		head	= "Brioso Roundlet +3",
		ear1	= "Gersemi Earring",
		body	= "Brioso Justaucorps +4",
		hands	= "Brioso cuffs +3",
		back	= gear.CapeFC,
		legs	= "Inyanga Shalwar +2",
		feet	= "Brioso Slippers +3",
		})		
	sets.midcast['Enfeebling Magic'] = sets.midcast['Lullaby']

	sets.midcast['Healing Magic'] = {
		main	= "Daybreak",
		head	= "Vanya Hood",
		neck	= {name="Null Loop",				priority= 1},
		ear1	= "Alabaster Earring",
		ear2	= "Etiolation Earring",
		body	= {name="Brioso Just. +4",			priority= 2},
		hands	= "Fili Manchettes +3",
		ring1	= "Etana Ring",
		ring2	= "Lebeche Ring",
		back	= gear.CapeFC,
		waist	= "Plat. Mog. Belt",	
		legs	= "Vanya Slops",
		feet	= "Vanya Clogs",
		}

	--- Engaged Sets ---
	sets.engaged = sets.defense

	sets.defense = {
		head	= "Fili Calot +3",		-- 11
		neck	= "Warder's Charm +1",
		ear1	= "Alabaster Earring",	-- 05
		ear2	= "Etiolation Earring",
		body	= "Fili Hongreline +3",
		hands	= "Fili Manchettes +3",	-- 11
		ring1	= "Murky ring",			-- 10
		ring2	= "Gurebu's Ring",
		back	= gear.CapeSR,
		waist	= "Plat. Mog. Belt",	-- 03	
		legs	= "Brioso Cannions +3",	-- 08
		feet	= "Fili Cothurnes +3",
		}

	--- Other Sets ---
	sets.idle = sets.defense
	sets.idle.Town = set_combine(sets.idle, {ring1="Warp Ring", ring2="Dim. Ring (Holla)"})	 
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
    end
end

function check_weapon()
	if WeaponLock then return end
	equip(sets[state.WeaponSet])
end

function customize_melee_set()
	if state.OffenseMode.value == "Defense" or
	player.status == 'Idle' then
		equip(sets.defense)
	else
		equip(sets.engaged)
	end
	check_weapon()
end

function job_aftercast(spell, action, spellMap, eventArgs)
	customize_melee_set()
end

function job_post_pretarget(spell, action, spellMap, eventArgs)
	if spell.action_type == 'Magic' then -- Don't change gear on CD
		if windower.ffxi.get_spell_recasts()[spell.recast_id] >= 1 then
			cancel_spell()
			eventArgs.handled = true
			return
		end
	elseif spell.type == 'WeaponSkill' then
		if player.tp <= 1000 then
			cancel_spell()
			eventArgs.handled = true
			return
		end
	end
end

function job_state_change(field, new_value, old_value)
	customize_melee_set()
end

function job_update(cmdParams, eventArgs)
	customize_melee_set()
end

function job_self_command(cmdParams, eventArgs)
	if cmdParams[1]:lower() == 'change_weapon' then
		WeaponLock = false
		enable('main','sub','range')
		if state.WeaponSet == 'Sword' then
			msg = string.char(0x87, 0x41) .. ' Dagger'
			state.WeaponSet = 'Dagger'
			send_command('send @all bind numpad7 send Cissilea /Evisceration') 
		elseif state.WeaponSet == 'Dagger' then
			msg = string.char(0x87, 0x42) .. ' Club'
			state.WeaponSet = 'Club'
			send_command('send @all bind numpad7 send Cissilea /Moonlight') 
		else
			msg = string.char(0x87, 0x40) .. ' Sword'
			state.WeaponSet = 'Sword'
			send_command('send @all bind numpad7 send Cissilea /SavageBlade') 
		end
		windower.add_to_chat(206, 'Weapon Set '..msg)

	elseif cmdParams[1]:lower() == 'lock' then
		WeaponLock = not WeaponLock
		if WeaponLock then
			disable('main','sub','range')
			windower.add_to_chat(206, 'Weapon Lock: On')
		else
			enable('main','sub','range')
			windower.add_to_chat(206, 'Weapon Lock: Off')
			send_command('gs equip sets.'..state.WeaponSet)
		end
	end
	check_weapon()
end