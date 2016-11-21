--    ____                                   ______
--   / __ \____  ____  __  ___      ______  / / __/
--  / /_/ / __ \/ __ \/ / / / | /| / / __ \/ / /_  
-- / ____/ /_/ / / / / /_/ /| |/ |/ / /_/ / / __/  
--/_/    \____/_/ /_/\__, / |__/|__/\____/_/_/     
--                  /____/      

-- Commented config.lua by Ponywolf

-- Calculate the aspect ratio of the device; will error on Desktop builds
--local aspectRatio = display.pixelHeight / display.pixelWidth

application = {

	-- A fundamental concept behind content scaling is the content area. In Corona, your base
	-- content area can be whatever you wish, but often it's based around a common screen
	-- width/height aspect ratio like 2:3, for example 320×480.
	-- See the Project Configuration guide for more information:
	-- https://docs.coronalabs.com/guide/basics/configSettings/index.html

	content = {

		-- Set content area width/height settings for 1080p resolution here
		-- Note that even for landscape-oriented apps, width should be the "short" side for Corona's purposes
		width = 800,
		height = 1280,

		-- Sample aspect-driven width/height:
		--width = aspectRatio > 1.5 and 720 or math.ceil( 1200 / aspectRatio ),
		--height = aspectRatio < 1.5 and 1200 or math.ceil( 720 * aspectRatio ),

		-- The scaling method of the content area is determined by the "scale" value.
		-- If you omit this (not recommended), the width and height values will be ignored and the
		-- content area will be set to the device's actual pixel width and height.
		scale = "letterbox",
		-- "letterbox" scales the content area to fill the screen while preserving the same aspect ratio
		-- "zoomEven" scales the content area to fill the screen while preserving the same aspect ratio
		-- "adaptive" uses a dynamic content width and height based on the device

		-- If you need to align the content area to an edge of the screen, you can use "xAlign"/"yAlign"
		-- By default, scaled content is centered on the screen
		-- In "letterbox" scale mode, empty screen area will be evenly divided between both sides
		-- In "zoomEven" mode, the bleed area will be cropped equally on both sides
		xAlign = "center",  -- Possible values are "left", "center", or "right"
		yAlign = "center",  -- Possible values are "top", "center", or "bottom"

		-- The default frame rate is 30 frames per second, but you can set it to 60 frames per second
		-- by adding the "fps" key. Values other than 30 or 60 will be ignored.
		fps = 60,

		--local deviceScale = display.pixelWidth / display.actualContentWidth
		-- This is the scale factor for the device. If the value on a particular device is greater than or
		-- equal to the number you specify for the scale factor, Corona will use images from that suffix set.

		--imageSuffix = { ["@2x"] = 1.5 },
		-- With this line enabled, high-resolution devices (Retina iPad, Kindle Fire HD 9", Nexus 10, etc.)
		-- will use @2x-suffixed images. Devices less than 1200 pixels in width will use non-suffixed images.

		-- This is used to override the default shader precision for all OpenGL ES shaders (on devices)
		-- You should not specify this unless you absolutely require higher precision and see no performance impact
		--shaderPrecision = "highp",  -- Acceptable values are "highp", "mediump", or "lowp"
	},

	-- This global setting triggers pop-up error messages while running an app in the Corona Simulator
	-- If you don't like this feature or if it doesn't fit your workflow, you can turn it off
	--showRuntimeErrors = true,
}
