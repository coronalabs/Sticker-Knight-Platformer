-- module/class for platfomer enemy
-- Use this as a template to build an in-game enemy 

-- define module
local M = {}
local composer = require "composer"

function M.new(instance)
  if not instance then error("ERROR: Expected display object") end

  -- Get scene and sounds
  local scene = composer.getScene(composer.getSceneName("current"))
  local sounds = scene.sounds

  -- store map placement and hide placeholder
  instance.isVisible = false
  local parent = instance.parent
  local x,y = instance.x,instance.y

  -- load spritesheet
  local sheetData = { width=192, height=256, numFrames=79, sheetContentWidth=1920, sheetContentHeight=2048 }
  local sheet = graphics.newImageSheet( "scene/game/img/sprites.png", sheetData )
  local sequenceData = {
    { name="idle", frames = { 21 } },
    { name="walk", frames = { 22, 23, 24, 25 } , time = 500, loopCount = 0 },
  }  
  instance = display.newSprite( parent, sheet, sequenceData )
  instance.x,instance.y = x,y
  instance:setSequence( "walk" )
  instance:play()

  -- add physics
  physics.addBody(instance, "dynamic", { radius = 54, density = 3, bounce = 0, friction =  1.0 })
  instance.isFixedRotation = true
  instance.anchorY = 0.77
  instance.angularDamping = 3
  instance.isDead = false   

  function instance:die()
    audio.play(sounds.sword)
    self.isFixedRotation = false
    self.isSensor = true
    self:applyLinearImpulse(0, -200)
    self.isDead = true
  end

  function instance:preCollision(event)
    local other = event.other
    local y1, y2 = self.y + 50, other.y - other.height/2
    -- also skip bumping into floating platforms
    if event.contact and (y1 > y2) then
      if other.floating then 
        event.contact.isEnabled = false 
      else
        event.contact.friction = 0.1
      end
    end
  end

  local max, direction, flip, timeout = 250, 5000, 0.133, 0
  direction = direction * ((instance.xScale < 0) and 1 or -1)
  flip = flip * ((instance.xScale < 0) and 1 or -1)

  local function enterFrame()
    -- do this every frame
    local vx, vy = instance:getLinearVelocity()
    local dx = direction
    if instance.jumping then dx = dx / 4 end
    if (dx < 0 and vx > -max) or (dx > 0 and vx < max) then
      instance:applyForce(dx or 0, 0, instance.x, instance.y)
    end
    -- bumped
    if math.abs(vx) < 1 then
      timeout = timeout + 1
      if timeout > 30 then
        timeout = 0
        direction, flip = -direction, -flip
      end
    end

    -- turn around
    instance.xScale = math.min(1, math.max(instance.xScale + flip, -1))
  end

  function instance:finalize()
    -- on remove cleanup instance, or call directly for non-visual
    Runtime:removeEventListener("enterFrame", enterFrame)
    instance = nil
  end

  -- add a finalize listener (for display objects only, comment out for non-visual)
  instance:addEventListener("finalize")

  -- add our enterFrame listener
  Runtime:addEventListener("enterFrame", enterFrame)  

  -- add our collision listener
  instance:addEventListener("preCollision")  

  -- return instance
  instance.name = "enemy"  
  instance.type = "enemy"  
  return instance
end

-- return module
return M