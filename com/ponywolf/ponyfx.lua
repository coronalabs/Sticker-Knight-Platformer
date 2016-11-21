-- ponyfx

local M = {}

local function lenSqr( dx, dy, dz )
	return ( dx * dx + dy * dy + dz * dz )
end

function M.flash( object, frames, listener )

	if not object.contentBounds then
		print( "WARNING: Object not found" )
		return false
	end

	local function flash()
		object.fill.effect = "filter.duotone"
		object.fill.effect.darkColor = { 1, 1, 1, 1 }
		object.fill.effect.lightColor = { 1, 1, 1, 1 }
	end
	local function revert()
		object.fill.effect = nil
	end

	object._flashFrames = math.min( 180, ( frames or 30 ) + ( object._flashFrames or 0 ) )
	local function cycle()
		if ( object._flashFrames > 0 ) and object.contentBounds then  -- Flash it
			if object._flashFrames % 2 == 1 then
				revert()
			else
				flash()
			end
			object._flashFrames = object._flashFrames - 1
		else
			Runtime:removeEventListener( "enterFrame", cycle )
			if listener then listener() end
		end
	end
	Runtime:addEventListener( "enterFrame", cycle )
end

-- Flash screen
function M.screenFlash( color, blendMode, time )

	color = color or { 1, 1, 1, 1 }
	blendMode = blendMode or "add"
	local overlay = display.newRect(
		display.contentCenterX,
		display.contentCenterY,
		display.actualContentWidth,
		display.actualContentHeight )
	overlay:setFillColor( unpack(color) )
	overlay.blendMode = blendMode
	
	local function destroy()
		display.remove( overlay )
	end
	-- Transitions are used to animate/interpolate an object's properties over time
	-- See the Transitions/Tweens guide for more information:
	-- https://docs.coronalabs.com/guide/media/transitionLib/index.html
	transition.to( overlay, { alpha = 0, time = time, transition = easing.outQuad, onComplete = destroy } )
end

function M.fadeOut( onComplete, time, delay )

	local color = { 0, 0, 0, 1 }
	local overlay = display.newRect(
		display.contentCenterX,
		display.contentCenterY,
		display.actualContentWidth,
		display.actualContentHeight )
	overlay:setFillColor( unpack(color) )
	overlay.alpha = 0
	
	local function destroy()
		if onComplete then onComplete() end
		display.remove( overlay )
	end
	transition.to( overlay, { alpha = 1, time = time, delay = delay, transition = easing.outQuad, onComplete = destroy } )
end

function M.fadeIn( onComplete, time, delay )

	local color = { 0, 0, 0, 1 }
	local overlay = display.newRect(
		display.contentCenterX,
		display.contentCenterY,
		display.actualContentWidth,
		display.actualContentHeight )
	overlay:setFillColor( unpack(color) )
	overlay.alpha = 1
	
	local function destroy()
		if onComplete then onComplete() end
		display.remove( overlay )
	end
	transition.to( overlay, { alpha = 0, time = time, delay = delay, transition = easing.outQuad, onComplete = destroy } )
end

-- Impact fx function
function M.impact( object, intensity, time )

	if not object.contentBounds then
		print( "WARNING: Object not found" )
		return false
	end
	
	intensity = 1 - ( intensity or 0.25 )
	time = time or 250
	local sx, sy = object.xScale, object.yScale
	local i = { time = time, rotation = 15 - math.random(30), xScale = sx/intensity, yScale = sy/intensity, transition = easing.outBounce }
	transition.from( object, i )
end

-- Bounce fx function
function M.bounce( object, intensity, time )

	if not object.contentBounds then
		print( "WARNING: Object not found" )
		return false
	end
	
	object._y = object.y
	intensity = intensity or 0.05
	time = time or 500
	local i = { y = object._y - ( object.width * intensity ), transition = easing.outBounce, time = time, iterations = -1 }
	transition.from( object, i )
end

-- Breath fx function
function M.breath( object, intensity, time )

	if not object.contentBounds then
		print( "WARNING: Object not found" )
		return false
	end

	intensity = 1 - ( intensity or 0.05 )
	time = time or 250
	local w, h, i, e = object.width, object.height, {}, {}
	local function inhale() transition.to( object, i ) end
	local function exhale() transition.to( object, e ) end

	-- Set transitions
	i = { time  =time, width = w * intensity, height = h / intensity, transtion = easing.inOutQuad, onComplete = exhale }
	e = { time = time, width = w / intensity, height = h * intensity, transtion = easing.inOutQuad, onComplete = inhale }

	inhale()
end

