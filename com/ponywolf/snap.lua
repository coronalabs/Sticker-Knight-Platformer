-- Project: Snap
--
-- Date: Sep 11, 2014
--
-- Version: 0.1
--
-- File name: snap.lua
--
-- Author: Michael Wilson / Ponywolf
--
-- Update History:
--
-- 0.1 - Initial release
-- 0.2 - Lots of re-org
-- 0.3 - Added align
--
-- Snap display objects for HUD purposes
--
-- Examples:
--  snap(object, "topleft", 16)  to put a display object 16px from the upper left
--  snap(object, "center")  to center a display object
--  snap(object, "lowerright", 16)  to put a display object 16px from the lower left

local M = {}

local width 	= display.contentWidth
local height 	= display.contentHeight
local originX = display.screenOriginX
local originY = display.screenOriginY
local centerX = display.contentCenterX
local centerY = display.contentCenterY

-- Called when the app's view has been resized
local function onResize( event )
  width = display.contentWidth
  height = display.contentHeight
  originX = display.screenOriginX
  originY = display.screenOriginY
  centerX = display.contentCenterX
  centerY = display.contentCenterY
end

-- Add the "resize" event listener
Runtime:addEventListener( "resize", onResize )

local function getLocalCenter(object)
    local bounds = object.contentBounds
  if bounds then 
    return (bounds.xMin + bounds.xMax)/2, (bounds.yMin + bounds.yMax)/2
  else
    return false
  end
end

local function getLocalAnchor(object)
  local x,y = getLocalCenter(object)
  local bounds = object.contentBounds
  return (bounds.xMin - x) / (bounds.xMin - bounds.xMax), (bounds.yMin - y) / (bounds.yMin - bounds.yMax)
end

function M.snap(object, alignment, margin)
  if not object or not object.x or not object.y then return nil end
  local x, y = getLocalCenter(object) 
  local anchorX, anchorY

  if object.numChildren then
    anchorX, anchorY = getLocalAnchor(object)
  else   
    anchorX, anchorY = object.anchorX, object.anchorY
  end

  -- Let's do it!
  alignment = string.lower(alignment or "center")
  margin = margin or 0

	local w = object.designedWidth or object.contentWidth
	local h = object.designedHeight or object.contentHeight

  if string.find(alignment,"center") then
    --object:translate(centerX - x, centerY - y)
		object.x, object.y = centerX, centerY
  end
  if string.find(alignment,"top") or string.find(alignment,"upper") then
    object.y = originY + margin + (anchorY * h)
  end
  if string.find(alignment,"bottom") or string.find(alignment,"lower") then
    object.y = -originY + height - margin - (anchorY * h)
  end
  if string.find(alignment,"left") then
    object.x = originX + margin + (anchorX * w)
  end
  if string.find(alignment,"right") then
    object.x = -originX + width - margin - (anchorX * w)
  end
  
  return object.x, object.y -- new x,y if you need it
end

function M.align(object, reference, alignment, margin)
  if not object or not object.x or not object.y then return nil end
  if not reference or not reference.x or not reference.y then return nil end  

  alignment = string.lower(alignment or "cover")
  margin = margin or 0

  object.x, object.y = reference.x, reference.y

  if string.find(alignment,"below") then 
    object:translate(0, reference.contentHeight + margin)
  elseif string.find(alignment,"above") then 
    object:translate(0, -reference.contentHeight - margin)
  elseif string.find(alignment,"left") then 
    object:translate(-reference.contentWidth - margin, 0)
  elseif string.find(alignment,"right") then 
    object:translate(reference.contentWidth + margin, 0)
  end
end

setmetatable(M, { __call = function(_, ...) return M.snap(...) end })

return M