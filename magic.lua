local effect = require "effect"
local timer = require"timer"

local image_brainwash = love.graphics.newImage("assets/sprites/eff_brainwash.png")
local image_chaos = love.graphics.newImage("assets/sprites/eff_chaos.png")
local image_sleep = love.graphics.newImage("assets/sprites/eff_sleep.png")

local directions = {
  {-1,-1},
  {-1,0},
  {-1,1},

  {0,-1},
  {0,1},

  {1,-1},
  {1,0},
  {1,1},
}

local effectImage = {}
function effectImage:new(image, fromx, fromy, tox, toy)
  return setmetatable({image = image, fromx = fromx, fromy = fromy, x = fromx, y=fromy, tox= tox, toy = toy, timer=timer:new(1/60)}, {__index=self})
end

function effectImage:update(dt)
  if self.timer:executable(dt) then
    self.x = self.x + (self.tox - self.x) * 0.1
    self.y = self.y + (self.toy - self.y) * 0.1
  end
end

local function brainwash(player, cave, stairs, enemies)
  player.animKey = "walk"
  player.effectImages = {}
  for _,dir in ipairs(directions) do
    table.insert(player.effectImages, effectImage:new(image_brainwash, player.x, player.y, player.x + dir[1], player.y + dir[2]))
  end

  local t = timer:new(1.2)

  require "audio".play "brainwash"
  return function (dt)
    if t:executable(dt) then
      for _,enemy in ipairs(enemies) do
        if (enemy.x - player.x) * (enemy.x - player.x) + (enemy.y - player.y) * (enemy.y - player.y) <= 2 then
          enemy:setEffect(effect.brainwash)
        end
      end
      player.effectImages = {}
      return true
    end
    return false
  end
end

local function chaos(player, cave, stairs, enemies)
  player.animKey = "walk"
  player.effectImages = {}
  for _,dir in ipairs(directions) do
    table.insert(player.effectImages, effectImage:new(image_chaos, player.x, player.y, player.x + dir[1], player.y + dir[2]))
  end

  local t = timer:new(1.2)
  require "audio".play "chaos"

  return function (dt)
    if t:executable(dt) then
      for _,enemy in ipairs(enemies) do
        if (enemy.x - player.x) * (enemy.x - player.x) + (enemy.y - player.y) * (enemy.y - player.y) <= 2 then
          enemy:setEffect(effect.chaos)
        end
      end
      player.effectImages = {}
      return true
    end
    return false
  end
end

local function sleep(player, cave, stairs, enemies)
  player.animKey = "walk"
  player.effectImages = {}
  for _,dir in ipairs(directions) do
    table.insert(player.effectImages, effectImage:new(image_sleep, player.x, player.y, player.x + dir[1], player.y + dir[2]))
  end

  local t = timer:new(1.2)
  require "audio".play "sleep"

  return function (dt)
    if t:executable(dt) then
      for _,enemy in ipairs(enemies) do
        if (enemy.x - player.x) * (enemy.x - player.x) + (enemy.y - player.y) * (enemy.y - player.y) <= 2 then
          enemy:setEffect(effect.sleep)
        end
      end
      player.effectImages = {}
      return true
    end
    return false
  end
end

local function teleport(player, cave, stairs, enemies)
  player.animKey = "teleport1"
  player.anim[player.animKey]:gotoFrame(2)

  require "audio".play "teleport"
  return function (dt)
    if player.animKey == "teleport1" then
      if player.anim[player.animKey].position == 1 then
        player.animKey = "teleport2"
        player.anim[player.animKey]:gotoFrame(2)
        require "audio".play "teleport"

      	if love.math.random(1, 3) == 1 then
      		player.x, player.y = love.math.random(1, cave.w), love.math.random(1, cave.h)
      	else
      		player.x, player.y = cave:getEmptyAtRandom()
      	end
      end
    elseif player.animKey == "teleport2" then
      if player.anim[player.animKey].position == 1 then
        player.animKey = "walk"
        return true
      end
    end
    return false
  end
end

local function perfectTeleport(player, cave, stairs, enemies)
  player.animKey = "teleport1"
  player.anim[player.animKey]:gotoFrame(2)
  require "audio".play "teleport"
  return function (dt)
    if player.animKey == "teleport1" then
      if player.anim[player.animKey].position == 1 then
        player.animKey = "teleport2"
        player.anim[player.animKey]:gotoFrame(2)
    	  player.x, player.y = cave:getEmptyAtRandom(enemies)
        require "audio".play "teleport"
       end
    elseif player.animKey == "teleport2" then
      if player.anim[player.animKey].position == 1 then
        player.animKey = "walk"
        return true
      end
    end
    return false
  end
end

return {
	{mp=3, name= "   Telepo", func=teleport},
	{mp=6, name= "    Chaos", func=chaos},
	{mp=10, name=" Telepo 2", func=perfectTeleport},
	{mp=14, name="Brainwash", func=brainwash},
	{mp=18, name="    Sleep", func=sleep}
}
