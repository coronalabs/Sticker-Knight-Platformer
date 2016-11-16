-- health bar module

-- define module
local M = {}

-- local/module based variables

function M.new(options)

  -- default options for instance
  options = options or {}
  local x,y = options.x or 0, options.y or 0
  local w,h = options.w or 192, options.h or 24
  local foreground = options.foreground or { 0, 1, 0, 0.75 }
  local background = options.foreground or { 1, 0, 0, 0.75 }
  local align = options.align or "right"
  align = string.lower(align)

  --  create display group to hold visuals 
  local group = display.newGroup()
  group.outline = display.newRect(group,x,y,w+8,h+8)
  group.outline.alpha = 0.6
  group.backgroundBar = display.newRect(group,x,y,w,h)
  group.foregroundBar = display.newRect(group,x,y,w,h)

  if align == "left" then
    group.foregroundBar.anchorX = 0
    group.foregroundBar:translate(-w * 0.5, 0)
  elseif align == "right" then
    group.foregroundBar.anchorX = 1
    group.foregroundBar:translate(w * 0.5, 0)
  elseif align == "center" then 
    -- do nothing
  end

  group.percent = options.percent or 1

  group.backgroundBar:setFillColor(unpack(background))
  group.foregroundBar:setFillColor(unpack(foreground))  

  function group:damage(amount, speed)
    self.percent = self.percent - (amount or 0.25)
    self.percent = math.min(1,math.max(0, self.percent))
    transition.to(self.foregroundBar, { xScale = math.max(0.001, self.percent), time = speed or 500, transition=easing.outQuad } )
    return self.percent
  end

  function group:heal(amount, speed)
    self:damage(-amount, speed)
  end  

  function group:finalize()
    -- on remove cleanup instance 

  end
  group:addEventListener('finalize')
  group:damage(0,0)

-- return insantnce
  return group
end

-- return module
return M