_addon.author = 'Spikex'
_addon.version = '1.0'
_addon.commands = { 'splitscreen' }

single_screen = true
window = false
character_top_left = 'Spikex'
character_top_right = 'Sneaksy'
character_bottom_left = 'Cissilea'
character_bottom_right = 'Pharen'

windower.register_event('load', function ()
	windower.send_command('bind %home splitscreen')
	windower.send_command('bind !home splitscreen toggle ')
end)

windower.register_event('addon command', function(action)
	if action == "toggle" then
		if window then
			windower.send_command('window_togglefullscreen')			
		else
			windower.send_command('window_toggleframe')
		end
		window = not window
	else
		if single_screen then
			windower.send_command('input /echo Split Screen')
			windower.send_command('send @all wincontrol resize 960 512')
			coroutine.sleep(0.1)
			windower.send_command('send '..character_top_right..' wincontrol move 960 0')
			coroutine.sleep(0.1)
			windower.send_command('send '..character_bottom_right..' wincontrol move 960 512')
			coroutine.sleep(0.1)
			windower.send_command('send '..character_bottom_left..' wincontrol move 0 512')
			single_screen = false
		else
			windower.send_command('input /echo Single Screen')
			windower.send_command('send @all wincontrol resize reset')
			coroutine.sleep(0.1)
			windower.send_command('send '..character_top_right..' wincontrol move 0 0')
			coroutine.sleep(0.1)
			windower.send_command('send '..character_bottom_right..' wincontrol move 0 0')
			coroutine.sleep(0.1)
			windower.send_command('send '..character_bottom_left..' wincontrol move 0 0')
			single_screen = true
		end 
	end
end)