local AI = {}

function onGoal(x, y, grid) -- Comprueba si existe una casilla redonda en la posición indicada
  for z = 1, #grid[y + 1][x + 1] do
    if grid[y + 1][x + 1][z] == 5 then
      return true
    end
  end
end

local function solve(x, y, maxMoves, detailedInfo, grid, moves) -- Calcula todas las soluciones posibles, el número mínimo y el máximo de movimientos
  -- x: posición x del jugador
  -- y: posición y del jugador
  -- grid: grilla del nivel,
  -- moves: hoja de datos

  grid = grid or mytable.copy(lm:getGrid())

  moves = moves or {{x, y}}

  local dirX; local dirY

  for dir = 1, 4 do
    dirX = 0; dirY = 0
    if dir == 1 then -- Norte
      dirY = -1
    elseif dir == 2 then -- Este
      dirX = 1
    elseif dir == 3 then -- Sur
      dirY = 1
    elseif dir == 4 then -- Oeste
      dirX = -1
    end

    if (onGoal(x, y, grid)) and not lm:remainingCells(grid) then -- Si la posición actual es una casilla redonda y no quedan bloques restantes que gastar
      local dashes = 1
      local lastDashMove = 1
      for i = 1, #moves do
        -- Calculamos los dashes
        for j = lastDashMove, i - 1 do
          if moves[i][1] == moves[j][1] and moves[i][2] == moves[j][2] then -- Si se repite un movimiento (fin del dash)
            lastDashMove = i - 1
            dashes = dashes + 1
            if detailedInfo then print "***" end -- Separación de dash
          end
        end

        -- Imprimimos las posiciones en cada momento y las flechas
        local arrow
        local diffX; local diffY
        if moves[i - 1] then
          diffX = moves[i][1] - moves[i - 1][1]; diffY = moves[i][2] - moves[i - 1][2]
          if diffX == -1 then arrow = "<"
          elseif diffX == 1 then arrow = ">"
          elseif diffY == -1 then arrow = "^"
          elseif diffY == 1 then arrow = "v"
          end
        else
          arrow = "*init*"
        end

        if detailedInfo then print(i .. ": " .. "(" .. moves[i][1] .. ", " .. moves[i][2] .. ")", arrow) end
      end
      if detailedInfo then
        print ("Solution found with " .. dashes .. " dashes")
        print "============================================================"
      else
        io.write(dashes .. ", ")
      end
      break
    end

    if grid[y + dirY + 1] and grid[y + dirY + 1][x + dirX + 1] and tm:areWalkable(grid[y + dirY + 1][x + dirX + 1]) then
      local newX = x + dirX; local newY = y + dirY
      local newMoves = mytable.copy(moves)
      table.insert(newMoves, {newX, newY})
      local newGrid = mytable.copy(grid) -- Se copia la tabla para que la tabla de las demás direcciones no se vea modificada
      for z = 1, #newGrid[newY + 1][newX + 1] do
        if newGrid[newY + 1][newX + 1][z] ~= 5 and newGrid[newY + 1][newX + 1][z] ~= 0 then -- El 0 no tiene función onOver y la del 5 no queremos que se active
          tm.tiles[newGrid[newY + 1][newX + 1][z]].onOver(newGrid, newY + 1, newX + 1, z)
        end
      end
      if #newMoves <= maxMoves then
        solve(newX, newY, maxMoves, detailedInfo, newGrid, newMoves)
      end
    end
  end
end

function AI.solve()
  local initTime
  local maxMoves
  local detailedInfo
  io.write("Type the max number of moves (leave blank for inf): ")
  maxMoves = tonumber(io.read()) or math.huge
  io.write("Do you want detailed info (move steps, dashes, processing time...)? (y/n): ")
  detailedInfo = (function() if io.read() == "y" then return true end end)()
  initTime = os.clock()
  solve(player.x, player.y, maxMoves, detailedInfo)
  if detailedInfo then print("Processing time: " .. os.clock() - initTime .. "s") end
end

return AI
