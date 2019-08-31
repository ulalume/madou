local timer = require "timer"

local key = {}


function key:new(name, repeatTime)
  local t
  if repeatTime ~= nil then t = timer:new(repeatTime) end

  return setmetatable({name=name,
    prev = love.keyboard.isDown(name),
    now = love.keyboard.isDown(name),
    repeatTimer = t,
    repeatExecuted = false}, {__index=self})
end

function key:update(dt)
  self.prev = self.now
  self.now = love.keyboard.isDown(self.name)
  if self.repeatTimer then
    if self.prev and self.now then
      self.repeatExecuted = self.repeatTimer:executable(dt)
    else
      self.repeatTimer:reset()
      self.repeatExecuted = false
    end
  end
end

function key:isDown()
  return self.now
end

function key:isDownNow()
  return self.now and not self.prev
end
function key:isRelease()
  return not self.now and self.prev
end
function key:isRepeat()
  return self.repeatExecuted
end
function key:isDowner()
  return self:isRepeat() or self:isDownNow()
end

return key
