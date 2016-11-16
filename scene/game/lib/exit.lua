-- Extends an object to load a new map

local M = {}
local composer = require "composer"
local fx = require "com.ponywolf.ponyfx"

function M.new(instance)
  if not instance then error("ERROR: Expected display object") end
  
  -- get current scene and sounds
  local scene = composer.getScene(composer.getSceneName("current"))
  local sounds = scene.sounds
  
  if not instance.bodyType then
    physics.addBody(instance, "static", { isSensor = true })    
  end  

  function instance:collision(event)
    local phase, other = event.phase, event.other
    if phase == "began" and other.name == "hero" and not other.isDead then
      other.isDead = true
      other.linearDamping = 8
      audio.play(sounds.door)
      self.fill.effect = "filter.exposure"
      transition.to (self.fill.effect, { time = 666, exposure = -5, onComplete = function ()
            fx.fadeOut( function () 
                composer.gotoScene( "scene.refresh", { params={ map = self.map, score = scene.score:get() } } )
              end)
          end } )
    end
  end

  instance:addEventListener('collision')  
  return instance
end

return M