local table2 = require "table2"
local magic = require "magic"

local fonts = require "fonts"
return function(mp, maxMp)
  local dy = math.floor(math.cos(love.timer.getTime() * math.pi /1.875 *4))
  love.graphics.clear()

  for i, m in ipairs(magic) do
    local str
    if m.mp <= maxMp then
      -- acquire
      love.graphics.setFont(fonts.white)
    else
      -- not acquire
      love.graphics.setFont(fonts.darkgray)
    end

    str = " "..m.name

    for i=1, 18 do
      if i <= m.mp then
        if i <= mp then
          -- full
          str = "@"..str
        else
          -- empty
          str = "%"..str
        end
      else
        -- space
        str = "&"..str
      end
    end
    love.graphics.print(str, 2, (i-1)*6 + 2)

    if m.mp <= mp then
      love.graphics.print(i.."key", 135, (i-1)*6 + 2 + dy)
    end
  end

  love.graphics.setFont(fonts.white)

end
