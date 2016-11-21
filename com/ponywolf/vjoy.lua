
-- Project: vjoy 0.3
--
-- A virtual joystick and button system that emulates
-- an xBox controller axis/button events

local M = {}
local stage = display.getCurrentStage()

function M.newButton(key, radius)

  local instance
  radius = radius or 64
  key = key or "buttonA"

  if type(radius) == "number" then
    instance = display.newCircle(0,0, radius)
    instance:setFillColor( 0.2, 0.2, 0.2, 0.9 )
    instance.strokeWidth = 6
    instance:setStrokeColor( 1, 1, 1, 1 )
  else
    instance = display.newImage( instance, radius, 0,0 )
  end

  function instance:touch(event)
    local phase = event.phase
    if phase=="began" then
      if event.id then stage:setFocus(event.target, event.id) end
      self.xScale, self.yScale = 0.95, 0.95
      local keyEvent = {name = "key", phase = "down", keyName = key or "none"}
      Runtime:dispatchEvent(keyEvent)
    elseif phase=="ended" or phase == "canceled" then
      if event.id then stage:setFocus(nil, event.id) end
      self.xScale, self.yScale = 1, 1
      local keyEvent = {name = "key", phase = "up", keyName = key or "none"}
      Runtime:dispatchEvent(keyEvent)
    end
    return true
  end

  function instance.activate()
    instance:addEventListener("touch")
  end

  function instance.deactivate()
    instance:removeEventListener("touch")
  end

  instance.activate()
  return instance
end

function M.newStick(startAxis, innerRadius, outerRadius)

  startAxis = startAxis or 1
  innerRadius, outerRadius = innerRadius or 48, outerRadius or 96
  local instance = display.newGroup()

  local outerArea 
  if type(outerRadius) == "number" then
    outerArea = display.newCircle( instance, 0,0, outerRadius )
    outerArea.strokeWidth = 8
    outerArea:setFillColor( 0.2, 0.2, 0.2, 0.9 )
    outerArea:setStrokeColor( 1, 1, 1, 1 )
  else
    outerArea = display.newImage( instance, outerRadius, 0,0 )
    outerRadius = (outerArea.contentWidth + outerArea.contentHeight) * 0.25
  end

  local joystick 
  if type(innerRadius) == "number" then
    joystick = display.newCircle( instance, 0,0, innerRadius )
    joystick:setFillColor( 0.4, 0.4, 0.4, 0.9 )
    joystick.strokeWidth = 6
    joystick:setStrokeColor( 1, 1, 1, 1 )
  else
    joystick = display.newImage( instance, innerRadius, 0,0 )
    innerRadius = (joystick.contentWidth + joystick.contentHeight) * 0.25
  end  

  -- where should joystick motion be stopped?
  local stopRadius = outerRadius - innerRadius

  function joystick:touch(event)
    local phase = event.phase
    if phase=="began" or (phase=="moved" and self.isFocus) then
      if phase == "began" then
        stage:setFocus(event.target, event.id)
        self.eventID = event.id
        self.isFocus = true
      end
      local parent = self.parent
      local posX, posY = parent:contentToLocal(event.x, event.y)
      local angle = -math.atan2(posY, posX)
      local distance = math.sqrt((posX*posX)+(posY*posY))

      if( distance >= stopRadius ) then
        distance = stopRadius
        self.x = distance*math.cos(angle)
        self.y = -distance*math.sin(angle)
      else
        self.x = posX
        self.y = posY
      end
    else
      self.x = 0
      self.y = 0
      stage:setFocus(nil, event.id)
      self.isFocus = false
    end
    instance.axisX = self.x / stopRadius
    instance.axisY = self.y / stopRadius
    local axisEvent
    if not (self.y == (self._y or 0)) then
      axisEvent = {name = "axis", axis = { number = startAxis }, normalizedValue = instance.axisX }
      Runtime:dispatchEvent(axisEvent)
    end
    if not (self.x == (self._x or 0))  then 
      axisEvent = {name = "axis", axis = { number = startAxis+1 }, normalizedValue = instance.axisY }
      Runtime:dispatchEvent(axisEvent)
    end
    self._x, self._y = self.x, self.y
    return true
  end

  function instance:activate()
    self:addEventListener("touch", joystick )
    self.axisX = 0
    self.axisY = 0
  end

  function instance:deactivate()
    stage:setFocus(nil, joystick.eventID)
    joystick.x, joystick.y = outerArea.x, outerArea.y
    self:removeEventListener("touch", self.joystick )
    self.axisX = 0
    self.axisY = 0
  end

  instance:activate()
  return instance
end

return M
