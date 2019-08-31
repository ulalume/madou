
return function (image, w, h)
  local quads = {}
  local imageW, imageH = image:getWidth(), image:getHeight()
  local i = 0
  for y=0, imageH-1, h do
    for x=0, imageW-1, w do
      table.insert(quads, love.graphics.newQuad(x, y, w, h, image:getDimensions()))
      i = i + 1
    end
  end

  return quads
end
