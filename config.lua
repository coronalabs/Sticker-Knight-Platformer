--    ____                                   ______
--   / __ \____  ____  __  ___      ______  / / __/
--  / /_/ / __ \/ __ \/ / / / | /| / / __ \/ / /_  
-- / ____/ /_/ / / / / /_/ /| |/ |/ / /_/ / / __/  
--/_/    \____/_/ /_/\__, / |__/|__/\____/_/_/     
--                  /____/      

-- Commented config.lua by Ponywolf

-- Calculate the aspect ratio of the device:
-- will error on Desktop Builds
--local aspectRatio = display.pixelHeight / display.pixelWidth

application = {
  
--  A fundamental concept behind content scaling is content area. In Corona, your base
--  content area can be whatever you wish, but often it's based around a common screen
--  width/height aspect ratio like 2:3, for example 320×480

  content = {

-- Sample aspect driven width/height

--    width = aspectRatio > 1.5 and 320 or math.ceil( 480 / aspectRatio ),
--    height = aspectRatio < 1.5 and 480 or math.ceil( 320 * aspectRatio ),

-- Content for 1080p scale

    width = 800, -- these need to be backward for Lanscape as Corona thinks
    height = 1280, -- all devices are Portrait by default
--    width = aspectRatio > 1.5 and 720 or math.ceil( 1200 / aspectRatio ),
--    height = aspectRatio < 1.5 and 1200 or math.ceil( 720 * aspectRatio ),

--    The scaling method of the content area is determined by the scale value. If you
--    omit this (not recommended), the width and height values will be ignored and the
--    content area will be set to the device's actual pixel width and height.

--    "letterbox" — scales the content area to fill the screen while preserving the same aspect ratio. 
--    "zoomEven" — scales the content area to fill the screen while preserving the same aspect ratio. 
--    "adaptive" — instead of a static content area, a dynamic content width and height is chosen based on the device.
--    "zoomStretch" — scales the content area to fill the entire screen.   

    scale = "letterbox",

--    If you need to align the content area to a particular edge of the screen, you can use
--    the xAlign and yAlign values.       

--    By default, scaled content is centered on the screen. In letterbox scale mode, empty
--    screen area will be evenly divided between both sides. In zoomEven mode, the bleed
--    area will be cropped equally on both sides.

    xAlign = "center", -- Possible values are "left", "center", or "right".
    yAlign = "center", --Possible values are "top", "center", or "bottom".

--    The default frame rate is 30 frames per second, but you can set it to 60 frames per second 
--    by adding the fps key. Values other than 30 or 60 will be ignored.

    fps = 60,

--    local deviceScale = display.pixelWidth / display.actualContentWidth
--    This is the scale factor for the device. If the value on a particular device is greater
--    than or equal to the number you specify for the scale factor, Corona will use images
--    from that suffix set.

--    imageSuffix = {
--      ["@2x"] = 1.5
--      High-resolution devices (Retina iPad, Kindle Fire HD 9", Nexus 10, etc.) will use @2x-suffixed images.
--      Devices less than 1200 pixels in width (iPhone 5, iPad 2, Kindle Fire 7", etc.) will use non-suffixed images
--    },

--    This is used to override the default shader precision for all OpenGL ES shaders (on devices).
--    You should not specify this unless you absolutely require higher precision and see no performance
--    impact from setting it.

--    shaderPrecision = "highp", -- Acceptable values are "highp", "mediump", and "lowp".

  }, -- end of content

--    This global setting triggers pop-up error messages while running an app in the Simulator.
--    If you don't like this feature or if it doesn't fit your workflow, you can turn it off.

  --showRuntimeErrors = true,

--    The Corona licensing library lets you confirm that the app was bought from a store.
--    To implement licensing, the license table must be added to the application table of config.lua.

  license = {
    google = {
      key = "", -- required
      policy = "", -- optional
    },
  },
}

