-- Requirements
local composer = require "composer"
local fx = require "com.ponywolf.ponyfx"
local tiled = require "com.ponywolf.ponytiled"
local json = require "json"

-- Variables local to scene
local scene = composer.newScene()
local ui, music, sword

function scene:create( event )
  local sceneGroup = self.view -- add display objects to this group

  -- music
  music = audio.loadSound("scene/menu/sfx/titletheme.ogg")

  -- load our ui
  local uiData = json.decodeFile(system.pathForFile("scene/menu/ui/title.json", system.ResourceDirectory))
  ui = tiled.new(uiData, "scene/menu/ui")
  ui.x, ui.y = display.contentCenterX - ui.designedWidth/2, display.contentCenterY - ui.designedHeight/2

  -- find the start button
  local start = ui:findObject("start")
  function start:tap()
    fx.fadeOut(function ()
        composer.gotoScene( "scene.game", { params = { } })
      end)
  end
  fx.breath(start)
  start:addEventListener("tap")

  -- find the help button
  local help = ui:findObject("help")
  function help:tap()
    ui:findLayer("help").isVisible = not ui:findLayer("help").isVisible
  end
  help:addEventListener("tap")
  
  -- transtion in logo
  transition.from(ui:findObject("logo"), {xScale = 2.5, yScale = 2.5, time = 333, transition = easing.outQuad } )

  -- add streaks
  local streaks = fx.newStreak()
  streaks.x,streaks.y = ui:findObject("logo"):localToContent(-10,0)
  ui:findLayer("clouds"):insert(streaks)

  sceneGroup:insert(ui)
end

local function enterFrame(event)
  local elapsed = event.time

end

function scene:show( event )
  local phase = event.phase
  if ( phase == "will" ) then
    Runtime:addEventListener("enterFrame", enterFrame)
  elseif ( phase == "did" ) then
    audio.play(music, { loops = -1, fadein = 750, channel = 16 } )
  end
end

function scene:hide( event )
  local phase = event.phase
  if ( phase == "will" ) then
    audio.fadeOut( {channel = 16, time = 1500 } )
  elseif ( phase == "did" ) then
    Runtime:removeEventListener("enterFrame", enterFrame)  
  end
end

function scene:destroy( event )
  audio.stop()
  audio.dispose(music)  
end

scene:addEventListener("create")
scene:addEventListener("show")
scene:addEventListener("hide")
scene:addEventListener("destroy")

return scene