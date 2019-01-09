local way = {}
way.active = false
way.nodes = {}
way.drawNodes = {}
way.mousePos = {}

-- Establecemos el diseño del way:
love.graphics.setLineJoin("none")
love.graphics.setLineStyle("smooth")
love.graphics.setLineWidth(2)

function way:draw(r, g, b, a)
  local nodes = mytable.merge(self.drawNodes, self.mousePos)
  love.graphics.setColor(r, g, b, a)
  love.graphics.line(nodes)
  -- Se restablece el color que estaba antes
  love.graphics.setColor(1, 1, 1, 1)
end

function way:addNode(x, y)
  local vFix = TILESIZE / 16 -- Para que se centren verticalmente
  -- Al añadir los nodos, para que al dibujar el way queden centrados, se añaden en el centro de zona
  table.insert(self.drawNodes, TILESIZE * (x + 0.5))
  table.insert(self.drawNodes, TILESIZE * (y + 0.5) - vFix)

  table.insert(self.nodes, x)
  table.insert(self.nodes, y)
end

-- Se introducen los nodos correspondientes al mouse para actualizarlos
function way:updateMouse(x, y)
  self.mousePos = {x, y}
end

-- Devuelve true si el way se puede conectar al nodo, y false si no puede (sea porque no es válido o porque ya está usándose)
function way:nodeAvaliable(x, y)
  if not self:validNode(x, y) then return false end
  if not self:locateNode(x, y) then return true end
end

-- Comprueba que el nodo a comprobar sea contiguo al último, que exista en el nivel y que su casilla no esté gastada
function way:validNode(x, y)
  if #self.nodes == 0 then return true end
  local grid = lm:getGrid()
  if lm:cellExists(x + 1, y + 1) and
  tm:areWalkable(lm:getIDs(x + 1, y + 1)) and
  math.abs(self.nodes[#self.nodes - 1] - x) + math.abs(self.nodes[#self.nodes] - y) <= 1 then return true end
end

function way:locateNode(x, y)
  for i = 1, #self.nodes, 2 do
    if x == self.nodes[i] and y == self.nodes[i + 1] then return true end
  end
  return false
end

function way:removeLastNode(x, y)
  for i = 1, 2 do
    self.nodes[#self.nodes] = nil
    self.drawNodes[#self.drawNodes] = nil
  end
end

function way:getLastNode()
  return self.nodes[#self.nodes - 1], self.nodes[#self.nodes]
end

function way:reset()
  self.nodes = {}
  self.drawNodes = {}
end

function way:enable()
  self.active = true
end

function way:disable()
  self.active = false
end

function way:isActive()
  return self.active
end

return way
