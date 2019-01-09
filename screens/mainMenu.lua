-- Array que contiene los callbacks de la pantalla
local funcs = {}
local name = "mainMenu"

-- Callbacks
function funcs:load()
  self.titleLabel = "INSASH"
  self.container = UI.Container(
    UI.Button(12, 12, 24, 24, SPRITES.music, {
      onRelease = function()
        MUSICSWITCH = not MUSICSWITCH
        if MUSICSWITCH then love.audio.setVolume(1) else love.audio.setVolume(0) end
      end,
      onDraw = function(self)
        if not MUSICSWITCH then love.graphics.setColor(1, 1, 1, .3) end
        self:draw(); love.graphics.setColor(1, 1, 1, 1)
      end
    }),
    UI.Button(WIDTH - 12 - 24, 12, 24, 24, SPRITES.exit, {onRelease = function() love.event.quit() end}),
    UI.Button(WIDTH / 2 - 64, ((HEIGHT*2/3)/2-64) + HEIGHT/3, 128, 128, SPRITES.play, { -- El botón se coloca centrado en la línea que indicaría 2/3 de altura ---|--->|<---
      onRelease = function()
        sm:set("levelSelection", "relax", lm:getTotalLevels("relax"), savm:getCompletedLevels(SAVEDATA, "relax"))
      end
    })
  )
end

function funcs:update(dt)
  shaders.multicolorbg:send("time", TIME)
end

function funcs:draw()
  -- Fondo
  love.graphics.setShader(shaders.multicolorbg)
    love.graphics.setColor(.5, .5, .5, 1)
    love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT)
    love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setShader()

  -- GUI
  self.container:draw()
  love.graphics.setFont(FONT32)
  love.graphics.printf(self.titleLabel, 0, HEIGHT / 8, WIDTH, "center")
end

function funcs:mousepressed(x, y, button, isTouch)
  self.container:onPress()
end

function funcs:mousereleased(x, y, button, isTouch)
  self.container:onRelease()
end

return Screen(name, funcs)
