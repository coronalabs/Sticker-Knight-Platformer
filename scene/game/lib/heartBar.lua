-- heart bar module

-- define module
local M = {}

-- local/module based variables

function M.new(options)

  -- default options for instance
  options = options or {}
  local image = options.image
  local max = options.max or 3
  local spacing = options.spacing or 8
  local w, h = options.width or 64, options.height or 64

  --  create display group to hold visuals 
  local group = display.newGroup()
  local hearts = {}
  for i = 1, max do 
    hearts[i] = display.newImageRect("scene/game/img/shield.png", w,h )  
    hearts[i].x = (i-1) * ((w/2) + spacing)
    hearts[i].y = 0
    group:insert(hearts[i])
  end  
  group.count = max

  function group:damage(amount)
    group.count = math.min(max,math.max(0,group.count - (amount or 1)))
    for i = 1, max do
      if i <= group.count then 
        hearts[i].alpha = 1
      else 
        hearts[i].alpha =  0.2
      end
    end
    return group.count
  end

  function group:heal(amount)
    self:damage(-(amount or 1))
  end  

  function group:finalize()
    -- on remove cleanup instance 
  end
  group:addEventListener('finalize')

-- return insantnce
  return group
end

-- return module
return M