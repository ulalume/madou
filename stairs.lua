
local stairs = {}
local image = love.graphics.newImage("assets/sprites/stairs.png")


function stairs:new(x, y)
  return setmetatable({x=x, y=y}, {__index=self})
end

function stairs:draw(pos)
  love.graphics.setColor(1, 1, 1)
  local x, y = pos(self.x, self.y)
  love.graphics.draw(image, x, y)
end

return stairs
