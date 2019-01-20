local lm = {}
lm.levels = {
  relax = {
    [1] = require "levels.relax1",
    [2] = require "levels.relax2",
    [3] = require "levels.relax3",
    [4] = require "levels.relax4",
    [5] = require "levels.relax5",
    [6] = require "levels.relax6",
    [7] = require "levels.relax7",
    [8] = require "levels.relax8",
    [9] = require "levels.relax9",
    [10] = require "levels.relax10",
    [11] = require "levels.relax11",
    [12] = require "levels.relax12",
    [13] = require "levels.relax13",
    [14] = require "levels.relax14",
    [15] = require "levels.relax15",
    [16] = require "levels.relax16",
    [17] = require "levels.relax17",
    [18] = require "levels.relax18",
    [19] = require "levels.relax19",
  }
}

-- Generacio

function lm:get()
  return self.currLev
end

function lm:getMessage()
  return self.levels[self.currMode][self.currLev].message
end

function lm:getMode()
  return self.currMode
end

function lm:getMoves() -- Devuelve el número de movimientos hechos en el nivel
  return self.moves
end

function lm:getRange(num, mode, moves)
  if moves <= self.levels[mode][num].moves[1] then
    if moves ~= self.levels[mode][num].moves[1] then
      print("Move number not correct on level #" .. num)
    end
    return "purple"
  elseif moves <= self.levels[mode][num].moves[2] then
    return "gold"
  end
  return "white"
end

function lm:getTotalLevels(mode)
  return #self.levels[mode]
end

function lm:set(num, mode)
  mode = mode or self.currMode
  if type(mode) ~= "string" then error("mode parameter must be a string", 2) end
  if type(num) ~= "number" then error("level parameter must be a number", 2) end
  if not self.levels[mode][num] then return false end -- Indica que el nivel especificado no existe
  self.currMode = mode
  self.currLev = num
  self.moves = 0
  self:resetGrid(num, mode)
  player:set(self.levels[mode][num].init.x, self.levels[mode][num].init.y)
  return true -- Indica que no hubo problemas en cargar el nivel especificado
end

function lm:draw(num)
  -- Dibuja el nivel del número que se le indique
  for i = 1, #self.currGrid do
    for j = 1, #self.currGrid[i] do
      tm:drawTile(self.currGrid[i][j], (j - 1) * TILESIZE, (i - 1) * TILESIZE) -- Ojo con el intercambio de i y j
    end
  end
end

function lm:getGrid()
  return self.currGrid
end

function lm:resetGrid(num, mode) -- Se hace una copia de la grilla original del nivel para pasar al LM (ya que si se iguala se edita la original)
  self.currGrid = {}
  for i = 1, #self.levels[mode][num].layout[1] do -- Filas
    self.currGrid[i] = {}
    for j = 1, #self.levels[mode][num].layout[1][i] do -- Columnas
      self.currGrid[i][j] = {}
      for k = 1, #self.levels[mode][num].layout do -- Capas
        table.insert(self.currGrid[i][j], self.levels[mode][num].layout[k][i][j])
      end
    end
  end
end

function lm:cellExists(x, y)
  return self.currGrid[y] and self.currGrid[y][x]
end

function lm:getIDs(x, y, grid) -- Coge los IDs de las capas de la casilla
  grid = grid or self.currGrid
  return grid[y][x]
end

-- Aplica los movimientos del jugador al nivel, es decir, "gasta" las casillas por las que pasó
function lm:applyNodes(nodes)
  self.moves = self.moves + 1
  local x; local y
  local currLev = lm:get()
  for i = 3, #nodes - 1, 2 do
    x = way.nodes[i + 1] + 1; y = way.nodes[i] + 1
    for z = 1, #self.currGrid[x][y] do -- Itera según las capas de la tabla
      if self.currGrid[x][y][z] > 0 then
        tm.tiles[self.currGrid[x][y][z]].onOver(self.currGrid, x, y, z, mode)
        if currLev ~= lm:get() then return end -- Si al ir activando las casillas hay alguna que haga pasar de nivel, se detiene la activación de casillas
      end
    end
  end
end

function lm:remainingCells(grid)
  grid = grid or self.currGrid
  for i = 1, #grid do
    for j = 1, #grid[i] do
      for k = 1, #grid[i][j] do
        if grid[i][j][k] > 0 and grid[i][j][k] < 5 then return true end
      end
    end
  end
end

return lm
