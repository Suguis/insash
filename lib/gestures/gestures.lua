gestures = {}
gestures.touches = {
  [1] = {id = nil, x = 0, y = 0},
  [2] = {id = nil, x = 0, y = 0},
}

function gestures:addTouch(id, x, y) -- Añade un touch al principio (baja el touch 1 al 2 y elimina el touch 2 ya que se sobreescribe)
  self.touches[2].id = self.touches[1].id
  self.touches[2].x = self.touches[1].x
  self.touches[2].y = self.touches[1].y

  self.touches[1].id = id
  self.touches[1].x = x
  self.touches[1].y = y
end

function gestures:removeTouch(id) -- Elimina un touch y deja al restante al principio de la lista
  for i = 1, #self.touches do
    if self.touches[i].id == id then
      self.touches[i] = {id = nil, x = 0, y = 0}
      if i == 1 then self.touches[i], self.touches[2] = self.touches[2], self.touches[i] end -- Si solo hey un touch se pone de primero
    end
  end
end

function gestures:updateTouches() -- Actualiza los touches
  for i, localTouch in ipairs(self.touches) do
    for j, id in ipairs(love.touch.getTouches()) do
      if localTouch.id == id then localTouch.x, localTouch.y = love.touch.getPosition(id) end
    end
  end
end

function gestures:getActiveTouches() -- Devuelve el número de touches activos
  return #love.touch.getTouches()
end

function gestures:getTouchesDistance(t1, t2) -- Devuelve la distancia entre dos touches
  return math.sqrt((self.touches[t2].x - self.touches[t1].x) ^ 2 + (self.touches[t2].y - self.touches[t1].y) ^ 2) -- SCALE
end

return gestures
