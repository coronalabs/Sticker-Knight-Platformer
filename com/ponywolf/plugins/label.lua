-- smart label

local M = {}
local renderSteps = 1

local function decodeTiledColor(hex)
  hex = hex or "#FF888888"
  hex = hex:gsub("#","")
  local function hexToFloat(part)
    part = part or "00"
    part = part == "" and "00" or part
    return tonumber("0x".. (part or "00")) / 255
  end
  local a, r, g, b =  hexToFloat(hex:sub(1,2)), hexToFloat(hex:sub(3,4)), hexToFloat(hex:sub(5,6)) , hexToFloat(hex:sub(7,8)) 
  return r,g,b,a
end

local function strokedText(options)

  -- default options for instance
  options = options or {}
  local x = options.x or 0
  local y = options.y or 0
  local h = options.height
  local parent = options.parent
  options.height = nil
  options.x = 0
  options.y = 0
  options.parent = nil

  -- new options 
  local color = options.color or {1,1,1,1}
  local strokeColor = options.strokeColor or {0,0,0,0.75}
  local strokeWidth = options.strokeWidth or 1

  -- create the main text
  local text = display.newText(options)
  text:setFillColor(unpack(color))

  --  create group to hold text/strokes
  local stroked = display.newGroup()
  if parent then parent:insert(stroked) end
  stroked:insert(text)
  stroked.strokes = {}
  stroked.unstroked = text

  -- draw the strokes
  for i = -strokeWidth, strokeWidth, renderSteps do
    for j = -strokeWidth, strokeWidth, renderSteps do
      if not (i == 0 and j == 0) then --skip middle
        options.x,options.y = i,j
        local stroke = display.newText(options)
        stroke:setFillColor(decodeTiledColor(strokeColor))
        stroked:insert(stroke)
      end
    end
  end

  -- call this function to update the label
  function stroked:update(text)
    self.text = text
    for i=1, stroked.numChildren do
      stroked[i].text = text
    end
  end

  function stroked:setTextColor(...)
    stroked.unstroked:setFillColor(...)
  end

  stroked:translate(x,y)
  text:toFront()
  return stroked
end

function M.new(instance)
  if not instance then error("ERROR: Expected display object") end  

  -- remember inital object
  local tiledObj = instance

  -- set defaults
  local text = tiledObj.text or " "
  text = text:gsub("|","\n")
  local font = tiledObj.font or native.systemFont
  local size = tiledObj.size or 20
  local stroked = tiledObj.stroked
  local strokeColor = tiledObj.labelStrokeColor or "000000CC"
  local align = tiledObj.align or "center"
  local color = tiledObj.color or "FFFFFFFF"
  local params = { parent = tiledObj.parent,
    x = tiledObj.x, y = tiledObj.y, strokeColor = strokeColor,
    text = text, font = font, fontSize = size, strokeWidth = tiledObj.labelStrokeWidth,
    align = align, width = tiledObj.width } 

  if stroked then
    instance = strokedText(params)
  else
    instance = display.newText(params)
    function instance:update(text) instance.text = text end
  end
  instance:setTextColor(decodeTiledColor(color))

-- push the rest of the properties
  instance.rotation = tiledObj.rotation 
  instance.name = tiledObj.name 
  instance.type = tiledObj.type
  instance.alpha = tiledObj.alpha 

  if not tiledObj.keepInstance then
    display.remove(tiledObj)
  end
  
  return instance
end

return M