local sm = {}
sm.currScr = nil
sm.screens = {
  ["load"] = require "screens.load",
  ["mainMenu"] = require "screens.mainMenu",
  ["levelSelection"] = require "screens.levelSelection",
  ["level"] = require "screens.level",
}

function sm:load()
  for name, scr in pairs(self.screens) do
    if scr.load then scr:load() end -- Ejecuta la función de carga, que se ejecuta una única vez. Esto es útil para, p. ej., no crear varias veces un mismo botón
  end
end

function sm:set(screenName, ...) -- Los tres puntos (...) son parámetros adicionales enviados a la screen
  if type(screenName) ~= "string" then error("screen name must be an string", 2) end
  if not self.screens[screenName]:is(Screen) then error("screen " .. screenName .. " doesn't exists", 2) end -- Se comprueba que el parámetro sea una screen
  self.screens[screenName]:init(...) -- Se ejecuta la función de inicio de la nueva pantalla
  self.currScr = self.screens[screenName] -- Se establece como activa la nueva pantalla
end

function sm:get()
  return self.currScr
end

return sm
