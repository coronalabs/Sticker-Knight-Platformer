
-- joykey 0.1

-- Re-broadcast joystick axis events as arrow keys

-- This module turns gamepad axis events into keyboard events
-- so we don't have to write separate code for joystick and keyboard control.
-- Just add this line to your main.lua:
-- require( "com.ponywolf.joykey" ).start()

local M = {}
local deadZone = 0.333

-- Store previous events
local eventCache = {}

-- Store key mappings
local map = {}

-- Map the axis to arrow keys and wsad
map["axis1-"] = "left"
map["axis1+"] = "right"
map["axis2-"] = "up"
map["axis2+"] = "down"

map["axis3-"] = "a"
map["axis3+"] = "d"
map["axis4-"] = "w"
map["axis4+"] = "s"

-- Capture the axis event
local function axis( event )
	local num = event.axis.number or 1
	local name = "axis" .. num
	local value = event.normalizedValue
	local oppositeAxis = "none"
	event = event or {}

	event.name = "key"  -- Overide event type

	-- Set map axis to key
	if value > 0 then
		event.keyName = map[name .. "+"]
		oppositeAxis = map[name .. "-"]
	elseif value < 0 then
		event.keyName = map[name .. "-"]
		oppositeAxis = map[name .. "+"]
	else
		-- We had an exact 0 so throw both key up events for this axis
		event.keyName = map[name .. "-"]
		oppositeAxis = map[name .. "+"]
	end
	
	if event.keyName then 
		if math.abs(value) > deadZone then
			-- Throw the opposite axis if it was last pressed
			if eventCache[oppositeAxis] then
				event.phase = "up"
				eventCache[oppositeAxis] = false
				event.keyName = oppositeAxis
				Runtime:dispatchEvent( event )
			end
			-- Throw this axis if it wasn't last pressed
			if not eventCache[event.keyName] then
				event.phase = "down"
				eventCache[event.keyName] = true
				Runtime:dispatchEvent( event )
			end
		else
			-- We're back toward center
			if eventCache[event.keyName] then
				event.phase = "up"
				eventCache[event.keyName] = false
				Runtime:dispatchEvent( event )
			end
			if eventCache[oppositeAxis] then
				event.phase = "up"
				eventCache[oppositeAxis] = false
				event.keyName = oppositeAxis
				Runtime:dispatchEvent( event )
			end
		end
	end
	return true
end

function M.start()
	Runtime:addEventListener( "axis", axis )
end

return M
