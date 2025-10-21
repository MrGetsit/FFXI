Just to be clear, Im not a programmer. Smashing bits of code together from all over to make this thing run is a miracle it even works. Seems to run fine for me but your mileage may vary. Still a work in progress.

# Multibox

A simple multiboxing addon to give basic orders to all other characters. Shows cooldown for all characters abilities using the timers addon custom timers.

### Command Usage:
```
mb follow    -- Single tap to order all characters to disenage from enemies and follow, double tap to move all characters to current position
mb stop      -- All characters stop following
mb advance   -- All characters engage and move towards whatever enemy you have targeted
mb retreat   -- Single tap to turn all away from enemy, double tap to order others to run away to a set distance (12 meters default)           

ctrl + enter -- Order all characters interact with whatever you have targeted, or press enter if already interacting
ctrl + up    -- All characters hold up briefly
ctrl + down  -- All characters hold down briefly
```
Designed to be set up as hotkeys in your init such as:
```
bind %numpad0 multibox follow;
bind !numpad0 multibox stop;
bind %numpad. multibox advance;
bind !numpad. multibox retreat;
```
