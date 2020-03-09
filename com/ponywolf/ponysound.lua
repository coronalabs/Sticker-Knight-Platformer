-- Ponysound

-- Manages sound and music playback with the ability
-- to randomly mix sounds or round-robin random sounds

local M = {}

M.sounds = {}
M.volume = 1
M.enabled = true
M.musicVolume = 1
M.musicChannel = 1 -- one for music
M.lastMusic = ""
audio.reserveChannels(1)

M.path = "snd/"
M.ext = ".wav"

local defaultVolume = 0.333
local defaultMusicVolume = 1.0

function M:add(name, path, ext)
  path = path or (M.path .. name .. (ext or M.ext))
  self.sounds[name] = audio.loadSound(path, system.ResourceDirectory)
end

function M:batch(...)
  for i = 1, #arg do 
    local name = arg[i]
    local path = M.path .. name .. M.ext
    self.sounds[name] = audio.loadSound(path, system.ResourceDirectory)
  end
end

function M:remove(name)
  if not self.sounds or not self.sounds[name] then
    return
  end
  if self.sounds[name] then
    audio.dispose(self.sounds[name])
  end
  self.sounds[name] = nil
end

function M:play(name, delay, volume)
  if not self.sounds or not self.sounds[name] or not self.enabled then
    return
  end
  timer.performWithDelay(delay or 0, function ()
      local channel = audio.play(self.sounds[name])
      audio.setVolume(volume or self.volume, {channel = channel}) 
    end)
end

function M:mix(...)
  local mixVol = {}
  local maxVol = 0
  for i = 1, #arg do
    mixVol[i] = math.random()
    maxVol = maxVol + mixVol[i]
  end
  for i = 1, #arg do
    mixVol[i] = mixVol[i] / maxVol
  end
  for i = 1, #arg do
    self:play(arg[i], nil, mixVol[i])
  end
end

function M:rnd(...)
  if #arg > 0 then
    self:play(arg[math.random(#arg)])
  end
end

function M:setVolume(volume)
  self.volume = math.max(math.min(volume or 0,1),0)
  --print ("Setting volume to", self.volume)
  audio.setVolume(self.volume)
end

function M:getVolume()
  return self.volume
end


function M:toggleVolume()
  if M.volume > 0 then 
    defaultVolume = M.volume
    defaultMusicVolume = M.musicVolume
    self:setVolume(0)
    self:setMusicVolume(0)
  else
    self:setVolume(defaultVolume)
    self:setMusicVolume(defaultMusicVolume)
  end
  return M.volume
end

function M:panic() 
  audio.stop()
end

function M:disposeAll()
  self:panic()
  for _, v in pairs(self.sounds) do
    if v then
      audio.dispose(v)
    end
    v = nil
  end
  self.sounds = {}
end

function M:loadMusic(musicFile)
  M.music = audio.loadStream(musicFile)
  M.musicPaused = true
end

function M:playMusic(options)
  options = options or {
    channel=M.musicChannel,
    loops=-1,
    fadein=0}
  options.channel=M.musicChannel
  if M.music then
    audio.play(M.music, options)
  end
end

function M:setMusicVolume(volume)
  self.musicVolume = math.max(math.min(volume or 0,1),0)
  audio.setVolume(self.musicVolume, {channel=M.musicChannel})
end

function M:pauseMusic()
  audio.pause(M.musicChannel)
  M.musicPaused = true
end

function M:resumeMusic()
  audio.resume(M.musicChannel)
  M.musicPaused = false
end

function M:toggleMusic()
  if M.musicPaused then
    M:resumeMusic()
  elseif  M.musicPaused == nil then
    M:playMusic()
  else
    M:pauseMusic()
  end
  M.musicPaused = not M.musicPaused
end

function M:resumeMusic()
  audio.resume(M.musicChannel)
end

function M:stopMusic(time)
  if M.timer then
    timer.cancel(M.timer)
  end
  local function dispose()
    audio.stop(M.musicChannel)
    audio.dispose(M.music)
    M.music = nil    
    M.timer = nil
  end
  if M.music then
    if not time then
      M.timer = timer.performWithDelay(1, dispose)
    else
      audio.fadeOut({channel=M.musicChannel, time=time})
      M.timer = timer.performWithDelay(time + 1, dispose)
    end
  end
end

function M:switchMusic(musicFile, delay)
  if self.lastMusic == musicFile then return false end
  delay = tonumber(delay or 0)
  local function dispose()
    audio.stop(M.musicChannel)
    audio.dispose(M.music)
    M.music = nil    
    M.timer = nil
    M:loadMusic(musicFile)
    M:playMusic()
  end
  if M.music then
    if M.timer then
      timer.cancel(M.timer)
    end
    if delay > 0 then
      M.timer = timer.performWithDelay(16, dispose)
    else
      audio.fadeOut({channel=M.musicChannel, time=delay})
      M.timer = timer.performWithDelay(delay + 16, dispose)
    end
  else
    M:loadMusic(musicFile)
    M:playMusic()
  end
  self.lastMusic = musicFile
end

function M:destroy()
  if M.timer then
    timer.cancel(M.timer)
  end
  self:panic()
  self:disposeAll()
  self.sounds = nil
end

return M