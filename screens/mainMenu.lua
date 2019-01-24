-- Array que contiene los callbacks de la pantalla
local funcs = {}
local name = "mainMenu"

-- Callbacks
function funcs:load()
  self.titleLabel = "INSASH"
  local function drawBorder(x, y, size)
    local n,n,w,h = SPRITES.border:getViewport()
    love.graphics.draw(SPRITES.atlas, SPRITES.border, x + size/2, y + size/2, TIME, size/w, size/h, w/2, h/2)
  end

  self.container = UI.Container(
    -- Música
    UI.Button(WIDTH / 2 - 24, (HEIGHT*3/10 - (HEIGHT*1/5)/2) - 24, 48, 48, SPRITES.music,
    {
      onRelease = function()
        MUSICSWITCH = not MUSICSWITCH
        if MUSICSWITCH then love.audio.setVolume(1) else love.audio.setVolume(0) end
      end,
      onDraw = function(self)
        if not MUSICSWITCH then love.graphics.setColor(1, 1, 1, .3) end
        self:draw()
        local increase = self.w * 3/8
        drawBorder(self.x - increase, self.y - increase, self.w + increase*2)
        love.graphics.setColor(1, 1, 1, 1)
      end
    }),

    -- Créditos
    UI.Button(WIDTH / 2 - 24, (HEIGHT*9/10 - (HEIGHT*1/5)/2) - 24, 48, 48, (function()
      local canvas = love.graphics.newCanvas(64, 64)
      canvas:renderTo(function()
        love.graphics.setFont(FONT64)
        love.graphics.printf("i", 0, -8, 64, "center")
      end)
      return canvas
    end)(),
    {
      onRelease = function() sm:set("credits") end,
      onDraw = function(self)
        self:draw()
        local increase = self.w * 3/8
        drawBorder(self.x - increase, self.y - increase, self.w + increase*2)
        love.graphics.setColor(1, 1, 1, 1)
      end
    }),

    -- Salir
    UI.Button(WIDTH - 12 - 24, 12, 24, 24, SPRITES.exit, {onRelease = function() love.event.quit() end}),

    -- Jugar
    UI.Button(WIDTH / 2 - 64, (HEIGHT*5/10 - 64), 128, 128, SPRITES.play, {
      onRelease = function()
        sm:set("levelSelection", "relax", lm:getTotalLevels("relax"), savm:getCompletedLevels(SAVEDATA, "relax"))
      end,
      onDraw = function(self)
        self:draw()
        local increase = self.w * 3/8
        drawBorder(self.x - increase, self.y - increase, self.w + increase*2)
        love.graphics.setColor(1, 1, 1, 1)
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
    love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT)
  love.graphics.setShader()

  -- GUI
  self.container:draw()
  love.graphics.setFont(FONT32)
  love.graphics.printf(TITLE, 12, 12, WIDTH, "left")
  love.graphics.setFont(FONT16)
  love.graphics.setColor(1, 1, 1, .4)
  love.graphics.printf(VERSION, 12, HEIGHT - 12 - 16, WIDTH, "left")
  love.graphics.setColor(1, 1, 1, 1)
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
