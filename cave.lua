local table2 = require "table2"
local quads = require "quads"


local block1Image = love.graphics.newImage("assets/sprites/block1.png")
local block2Image = love.graphics.newImage("assets/sprites/block2.png")
local floorImage = love.graphics.newImage("assets/sprites/floor.png")
local floorQuads = quads(floorImage, 8, 8)

local function create(w,h, num, walkable, threshold)
  num = num or 1
  w,h = h,w
  walkable = walkable or 0
  threshold = threshold or 40

  local dir = {
		{-1,-1}, --nw
		{0,-1}, --n
		{1,-1}, --ne
		{-1,0}, --w
		{1,0}, --e
		{-1,1}, --sw
		{0,1}, --s
		{1,1} --se
	}

	local map = {}
	for x = 1, w do
		map[x] = {}
		for y = 1, h do
			if math.random(0, 100) < threshold then
				map[x][y] = love.math.random(1, num)
			else
				map[x][y] = walkable
			end
		end
	end
	for i = 1, 4 do
		for x = 1, w do
			for y = 1,h do
				neighbors = 0
				for ii = 1,#dir do
					if map[x+dir[ii][1]] then
						if map[x+dir[ii][1]][y+dir[ii][2]] then
							if map[x+dir[ii][1]][y+dir[ii][2]] ~= walkable then
								neighbors = neighbors + 1
							end
						else
							neighbors = neighbors+1
						end
					else
						neighbors = neighbors+1
					end
				end
				if map[x][y] ~= walkable then
					if neighbors >= 3 then
						map[x][y] = love.math.random(1, num)
					else
						map[x][y] = walkable
					end
				elseif map[x][y] == walkable then
					if neighbors >= 6 then
						map[x][y] = love.math.random(1, num)
					else
						map[x][y] = walkable
					end
				end
			end
		end
	end
	for x = 1, w do
		for y = 1, h do
			if x == 1 or x == w or y == 1 or y == h then
				map[x][y] = love.math.random(1, num)
			end
		end
	end

	return map
end


local cave = {}

function cave:new(w, h)
  local _data = create(w, h)
  local pathfinder = require "jumper.pathfinder" (require "jumper.grid" (_data), 'ASTAR', 0)
  --pathfinder:setMode("ORTHOGONAL")
  return setmetatable({w=w, h=h, _data=_data, floor=create(w, h, 8, 1, 60), pathfinder=pathfinder}, {__index=self})
end

function cave:getEmptyAtRandom(ban)
  ban = ban or {}
  local d = self:data()
  for _,v in ipairs(ban) do d[v.y][v.x] = 2 end
	while true do
		local x, y = love.math.random(1, self.w), love.math.random(1, self.h)
		if d[y][x] == 0 then
			return x, y
		end
	end
end

function cave:isEmpty(x, y)
  if x < 1 or x > self.w then return false end
  if y < 1 or y > self.h then return false end

  return self._data[y][x] == 0
end

function cave:getPath(x0, y0, x1, y1)
  if x0 < 1 or x0 > self.w then return end
  if y0 < 1 or y0 > self.h then return end
  if x1 < 1 or x1 > self.w then return end
  if y1 < 1 or y1 > self.h then return end
  return self.pathfinder:getPath(x0, y0, x1, y1)
end

function cave:checkLink(x0, y0, x1, y1)
  if x0 < 1 or x0 > self.w then return false end
  if y0 < 1 or y0 > self.h then return false end
  if x1 < 1 or x1 > self.w then return false end
  if y1 < 1 or y1 > self.h then return false end
	return self:getPath(x0, y0, x1, y1) ~= nil
end

function cave:data()
  return table2.copy(self._data)
end

function cave:draw(pos)
  love.graphics.setColor(1, 1, 1)
  local fx, fy = pos(1,1)
  fx = (fx % 8) -8
  fy = (fy % 8) -8
	for x=0, 24 do
		for y=0, 24 do
      love.graphics.draw(block1Image, fx + x*8, fy+y*8)
    end
  end

	for x=1, self.w do
		for y=1, self.h do
      local px, py = pos(x, y)
      if self:isEmpty(x, y) then
        if self:isEmpty(x, y - 1) then
          love.graphics.draw(floorImage, floorQuads[self.floor[y][x]], px, py)
        else
          love.graphics.draw(block2Image, px, py)
        end
			else
        --love.graphics.draw(block1Image, px, py)
			end
		end
	end
end


function cave:isDiagonal (x0, y0, x1, y1)
  return math.abs(x0 - x1) == 1 and math.abs(y0 - y1) == 1
end
function cave:canWalkDiagonal (x0, y0, x1, y1)
	if math.abs(y0 - y1) == 1 and math.abs(x0 - x1) == 1 then
		return self:isEmpty(x0, y1) and self:isEmpty(x1, y0)
	end
	return false
end


return cave
