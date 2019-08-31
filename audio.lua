
local source = {
  bgm1=love.audio.newSource("assets/sounds/bgm.ogg", "static"),
  bgm2=love.audio.newSource("assets/sounds/bgm2.ogg", "static"),
  died=love.audio.newSource("assets/sounds/died.ogg", "static"),

  brainwash=love.audio.newSource("assets/sounds/brainwash.ogg", "static"),
  chaos=love.audio.newSource("assets/sounds/chaos.ogg", "static"),
  death=love.audio.newSource("assets/sounds/death.ogg", "static"),

  hit=love.audio.newSource("assets/sounds/hit.ogg", "static"),
  magic=love.audio.newSource("assets/sounds/magic.ogg", "static"),
  sleep=love.audio.newSource("assets/sounds/sleep.ogg", "static"),

  stairs=love.audio.newSource("assets/sounds/stairs.ogg", "static"),
  teleport=love.audio.newSource("assets/sounds/teleport.ogg", "static"),
  up=love.audio.newSource("assets/sounds/up.ogg", "static"),

  walk=love.audio.newSource("assets/sounds/walk.ogg", "static"),
}

source.bgm1:setLooping(true)
source.bgm2:setLooping(true)

source.bgm1:setVolume(0.3)
source.bgm2:setVolume(0.3)
source.walk:setVolume(0.4)
source.up:setVolume(0.6)
source.hit:setVolume(0.6)

return {
  play = function (key)
    source[key]:stop()
    source[key]:play()
  end,

  source = source
}
