require('sets')
 
filter = S{
	'*/ma*',
	'*/ja*',
	'*command error*',
    '* does not have enough *',
    'Unable to use *',
    'Auto-targeting *',
    '* can only use that command during *',
	'Time left: *',
	'This action requires*',
	'A command error*',
	'You are ineligible*',
	'Unable to cast*',
	'You have not earned*',
	'* cannot use that weapon *',
	'Records of Eminence: *',
	'You find a* *crystal on the*',
	'You must wait longer to perform that action.',	
	'Progress:*',
	'Limit chain*',
	'*gains*limit points*',
	'You receive * sparks of eminence*',
	'You receive * Unity accolades for a total of*',
	'*You are cleared to fulfill this objective once again*',
	'Sound effects:*',
	'Background music:*',
	'You cannot use that command at this time.',
}
 
windower.register_event('incoming text', function(text)
    return filter:any(windower.wc_match+{text})
end)