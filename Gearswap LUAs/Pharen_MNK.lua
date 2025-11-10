function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
end

--------------------------------------------------------		
--				1				2				3			--
-- 			Victory Smite	Asuran Fist		Shijin Spiral	--
--	ALT		Provoke			Chakra			DEFBuffs		--
-- 	SHFT	AttackBuffs		Boost			Shell Crusher	--
-- 	CTRL													--
-- 	WIN		ChiBlast						FormlessStr		--
--															--
--------------------------------------------------------	

function job_setup()	
	windower.send_command('sta !packets on') -- For SendTarget to work
	
    state.WeaponLock = M(false, 'Weapon Lock')	
	state.WeaponSet = M{['description']='Weapon Set', 'Condemners', 'Sophistry'}
    state.OffenseMode:options('Normal', 'Defense')
    send_command('bind @w gs c toggle WeaponLock')	
    send_command('bind %capslock gs c cycle WeaponSet')	
    send_command('bind @S gs c cycle OffenseMode')
end
-- % Normal	^ Ctrl	! Alt	@ Win	# Apps	~ Shift

function user_setup()
	send_command('send @all bind  numpad4  sta Pharen /Victory Smite') 
	send_command('send @all bind  numpad5  sta Pharen /ShijinSpiral') 
	send_command('send @all bind  numpad6 send Pharen /boost') 
	send_command('send @all bind !numpad4 send Pharen /DragonKick') 
	send_command('send @all bind !numpad5 send Pharen /RagingFists') 
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
    sets.Condemners = 	{ main="Godhands"}
    sets.Sophistry 	= 	{ main=""}
	sets.Footwork	=	{body="Bhikku Gaiters+2"}

	gear.TPCape		=	{ name="Segomo's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','"Dbl.Atk."+10','Damage taken-5%',}}
	gear.STRCape	=	{ name="Segomo's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','"Dbl.Atk."+10',}}
	
	
	
   --- Precast Sets ---	
    sets.precast.FC = {}
	sets.precast.JA['Chakra'] = { Body = "Anch. Cyclas +1","Melee Gloves"}
    sets.precast.WS = {
		head	= "Adhemar Bonnet +1",
		body	= "Bhikku Cyclas +3",
		hands	= "Bhikku gloves +2",
		back	= gear.STRCape,
		feet	= "Herculean Boots",
		neck	= "Republican Platinum medal",
		}
	
    sets.precast.WS['Shijin Spiral'] = set_combine(sets.precast.WS, {
		body	= "Bhikku Cyclas +3",
		head	= "Malignance Chapeau",
		hands	= "Bhikku gloves +2",
		back	= gear.TPCape,
		})
	sets.precast.WS['Victory Smite'] = set_combine(sets.precast.WS, {
		ear2	= "Odr Earring",
		})

    --- Midcast Sets ---
    sets.midcast = {}

    --- Engaged Sets ---
    sets.engaged = {
		head  	= "Bhikku Crown +3",
		neck  	= "Monk's Nodowa +2",
		ear2  	= "Mache Earring +1",
		ear1  	= "Sherida Earring",
		body  	= "Mpaca's doublet",
		hands 	= "Adhemar wristbands +1",
		ring1 	= "Gere Ring",
		ring2 	= "Lehko Habhoka's Ring",
		back  	= gear.TPCape,
		waist 	= "Moonbow Belt +1",
		legs  	= "Bhikku Hose +3",
		feet  	= "Mpaca's boots",
		ammo	= "Coiste Bodhar",
		}

    sets.defense = {
		head  	= "Bhikku Crown +3",
		neck  	= "Sanctity necklace",
		ear2  	= "Mache Earring +1",
		ear1  	= "Sherida Earring",
		body  	= "Mpaca's doublet",
		hands 	= "Adhemar wristbands +1",
		ring1 	= "Gere Ring",
		ring2 	= "Lehko Habhoka's Ring",
		back  	= gear.TPCape, 
		waist 	= "Moonbow Belt +1",
		legs  	= "Bhikku Hose +3",
		feet  	= "Bhikku gaiters +2",
        }

    --- Other Sets ---
    sets.idle = sets.defense
    sets.idle.Town = set_combine(sets.idle, {ring1="Warp Ring", ring2="Dim. Ring (Holla)"})	 
end

custom_impetus = false
function customize_melee_set(meleeSet)
    equip(sets[state.WeaponSet.current])
    if state.OffenseMode.value == "Defense" then
		meleeSet = sets.defense
    end	
	if custom_impetus == true then		
		meleeSet = set_combine(meleeSet, {body="Bhikku Cyclas +3",ear2="Cessance earring"})
	end
    return meleeSet
end
function job_aftercast(spell, action, spellMap, eventArgs)	
    equip(sets[state.WeaponSet.current])
	equip(customize_melee_set())
end
function job_state_change(field, new_value, old_value)
    if state.WeaponLock.value == true then
        disable('main','sub')
    else
        enable('main','sub')
    end
    equip(sets[state.WeaponSet.current])
	equip(customize_melee_set())
end
function job_update(cmdParams, eventArgs)
    equip(sets[state.WeaponSet.current])
	equip(customize_melee_set())
end
function job_buff_change(buff,gain)
    if buff == 'Footwork' then
        if gain then
            equip(sets.Footwork)
            disable('feet')
        else
            enable('feet')
            status_change(player.status)
        end
    end
    if buff == 'Impetus' then
        if gain then
            custom_impetus = true 
        else
            custom_impetus = false 
            status_change(player.status)
        end
    end
	equip(customize_melee_set())
end
