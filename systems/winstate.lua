wins = {}
wins.enabled = false
wins.opacity = 0
wins.rangeColors = {
  purple = {.25, 0, .7, 1},
  gold = {1, .85, 0, 1},
  white = {1, 1, 1, 1}
}
local WIDTH = love.graphics.getWidth()
local HEIGHT = love.graphics.getHeight()
local w = 60
local h = 20

wins.range = "" -- Posibles rangos (mejor a peor): blanco, dorado y morado
wins.moves = 0

function wins:show(movs, range)
  wins.message = UI.Message(tostring(movs), WIDTH/2 - w/2, HEIGHT/1.25 - h/2, w, h, mytable.copy(self.rangeColors[range]), 1.5)
  WIN:play()
end

function wins:draw()
  if wins.message then wins.message.onDraw() end
end

return wins
