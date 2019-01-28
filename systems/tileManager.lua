local tm = {}

local draw = function(id, x, y) -- Función que dibuja cada tile
  if tm.tiles[id].sprite then love.graphics.draw(SPRITES.atlas, tm.tiles[id].sprite.quad , x, y, 0, TILESIZE / tm.tiles[id].sprite.w, TILESIZE / tm.tiles[id].sprite.h) end
end

tm.tiles = {
  [1] = {
    sprite = (function() local t = {}
      t.quad = SPRITES.cell1
      t.x, t.y, t.w, t.h = t.quad:getViewport()
      return t end)(),
    onOver = function(grid, x, y, z, mode)
      for i = 1, #grid[x][y] do
        grid[x][y][i] = 0
      end
    end,
    onDraw = function(x, y) draw(1, x, y) end,
    onPostZDraw = function(x, y) end,
    walkable = true,
  },

  [2] = {
    sprite = (function() local t = {}
      t.quad = SPRITES.cell2
      t.x, t.y, t.w, t.h = t.quad:getViewport()
      return t end)(),
    onOver = function(grid, x, y, z, mode) grid[x][y][z] = 1 end,
    onDraw = function(x, y) draw(2, x, y) end,
    onPostZDraw = function(x, y) end,
    walkable = true,
  },

  [3] = {
    sprite = (function() local t = {}
      t.quad = SPRITES.cell3
      t.x, t.y, t.w, t.h = t.quad:getViewport()
      return t end)(),
    onOver = function(grid, x, y, z, mode) grid[x][y][z] = 2 end,
    onDraw = function(x, y) draw(3, x, y) end,
    onPostZDraw = function(x, y) end,
    walkable = true,
  },

  [4] = {
    sprite = (function() local t = {}
      t.quad = SPRITES.cell4
      t.x, t.y, t.w, t.h = t.quad:getViewport()
      return t end)(),
    onOver = function(grid, x, y, z, mode) grid[x][y][z] = 3 end,
    onDraw = function(x, y) draw(4, x, y) end,
    onPostZDraw = function(x, y) end,
    walkable = true,
  },

  [5] = { -- Celda final
    sprite = (function() local t = {}
      t.quad = SPRITES.goalCell
      t.x, t.y, t.w, t.h = t.quad:getViewport()
      return t end)(),
    onOver = function(grid, x, y, z, mode)
      if not lm:remainingCells() then -- Si no quedan celdas que pisar
        if BGM2:isPlaying() then BGM2:stop(); BGM:play() end
        savm:manageLevelMoves(SAVEDATA, lm:getMoves(), lm:get(), lm:getMode()) -- Se aumenta el número de niveles completados
        savm:save(SAVEDATA) -- Se guardan los datos
        wins:show(lm:getMoves(), lm:getRange(lm:get(), lm:getMode(), lm:getMoves())) -- Se muestra el winstate
        if lm:get() + 1 > lm:getTotalLevels(mode) or (lm:isLastLevel(lm:get() + 1, mode) and not lm:isFinalLevelPlayable(mode)) then -- Si no existe el nivel siguiente se vuelve a la pantalla de inicio
          sm:set("levelSelection", "relax", lm:getTotalLevels(mode), savm:getCompletedLevels(SAVEDATA, mode))
        else
          lm:set(lm:get() + 1)
          sm:get():init()
        end
      end
    end,
    onDraw = function(x, y)
      love.graphics.setColor(mymath.hsv(0, 0, (mymath.nsin(TIME * 2) + 1) / 2, 1))
      draw(5, x, y)
      love.graphics.setColor(1, 1, 1, 1)
    end,
    onPostZDraw = function(x, y) end,
    walkable = true,
  },

  [6] = { -- Celda inmortal
    sprite = (function() local t = {}
      t.quad = SPRITES.greyCell
      t.x, t.y, t.w, t.h = t.quad:getViewport()
      return t end)(),
    onOver = function(grid, x, y, z, mode) end,
    onDraw = function(x, y) draw(6, x, y) end,
    onPostZDraw = function(x, y) end,
    walkable = true,
  },

  [7] = { -- Interruptor cerrado
    sprite = (function()
      local canvas = love.graphics.newCanvas(256, 256)
      canvas:renderTo(function()
        love.graphics.setColor(.3, .3, .3, .3)
        love.graphics.circle("fill", canvas:getWidth() / 2,  canvas:getHeight() / 2,  canvas:getWidth() / 8, 30)
        love.graphics.setColor(1, 1, 1, 1)
      end)
      return canvas
    end)(),
    onOver = function(grid, x, y, z, mode)
      for i = 1, #grid do
        for j = 1, #grid[i] do
          for k = 1, #grid[i][j] do
            if grid[i][j][k] == 9 then grid[i][j][k] = 10 end -- Activa las puertas
          end
        end
      end
      grid[x][y][z] = 8
    end,
    onDraw = function(x, y) end,
    onPostZDraw = function(x, y) draw(7, x, y - 2) end,
    walkable = true,
  },

  [8] = {
    sprite = (function() -- Interruptor abierto
      local canvas = love.graphics.newCanvas(256, 256)
      canvas:renderTo(function()
        love.graphics.setColor(.7, .7, .7, 1)
        love.graphics.circle("fill", canvas:getWidth() / 2,  canvas:getHeight() / 2,  canvas:getWidth() / 8, 30)
        love.graphics.setColor(1, 1, 1, 1)
      end)
      return canvas
    end)(),
    onOver = function(grid, x, y, z, mode)
      for i = 1, #grid do
        for j = 1, #grid[i] do
          for k = 1, #grid[i][j] do
            if grid[i][j][k] == 10 then grid[i][j][k] = 9 end -- Desactiva las puertas
          end
        end
      end
      grid[x][y][z] = 7
    end,
    onDraw = function(x, y) end,
    onPostZDraw = function(x, y) draw(8, x, y - 2) end,
    walkable = true,
  },

  [9] = { -- Puerta cerrada
    sprite = (function()
      local canvas = love.graphics.newCanvas(256, 256)
      canvas:renderTo(function()
        love.graphics.setColor(.2, .2, .2, 1)
        love.graphics.circle("fill", canvas:getWidth() / 4,  canvas:getHeight() / 4 - 16,  canvas:getWidth() / 24, 50)
        love.graphics.setColor(1, 1, 1, 1)
      end)
      return canvas
    end)(),
    onOver = function(grid, x, y, z, mode) end,
    onDraw = function(x, y)
      love.graphics.setColor(1, 1, 1, .3) --[[ Esto sería para la casilla, además de para la puerta, ya que de primero está la puerta,
      pero el dibujo de la puerta se pasa a postBlockDraw, por lo que primero se dibuja la puerta, con ese setColor aplicado ]]
    end,
    onPostZDraw = function(x, y)
      love.graphics.setColor(1, 1, 1, .15)
      draw(9, x, y)
    end,
    walkable = false,
  },

  [10] = { -- Puerta abierta
    sprite = (function()
      local canvas = love.graphics.newCanvas(256, 256)
      canvas:renderTo(function()
        love.graphics.setColor(.9, .9, .9, 1)
        love.graphics.circle("fill", canvas:getWidth() / 4,  canvas:getHeight() / 4 - 16,  canvas:getWidth() / 24, 50)
        love.graphics.setColor(1, 1, 1, 1)
      end)
      return canvas
    end)(),
    onOver = function(grid, x, y, z, mode) end,
    onDraw = function(x, y) love.graphics.setColor(1, 1, 1, 1) end,
    onPostZDraw = function(x, y)
      love.graphics.setColor(1, 1, 1, .5)
      draw(10, x, y)
    end,
    walkable = true,
  },
}

function tm:drawTile(IDs, x, y)

  -- Función que se ejecutará después de que todas las celdas de una posición hayan sido dibujadas. Puede ser cambiado por alguna celda
  local postZDraw = function() end

  love.graphics.setColor(1, 1, 1, 1)

  for i = 1, #IDs do
    if IDs[i] and IDs[i] ~= 0 then
      self.tiles[IDs[i]].onDraw(x, y)
      local lastPostZDraw = postZDraw
      postZDraw = function(x, y) lastPostZDraw(x, y) self.tiles[IDs[i]].onPostZDraw(x, y) end -- Se añade código nuevo a la función postZDraw
    end
  end
  postZDraw(x, y)
end

function tm:areWalkable(IDs) -- Comprueba si todas los IDs de las casillas de un punto permiten pasar al jugador
  local voidCell = true -- Sirve para indicar si la celda está totalmente vacía de casillas, para permitir poner 0s en una capa y casillas walkables en otras, y que el jugador pueda caminar por ellas
  for i = 1, #IDs do
    if IDs[i] ~= 0 then voidCell = false end
    if IDs[i] ~= 0 and not self.tiles[IDs[i]].walkable then return false
    end
  end
  return not voidCell
end

return tm
