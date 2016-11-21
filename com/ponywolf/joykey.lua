
-- joykey
-- Re-broadcast joystick axis events as arrow keys
-- Adds new "key" events axis1+, axis1-, axis2+, etc...

local M = {}
local deadZone = 0.333
local eventCache = {}

local function onAxisEvent( event )
	local num = event.axis.number or 1
	local name = "axis" .. num
	local value = event.normalizedValue
	local oppositeAxis = "none"

	event.name = "key"  -- Overide event type

	-- Set axis raw numbers
	if value > 0 then
		event.keyName = name .. "+"
		oppositeAxis = name .. "-"
	elseif value < 0 then
		event.keyName = name .. "-"
		oppositeAxis = name .. "+"
	end

	if value == 0 then return false end
	if math.abs(value) > deadZone then
		if eventCache[oppositeAxis] then
			event.phase = "up"
			eventCache[oppositeAxis] = false
			event.keyName = oppositeAxis
			Runtime:dispatchEvent( event )
		end
		if not eventCache[event.keyName] then
			event.phase = "down"
			eventCache[event.keyName] = true
			Runtime:dispatchEvent( event )
		end
	else
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

local function onAccelerate( event )
	deadZone = 0.075  -- Reduce for accelometer events
	event.axis = {}
	event.axis.number = "Y"
	event.normalizedValue = -event.yGravity
	onAxisEvent( event )
	event.axis.number = "X"
	event.normalizedValue = event.xGravity
	onAxisEvent( event )
	event.axis.number = "Z"
	event.normalizedValue = event.zGravity
	onAxisEvent( event )
end

function M.start()
	-- Make a clear touch area
	local screen = display.newRect( display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight )
	screen.isHitTestable = true
	screen.isVisible = false
	function screen:touch( event )
		if event.phase == "began" then
			Runtime:dispatchEvent( { name = "key", keyName = "screen", phase = "down" } )
		elseif event.phase == "ended" or event.phase == "cancel" then
			Runtime:dispatchEvent( { name = "key", keyName = "screen", phase = "up" } )
		end
	end
	-- Add listeners
	screen:addEventListener( "touch" )
	Runtime:addEventListener( "axis", onAxisEvent )
	Runtime:addEventListener( "accelerometer", onAccelerate )
end

return M
