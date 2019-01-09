local player = {
  x = nil,
  y = nil,
  dy = nil, -- Draw x
  dx = nil, -- Draw y
}

function player:draw()
  -- Aura
  love.graphics.setColor(1, 1, 1, 1 - mymath.sinRange(TIME, .25, .75))
  love.graphics.circle("fill", self.dx + TILESIZE / 2, self.dy + TILESIZE / 2, mymath.sinRange(TIME, TILESIZE / 4, TILESIZE), 100) -- El seno va de 0.25 a 0.5
  -- Jugador
  love.graphics.setColor(mymath.hsv(mymath.nsin(TIME/5), 1, 1, 1))
  love.graphics.circle("fill", self.dx + TILESIZE / 2, self.dy + TILESIZE / 2,  mymath.sinRange(TIME / 2, TILESIZE / 8, TILESIZE / 4), 50)
  love.graphics.setColor(1, 1, 1)
end

function player:update(dt)
end

function player:set(x, y)
  self.x = x
  self.y = y
  self.dx = x * TILESIZE
  self.dy = y * TILESIZE - 2
end

return player
