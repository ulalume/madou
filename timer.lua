local Timer={}
function Timer:new(time,limit)
  return setmetatable({
      time=time,
      limit=limit,
      count=0,
      now=0
    },{__index=self})
end

function Timer:reset()
  self.count=0
  self.now=0
end

function Timer:isLimit()
  if self.limit ~= nil then
    if self.count >= self.limit then
      return true
    end
  end
  return false
end
function Timer:executable(dt)
  if self:isLimit() then
    return false
  end

  self.now = self.now + dt
  if self.now > self.time then
    self.now = self.now - self.time
    self.count = self.count+1
    return true
  end
  return false
end

return Timer
