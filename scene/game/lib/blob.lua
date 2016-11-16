-- module/class for platfomer animal/blob
-- Use this as a template to build an in-game animal/blob

-- define module
local M = {}
local composer = require "composer"

function M.new(instance)
  if not instance then error("ERROR: Expected display object") end

  -- Get scene and sounds
  local scene = composer.getScene(composer.getSceneName("current"))
  local sounds = scene.sounds

  -- add physics
  instance.anchorY = 1  
  physics.addBody(instance, "dynamic", { density = 1, bounce = 0, friction =  1.0 })
  instance.isFixedRotation = true
  instance.angularDamping = 3
  instance.isDead = false 

  function instance:die()
    audio.play(sounds.squish)
    self.isFixedRotation = false
    self.isSensor = true
    self:applyLinearImpulse(0, -100)
    self.isDead = true
  end

  function instance:preCollision(event)
    local other = event.other
    local y1, y2 = self.y, other.y - other.height/2
    if event.contact and (y1 > y2) then
      -- don't bump into one way platforms
      if other.floating then 
        event.contact.isEnabled = false 
      else
        event.contact.friction = 0.1
      end
    end
  end

  local max, direction, flip, timeout, idle = 200, 750, -0.133, 0, 0
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
    -- breathe
    idle = idle + 0.08
    instance.yScale = 1 + (0.075 * math.sin(idle))

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
  return instance
end

-- return module
return M