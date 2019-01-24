local funcs = {}
local name = "level"

function funcs:load()
  self.container = UI.Container(
    -- Inglés
    UI.Button(0, 0, 64, 64, (function()
      local canvas = love.graphics.newCanvas(64, 64)
      canvas:renderTo(function()
        love.graphics.setFont(FONT32)
        love.graphics.printf("EN", 0, 0, 64, "center")
      end)
      return canvas
    end)(), {onRelease = function() savm:setLanguage(SAVEDATA, "en"); savm:save(SAVEDATA) sm:set("mainMenu") end}),

    -- Español
    UI.Button(0, 64, 64, 64, (function()
      local canvas = love.graphics.newCanvas(64, 64)
      canvas:renderTo(function()
        love.graphics.setFont(FONT32)
        love.graphics.printf("ES", 0, 0, 64, "center")
      end)
      return canvas
    end)(), {onRelease = function() savm:setLanguage(SAVEDATA, "es"); savm:save(SAVEDATA) sm:set("mainMenu") end})
  )
  self.container:orderInPanel(0, 0, WIDTH, HEIGHT)
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
  self.container:draw()
end

function funcs:mousepressed(x, y, button, isTouch)
  self.container:onPress()
end

function funcs:mousereleased(x, y, button, isTouch)
  self.container:onRelease()
end

function funcs:keypressed(key, scancode, isrepeat)
  if key == "escape" then love.event.quit() end
end

return Screen(name, funcs)
