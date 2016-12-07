
-- Include modules/libraries
local composer = require( "composer" )
local fx = require( "com.ponywolf.ponyfx" )
local tiled = require( "com.ponywolf.ponytiled" )
local physics = require( "physics" )
local json = require( "json" )
local scoring = require( "scene.game.lib.score" )
local heartBar = require( "scene.game.lib.heartBar" )

-- Variables local to scene
local map, hero, shield, parallax

-- Create a new Composer scene
local scene = composer.newScene()

-- This function is called when scene is created
function scene:create( event )

	local sceneGroup = self.view  -- Add scene display objects to this group

	-- Sounds
	local sndDir = "scene/game/sfx/"
	scene.sounds = {
		thud = audio.loadSound( sndDir .. "thud.wav" ),
		sword = audio.loadSound( sndDir .. "sword.wav" ),
		squish = audio.loadSound( sndDir .. "squish.wav" ),
		slime = audio.loadSound( sndDir .. "slime.wav" ),
		wind = audio.loadSound( sndDir .. "loops/spacewind.wav" ),
		door = audio.loadSound( sndDir .. "door.wav" ),
		hurt = {
			audio.loadSound( sndDir .. "hurt1.wav" ),
			audio.loadSound( sndDir .. "hurt2.wav" ),
		},
		hit = audio.loadSound( sndDir .. "hit.wav" ),
		coin = audio.loadSound( sndDir .. "coin.wav" ),
	}

	-- Start physics before loading map
	physics.start()
	physics.setGravity( 0, 32 )

	-- Load our map
	local filename = event.params.map or "scene/game/map/sandbox.json"
	local mapData = json.decodeFile( system.pathForFile( filename, system.ResourceDirectory ) )
	map = tiled.new( mapData, "scene/game/map" )
	--map.xScale, map.yScale = 0.85, 0.85

	-- Find our hero!
	map.extensions = "scene.game.lib."
	map:extend( "hero" )
	hero = map:findObject( "hero" )
	hero.filename = filename

	-- Find our enemies and other items
	map:extend( "blob", "enemy", "exit", "coin", "spikes" )

	-- Find the parallax layer
	parallax = map:findLayer( "parallax" )

	-- Add our scoring module
	local gem = display.newImageRect( sceneGroup, "scene/game/img/gem.png", 64, 64 )
	gem.x = display.contentWidth - gem.contentWidth / 2 - 24
	gem.y = display.screenOriginY + gem.contentHeight / 2 + 20

	scene.score = scoring.new( { score = event.params.score } )
	local score = scene.score
	score.x = display.contentWidth - score.contentWidth / 2 - 32 - gem.width
	score.y = display.screenOriginY + score.contentHeight / 2 + 16

	-- Add our hearts module
	shield = heartBar.new()
	shield.x = 48
	shield.y = display.screenOriginY + shield.contentHeight / 2 + 16
	hero.shield = shield

	-- Insert our game items in the correct back-to-front order
	sceneGroup:insert( map )
	sceneGroup:insert( score )
	sceneGroup:insert( gem )
	sceneGroup:insert( shield )

end

-- Function to scroll the map
local function enterFrame( event )

	local elapsed = event.time

	-- Easy way to scroll a map based on a character
	if hero and hero.x and hero.y and not hero.isDead then
		local x, y = hero:localToContent( 0, 0 )
		x, y = display.contentCenterX - x, display.contentCenterY - y
		map.x, map.y = map.x + x, map.y + y
		-- Easy parallax
		if parallax then
			parallax.x, parallax.y = map.x / 6, map.y / 8  -- Affects x more than y
		end
	end
end

-- This function is called when scene comes fully on screen
function scene:show( event )

	local phase = event.phase
	if ( phase == "will" ) then
		fx.fadeIn()	-- Fade up from black
		Runtime:addEventListener( "enterFrame", enterFrame )
	elseif ( phase == "did" ) then
		-- Start playing wind sound
		-- For more details on options to play a pre-loaded sound, see the Audio Usage/Functions guide:
		-- https://docs.coronalabs.com/guide/media/audioSystem/index.html
		audio.play( self.sounds.wind, { loops = -1, fadein = 750, channel = 15 } )
	end
end

-- This function is called when scene goes fully off screen
function scene:hide( event )

	local phase = event.phase
	if ( phase == "will" ) then
		audio.fadeOut( { time = 1000 } )
	elseif ( phase == "did" ) then
		Runtime:removeEventListener( "enterFrame", enterFrame )
	end
end

-- This function is called when scene is destroyed
function scene:destroy( event )

	audio.stop()  -- Stop all audio
	for s, v in pairs( self.sounds ) do  -- Release all audio handles
		audio.dispose( v )
		self.sounds[s] = nil
	end
end

scene:addEventListener( "create" )
scene:addEventListener( "show" )
scene:addEventListener( "hide" )
scene:addEventListener( "destroy" )

return scene
