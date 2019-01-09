-- Array que contiene los callbacks de la pantalla
local funcs = {}
local name = "intro"

-- Callbacks
function funcs:init(...)
end

function funcs:update(dt)
  if TIME > 0 then sm:set("mainMenu") end
end

function funcs:draw()
  love.graphics.print("LOADING", 0, 0)
end

function funcs:mousereleased(x, y, button, isTouch)
end

return Screen(name, funcs)
