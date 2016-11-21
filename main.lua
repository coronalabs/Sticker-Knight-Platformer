--[[

This is the main.lua file. It executes first and, in this demo,
its sole purpose is to set some initial visual settings.

Then, you execute the game or menu scene via Composer.
Composer is the official scene (screen) creation and management
library in Corona; it provides developers with an
easy way to create and transition between individual scenes.

See the Composer Library guide for details:
https://docs.coronalabs.com/guide/system/composer/index.html

--]]

-- Include the Composer library
local composer = require( "composer" )

-- Removes status bar on iOS
-- https://docs.coronalabs.com/api/library/display/setStatusBar.html
display.setStatusBar( display.HiddenStatusBar ) 

-- Removes bottom bar on Android 
if system.getInfo( "platformName" ):find( "droid" ) then
	if ( system.getInfo( "androidApiLevel" ) or 0 ) < 19 then
		native.setProperty( "androidSystemUiVisibility", "lowProfile" )
	else
		native.setProperty( "androidSystemUiVisibility", "immersiveSticky" ) 
	end
end

-- Are we running on the Corona Simulator?
-- https://docs.coronalabs.com/api/library/system/getInfo.html
local isSimulator = "simulator" == system.getInfo( "environment" )

-- If we are running in the Corona Simulator, enable debugging keys
-- "F" key shows a visual monitor of our frame rate and memory usage
if isSimulator then 

	-- Show FPS
	local visualMonitor = require( "com.ponywolf.visualMonitor" )
	local visMon = visualMonitor:new()
	visMon.isVisible = false

	local function debugKeys( event )
		local phase = event.phase
		local key = event.keyName
		if phase == "up" then
			if key == "f" then
				visMon.isVisible = not visMon.isVisible 
			end
		end
	end
	-- Listen for key events in Runtime
	-- See the "key" event documentation for more details:
	-- https://docs.coronalabs.com/api/event/key/index.html
	Runtime:addEventListener( "key", debugKeys )
end

-- This module turns gamepad axis events and mobile accelerometer events into keyboard
-- events so we don't have to write separate code for joystick, tilt, and keyboard control
require( "com.ponywolf.joykey" ).start()

-- Go to menu screen
-- https://docs.coronalabs.com/api/library/composer/gotoScene.html
composer.gotoScene( "scene.menu", { params={} } )

-- Or, instead of the line above, you can cheat skip to a specific level by using the
-- following line, passing to it the JSON file of the level you want to jump to
-- composer.gotoScene( "scene.game", { params={ map="scene/game/map/sandbox2.json" } } )
