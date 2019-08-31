local key = require "key"
local state = require "state"
local table2 = require "table2"
local magic = require "magic"

local timer = require "timer"

local anim8 = require "anim8"

local MAX_MP = 26

local imageNames = {
  dying="p_dying.png",
  died="p_died.png",
  magic="p_magic.png",
  teleport1="p_teleport1.png",
  teleport2="p_teleport2.png",
  walk="p_walk.png",
}
local images = {}
local grids = {}

for key, name in pairs(imageNames) do
  images[key] = love.graphics.newImage("assets/sprites/"..name)
  grids[key] = anim8.newGrid(8, 8, images[key]:getWidth(), images[key]:getHeight())
end


local directions ={
  left = {-1, 0},
  up = {0, -1},
  down = {0, 1},
  right = {1, 0},
}

local moveKeys = {
	left=key:new("left"),
	up=key:new("up"),
	down=key:new("down"),
	right=key:new("right"),
}
local move2Keys = {
	left=key:new("a"),
	up=key:new("w"),
	down=key:new("s"),
	right=key:new("d"),
}
local magicKeys = {
	num1=key:new("1"),
	num2=key:new("2"),
	num3=key:new("3"),
	num4=key:new("4"),
	num5=key:new("5"),
}

local magics= {
	num1=magic[1],
	num2=magic[2],
	num3=magic[3],
	num4=magic[4],
	num5=magic[5],
}


local player = {}

function player:new(x, y, mp, maxMp)
  local anim = {
    dying=anim8.newAnimation(grids.dying("1-8",1, "1-3",2), 1.875/4/4),
    died=anim8.newAnimation(grids.died(1,1, 1,1), 100),
    magic=anim8.newAnimation(grids.magic("1-8",1, "1-7",2), 1.875/4/4/2),
    teleport1=anim8.newAnimation(grids.teleport1("1-8",1, "1-8",2), 1.875/4/4/2),
    teleport2=anim8.newAnimation(grids.teleport2("1-8",1, "1-5",2), 1.875/4/4/2),
    walk=anim8.newAnimation(grids.walk("1-4", 1), 1.875/4/4),
  }

  local p =  setmetatable({
    T = 0,
    ox=0,oy=0,
    x=x or 0, y=y or 0,
    effectImages = {},
    anim=anim, animKey="walk"}, {__index=self})

  p:reset()
  return p
end

function player:update(dt)
  self.T = self.T + dt
  self.anim[self.animKey]:update(dt)
  for _,k in pairs(moveKeys) do
    k:update(dt)
  end
  for _,k in pairs(move2Keys) do
    k:update(dt)
  end
  for _,k in pairs(magicKeys) do
    k:update(dt)
  end
  for _,k in ipairs(self.effectImages) do
    k:update(dt)
  end

end

function player:reset()
	self.mp = 0
	self.maxMp = 4
  self.animKey = "walk"
end

function player:upMaxMp()


  self.maxMp = self.maxMp + 1

  for _,m in ipairs(magic) do
    if self.maxMp == m.mp then
      require "audio".play "up"
    end
  end
end

function player:phase(dt, cave, stairs, enemies)
  local stt

  if self.animKey == "magic" then
    if self.anim[self.animKey].position == 1 then
      self.magicEffect = self.magic.func(self, cave, stairs, enemies)
      stt = state.enemy
    else
      return state.player
    end
  end

  if self.magicEffect ~= nil then
    local complete = self.magicEffect(dt)
    if complete then
      self.magicEffect = nil
      self.animKey = "walk"
      stt = state.enemy
    else
      return state.player
    end
  end

  if self.moveTimer then
    if self.moveTimer:executable(dt) then
      self.ox = self.ox + self.dir[1]
      self.oy = self.oy + self.dir[2]

      if math.abs(self.ox) == 8 or math.abs(self.oy) == 8 then

        self.x = self.x + self.dir[1]
        self.y = self.y + self.dir[2]
        self.ox, self.oy = 0, 0

        self.moveTimer = nil

        stt = state.enemy
      end
    end

    if stt ~= nil then
      self.mp = math.min(self.maxMp, self.mp + 1, MAX_MP)
    else
      return state.player
    end
  end

  if self.wallTimer then
    if self.wallTimer:executable(dt) then
      if self.ox < 0 then self.ox = self.ox + 1 end
      if self.oy < 0 then self.oy = self.oy + 1 end

      if self.ox > 0 then self.ox = self.ox - 1 end
      if self.oy > 0 then self.oy = self.oy - 1 end

      if self.ox == 0 and self.oy == 0 then self.wallTimer = nil end
    end
    return state.player
  end

  local downMoveKey = false
  local mmm = function (s, k)
    if not downMoveKey and k:isDowner() then

      if cave:isEmpty(self.x + directions[s][1], self.y + directions[s][2]) then
        require "audio".play "walk"

        self.dir = directions[s]
        self.moveTimer = timer:new(1/60)
        downMoveKey = true
      else
        require "audio".play "hit"
        self.ox = directions[s][1] * 2
        self.oy = directions[s][2] * 2
        self.wallTimer = timer:new(1/60)
        downMoveKey = true
      end
    end
  end
  -- move
	for s, k in pairs(moveKeys) do mmm(s, k) end
	for s, k in pairs(move2Keys) do mmm(s, k) end

  -- magic
  if stt == nil then
    for s, k in pairs(magicKeys) do
      if k:isDowner() then
        local mag = magics[s]
      	if self.mp >= mag.mp then
          self.magic = mag
          self.animKey = "magic"
          self.anim[self.animKey]:gotoFrame(2)

          require "audio".play "magic"

          self.mp = self.mp - mag.mp

          break
        end
      end
    end
  end

  -- cave
  if not cave:isEmpty(self.x, self.y) then
    stt = state.gameover
  end

	if stairs.x == self.x and stairs.y == self.y then
    -- stairs
    require "audio".play "stairs"
		stt = state.levelchange
	else
    -- enemy
    for _, enemy in ipairs(enemies) do
      if enemy.x == self.x and enemy.y == self.y then
        stt = state.gameover
      end
    end
  end

  return stt or state.player
end

function player:draw(pos)
  local x, y = pos(self.x, self.y)
  love.graphics.setColor(1, 1, 1)
  self.anim[self.animKey]:draw(images[self.animKey], x + self.ox, y + self.oy)
  if math.floor(self.T * 200) % 2 == 0 then
    for _,ei in ipairs(self.effectImages) do
      local x, y = pos(ei.x, ei.y)
      love.graphics.draw(ei.image, x, y)
    end
  end
end

function player:dying ()
  if self.animKey ~= "dying" and self.animKey ~= "died" then
    require "audio".play "died"
	  self.animKey = "dying"
	  self.anim[self.animKey]:gotoFrame(1)

    self.anim[self.animKey].onLoop = function ()
      self.anim[self.animKey].onLoop = nil
      self.animKey = "died"
    end
  end
end



return player
