local savm = {}

function savm:getCompletedLevels(saveData, mode, range) -- Devuelve el número de niveles completados
  if range then
    local counter = 0
    for i = 1, lm:getTotalLevels("relax") do
      if lm:getRange(i, "relax", savm:getMoves(saveData, i, "relax")) == range then counter = counter + 1 end
    end
    return counter
  else
    return #saveData[mode].levelMoves
  end
end

function savm:manageLevelMoves(saveData, newMoves, level, mode) -- Define el "récord" de movimientos de un nivel (si el núm. de movs. es mayor que el actual, no hace nada, sino lo sobreescribe)
  if not saveData[mode].levelMoves[level] or newMoves < saveData[mode].levelMoves[level] then saveData[mode].levelMoves[level] = newMoves end
end

function savm:setLevelMoves(saveData, newMoves, level, mode) -- Define el "récord" de movimientos de un nivel (si el núm. de movs. es mayor que el actual, no hace nada, sino lo sobreescribe)
  saveData[mode].levelMoves[level] = newMoves
end

function savm:getMoves(saveData, level, mode)
  return saveData[mode].levelMoves[level] or math.huge -- Se devuelve math.huge para que si el nivel no ha sido hecho que nunca devuelva un número menor a los movimientos de oro
end

function savm:setCompletedLeves(saveData, num, mode) -- Solo usar para debuger, ya que no guarda legalmente los movimientos
  for i = 1, num do
    saveData[mode].levelMoves[i] = 0
  end
end

function savm:getLanguage(saveData)
  return saveData.language
end

function savm:setLanguage(saveData, lang)
  saveData.language = lang
end

function savm:save(saveData)
  love.filesystem.write("save.sav", serialize(saveData))
end

function savm:load()
  if love.filesystem.getInfo("save.sav") then
    return loadstring(love.filesystem.read("save.sav"))()
  end
end

return savm
