local funcs = {}
local name = "level"

function funcs:load()
  self.credits = {
    en =
[[
Game by Ivy - Bitivyte
Twitter: @bitivyte
Web: bitivyte.000webhostapp.com

Music by Eric Matyas
www.soundimage.org

Thanks to nui for giving me the support to complete this, and for his ideas for the game
]],

    es =
[[
Juego por Ivy - Bitivyte
Twitter: @bitivyte
Web: bitivyte.000webhostapp.com

Música por Eric Matyas
www.soundimage.org

Gracias a nui por darme el apoyo para lograr terminar esto, y por sus ideas para el juego
]],
  }

  self.exit = UI.Button(WIDTH - 12 - 24, 12, 24, 24, SPRITES.exit, {onRelease = function() sm:set("mainMenu") end})
end

function funcs:init()

end

function funcs:update(dt)
  shaders.multicolorbg:send("time", TIME)
end

function funcs:draw()
  -- Fondo
  love.graphics.setShader(shaders.multicolorbg)
    love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT)
  love.graphics.setShader()

  -- GUI
  self.exit:draw()
  love.graphics.setFont(FONT16)
  love.graphics.printf(self.credits[savm:getLanguage(SAVEDATA)], 12, 32, WIDTH - 12 - 12, "center")
end

function funcs:mousepressed(x, y, button, isTouch)
  self.exit:onPress()
end

function funcs:mousereleased(x, y, button, isTouch)
  self.exit:onRelease()
end

function funcs:keypressed(key, scancode, isrepeat)
  if key == "escape" then sm:set("mainMenu") end
end

return Screen(name, funcs)
