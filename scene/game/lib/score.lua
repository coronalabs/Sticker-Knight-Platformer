
-- Score lib

-- Define module
local M = {}

function M.new( options )

	-- Default options for instance
	options = options or {}
	local label = options.label or ""
	local x, y = options.x or 0, options.y or 0
	local font = options.font or "scene/game/font/GermaniaOne-Regular.ttf"
	local size = options.size or 56
	local align = options.align or "right"
	local stroked = options.stroked or true
	local color = options.color or { 1, 1, 1, 1 }
	local width = options.width or 256

	local score
	local num = options.score or 0
	local textOptions = { x = x, y = y, text = label .. " " .. num, width = width, font = font, fontSize = size, align = align }

	score = display.newEmbossedText( textOptions )
	score.num = num
	score.target = num

	score:setFillColor( unpack(color) )

	function score:add( points )
		score.target = self.target + ( points or 10 )
		local function countUp()
			local diff = math.ceil( ( score.target - score.num ) / 12 )
			score.num = score.num + diff
			if score.num > score.target then
				score.num = score.target
				timer.cancel( score.timer )
				score.timer = nil
			end
			score.text = label .. " " .. ( score.num or 0 )
		end
		if not score.timer then
			score.timer = timer.performWithDelay( 30, countUp, -1 )
		end
	end
  
	function score:get() return score.target or 0 end

	function score:finalize()
		-- On remove, cleanup instance
		if score and score.timer then timer.cancel( score.timer ) end
	end

	score:addEventListener( "finalize" )

	-- Return instance
	return score
end

return M
