local effect = require "effect"
local anim8 = require "anim8"
local timer = require "timer"

local imageNames = {
  dying="e_dying.png",
  died="e_died.png",
  chaos="e_chaos.png",
  sleep="e_sleep.png",
  brainwash="e_brainwash.png",
  walk="e_walk.png",
}

local images = {}
local grids = {}

for key, name in pairs(imageNames) do
  images[key] = love.graphics.newImage("assets/sprites/"..name)
  grids[key] = anim8.newGrid(8, 8, images[key]:getWidth(), images[key]:getHeight())
end


local enemy = {}

function enemy:new(x, y)

  local anim = {
    dying=anim8.newAnimation(grids.dying("1-8",1, "1-3",2), 1.875/4/4),
    died=anim8.newAnimation(grids.died(1,1, 1,1), 100),
    chaos=anim8.newAnimation(grids.chaos("1-8",1), 1.875/4/4),
    sleep=anim8.newAnimation(grids.sleep("4-8",1, "1-8",2,"1-8",3, "1-8",4), 1.875/4/4),
    brainwash=anim8.newAnimation(grids.brainwash("1-8",1), 1.875/4/4),
    walk=anim8.newAnimation(grids.walk("1-8", 1), 1.875/4/4),
  }

  return setmetatable({ox=0, oy=0, x=x, y=y, isDead = false, effect=effect.none, anim=anim, animKey="walk"}, {__index=self})
end

function getEnemyAtRandom(enemies, e0)
  if #enemies < 2 then return end

  while true do
    local e1 = enemies[love.math.random(1, #enemies)]
    if e0 ~= e1 then
      return e1
    end
  end
end

function enemy:isMoving()
  return self.moveTimer ~= nil
end

function enemy:move(cave, x, y)
  if cave:isEmpty(x, y) then
  self.ox = -(x - self.x) * 8
  self.oy = -(y - self.y) * 8
    self.x = x
    self.y = y

    self.moveTimer = timer:new(1/60)
  end
end

function enemy:setEffect(value)
  self.effect = value

  if self.isDead then
  elseif self.effect == effect.brainwash then
    self.animKey = "brainwash"
  elseif self.effect == effect.sleep then
    self.animKey = "sleep"
  elseif self.effect == effect.chaos then
    self.animKey = "chaos"
  else
    self.animKey = "walk"
  end
end

function enemy:moveToTarget(cave, targetX, targetY)

  local path = cave:getPath(self.x, self.y, targetX, targetY)
  if path == nil then return end

  local nodes = {}
  for node, count in path:nodes() do
    table.insert(nodes, node)
    if #nodes == 2 then break end
  end

  if #nodes <= 1 then return end

  if math.abs(nodes[1].x - nodes[2].x) == 1 and math.abs(nodes[1].y - nodes[2].y) == 1 then
    if not cave:canWalkDiagonal(nodes[1].x, nodes[1].y, nodes[2].x, nodes[2].y) then
      if cave:isEmpty(nodes[2].x, nodes[1].y) then
        self:move(cave, nodes[2].x, nodes[1].y)
      else
        self:move(cave, nodes[1].x, nodes[2].y)
      end
      return
    end
  end
  self:move(cave, nodes[2].x, nodes[2].y)
end

function enemy:update(dt)
  self.anim[self.animKey]:update(dt)

  if self.moveTimer then
    if self.moveTimer:executable(dt) then
      if self.ox < 0 then self.ox = self.ox + 1 end
      if self.oy < 0 then self.oy = self.oy + 1 end

      if self.ox > 0 then self.ox = self.ox - 1 end
      if self.oy > 0 then self.oy = self.oy - 1 end

      if self.ox == 0 and self.oy == 0 then self.moveTimer = nil end
    end
  end
end

function enemy:prePhase(cave, player, enemies)
  if self.isDead then
  else
    if self.effect == effect.brainwash then
      if self.targetEnemy == nil then
        self.targetEnemy = getEnemyAtRandom(enemies, self)
      end

      if self.targetEnemy ~= nil then
        self:moveToTarget(cave, self.targetEnemy.x, self.targetEnemy.y)
      end

    elseif self.effect == effect.sleep then

    elseif self.effect == effect.chaos then
      local dx, dy = love.math.random(-1, 1), love.math.random(-1, 1)
      if cave:isDiagonal(self.x, self.y, self.x + dx, self.y + dy) then
        if cave:canWalkDiagonal(self.x, self.y, self.x + dx, self.y + dy) then
          self:move(cave, self.x + dx, self.y + dy)
        end
      else
        self:move(cave, self.x + dx, self.y + dy)
      end
    elseif self.effect == effect.none then
      self:moveToTarget(cave, player.x, player.y)
    end
  end
end

function enemy:phase(dt, cave, player, enemies)
  for _, e in ipairs(enemies) do
    if self ~= e then
      if self.x == e.x and self.y == e.y then
        if not self.isDead then
          player:upMaxMp()
          --self.isDead = true
          self:dying()
        end
        if not e.isDead then
          player:upMaxMp()
          --e.isDead = true
          e:dying()
        end
      end
    end
  end
end

function enemy:dying()
  self.isDead = true
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

function enemy:draw(pos)
  local x, y = pos(self.x, self.y)
  love.graphics.setColor(1, 1, 1)
  self.anim[self.animKey]:draw(images[self.animKey], x + self.ox, y + self.oy)
end

return enemy
