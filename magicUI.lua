local table2 = require "table2"

local image = love.graphics.newImage("assets/sprites/magic.png")
local quads = require "quads"(image, 8, 8)


local b_1 = love.graphics.newImage("assets/sprites/b_1.png")
local b_2 = love.graphics.newImage("assets/sprites/b_2.png")
local b_3 = love.graphics.newImage("assets/sprites/b_3.png")


return function(mp, maxMp, level)
  local i = 1

  for x=1, 2 do
    for y=13, 1, -1 do
      if mp >= i then
        love.graphics.draw(image, quads[3], 8 * x, 8 * y)
      elseif maxMp >= i then
        love.graphics.draw(image, quads[2], 8 * x, 8 * y)
      else
        love.graphics.draw(image, quads[1], 8 * x, 8 * y)
      end
      i = i+ 1
    end
  end

  for y=1, 24 do
  end

  love.graphics.draw(b_3, 32-5, 0, 0, 1, 24)
  love.graphics.draw(b_3, 0, 0, 0, 1, 24)

  love.graphics.draw(b_2, 0, 0, 0, 32 / 5, 1)
  love.graphics.draw(b_2, 0, 15*8 - 5, 0, 32 / 5, 1)

  love.graphics.draw(b_1, 32-5, 0)
  love.graphics.draw(b_1, 0, 0)
  love.graphics.draw(b_1, 0, 15*8 - 5)
  love.graphics.draw(b_1, 32-5, 15*8 - 5)


	local l_txt = "MP"--level.."F"
	love.graphics.setColor(68/255, 68/255, 41/255)
	love.graphics.rectangle("fill", 11, 1, #l_txt * 4 + 1, 6)
	love.graphics.setColor(1, 1, 1)
	love.graphics.print(l_txt, 1 + 11, 1)
end
