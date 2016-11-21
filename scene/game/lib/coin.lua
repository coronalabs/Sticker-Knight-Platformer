
-- Extends an object to act as a pickup

-- Define module
local M = {}

local composer = require( "composer" )

function M.new( instance )
	if not instance then error( "ERROR: Expected display object" ) end

	-- Get scene and sounds
	local scene = composer.getScene( composer.getSceneName( "current" ) )
	local sounds = scene.sounds

	function instance:collision( event )

		local phase, other = event.phase, event.other
		if phase == "began" and other.type == "hero" then
			audio.play( sounds.coin )
			scene.score:add( 100 )
			display.remove( self )
		end
	end

	instance._y = instance.y
	physics.addBody( instance, "static", { isSensor = true } )
	transition.from( instance, { y = instance._y - 16, transition = easing.outBounce, time = 500, iterations = -1 } )
	instance:addEventListener( "collision" )

	return instance
end

return M