-- Shake object function
function M.shake( object, frames, intensity )

	if not object.contentBounds then
		print( "WARNING: Object not found" )
		return false
	end

	-- Add frames to count
	object._shakeFrames = math.min( 180, ( frames or 30 ) + ( object._shakeFrames or 0 ) )
	object._iX, object._iY = 0, 0

	local function shake()
		if ( object._shakeFrames > 0 ) and  object.contentBounds then  -- Shake it
			intensity = intensity or 128
			if object._shakeFrames % 2 == 1 then
				object._iX = ( math.random(intensity) - (intensity/2) ) * ( object._shakeFrames/100 )
				object._iY = ( math.random(intensity) - (intensity/2) ) * ( object._shakeFrames/100 )
				object.x = object.x + object._iX
				object.y = object.y + object._iY
			else
				object.x = object.x - object._iX
				object.y = object.y - object._iY
			end
			object._shakeFrames = object._shakeFrames - 1
		else
			Runtime:removeEventListener( "enterFrame", shake )
		end
	end

	-- Get shaking
	Runtime:addEventListener( "enterFrame", shake )
end

-- Object Trails
function M.newTrail( object, options )

	if not object.contentBounds then
		print( "WARNING: Object not found" )
		return false
	end

	options = options or {}

	local image = options.image or "com/ponywolf/ponyfx/circle.png"

	local dw, dh = object.width, object.height
	local size = options.size or ( dw > dh ) and ( dw * 0.9 ) or ( dh * 0.9 )
	local w, h = size, size
	local ox, oy = options.offsetX or 0, options.offsetY or 0
	local trans = options.transition or { time = 250, alpha = 0, delay = 50, xScale = 0.01, yScale = 0.01 }
	local delay = options.delay or 0
	local color = options.color or { 1.0 }
	local alpha = options.alpha or 0.5
	local blendMode = options.blendMode or "add"
	local frameSkip = options.frameSkip or 1
	local frame = 1

	local trail = display.newGroup()
	if options.parent then
		options.parent:insert( trail )
	else
		if object.parent then object.parent:insert( trail ) end
	end
	trail.ox, trail.oy, trail.oz, trail.oa = object.x, object.y, ( object.z or 0 ), object.rotation
	trail.alpha = alpha

	local function enterFrame()
		frame = frame + 1

		-- Object destroyed
		if not object.contentBounds then
			trail:finalize()
			return false
		end

		-- Haven't moved
		if lenSqr( object.x - trail.ox, object.y - trail.oy, ( object.z or 0 ) - trail.oz ) < 1 * 1 then return false end
		trail.ox, trail.oy, trail.oz = object.x, object.y, (object.z or 0)

		if frame > frameSkip then
			frame = 1
		else
			return false
		end

		-- Create trail
		local particle = display.newImageRect( trail, image, w, h )
		transition.from( particle, { alpha = 0, time = delay } )

		-- Color
		particle:setFillColor( unpack(color) )
		particle.blendMode = blendMode

		-- Place
		particle.x, particle.y = object.x + ox, object.y + oy - ( object.z or 0 )
		particle.rotation = object.rotation

		-- Finalization
		trans.onComplete = function()
			display.remove( particle )
			particle = nil
		end

		-- Transition
		transition.to( particle, trans )
	end

	Runtime:addEventListener("enterFrame", enterFrame)

	function trail:finalize()
		Runtime:removeEventListener( "enterFrame", enterFrame )
		local function onComplete()
			display.remove( self )
			trail = nil
		end
		transition.to( trail, {alpha = 0, onComplete = onComplete } )
	end

	trail:addEventListener( "finalize" )
	return trail
end

-- Spinning streaks for menus and such
function M.newStreak( options )

	options = options or {}

	local image = options.image or "com/ponywolf/ponyfx/streaksFade.png"

	local dw, dh = display.actualContentWidth, display.actualContentHeight
	local length = options.length or ( dw > dh ) and ( dw * 0.666 ) or ( dh * 0.666 )
	local count = options.count or 18
	local speed = options.speed or 0.333
	local ratio = options.ratio or 2.666
	local color = options.color or { 1.0 }
	local streaks = display.newGroup()

	for i = 1, math.floor( 360 / count ) do
		local streak = display.newImageRect( image, length, length / count * ratio )
		streak.anchorX = 0
		streak.x, streak.y = 0, 0
		streak.rotation = i * count
		streak:setFillColor( unpack(color) )
		streaks:insert( streak )
	end

	local function spin()
		streaks:rotate( speed )
	end

	function streaks:start()
		Runtime:addEventListener( "enterFrame", spin )
	end

	function streaks:stop()
		Runtime:removeEventListener( "enterFrame", spin )
	end

	function streaks:finalize()
		self:stop()
	end

	streaks:addEventListener( "finalize" )
	streaks:start()
	return streaks
end

return M
