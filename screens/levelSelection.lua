-- Array que contiene los callbacks de la pantalla
local funcs = {}
local name = "levelSelection"

local function drawBorder(x, y, size)
  local n,n,w,h = SPRITES.border:getViewport()
  love.graphics.draw(SPRITES.atlas, SPRITES.border, x + size/2, y + size/2, TIME, size/w, size/h, w/2, h/2)
end

-- Callbacks
function funcs:load()
  local levelButtonSize = 48

  self.purpleBigCircle = love.graphics.newCanvas(levelButtonSize * DPI, levelButtonSize * DPI)
  self.purpleBigCircle:renderTo(function()
    love.graphics.setColor(.33, 0, 1, 1)
    love.graphics.circle("fill", levelButtonSize * DPI / 2, levelButtonSize * DPI / 2, levelButtonSize * DPI / 3, 30 * DPI)
    love.graphics.setColor(1, 1, 1)
  end)

  self.goldenBigCircle = love.graphics.newCanvas(levelButtonSize * DPI, levelButtonSize * DPI)
  self.goldenBigCircle:renderTo(function()
    love.graphics.setColor(1, .66, 0, 1)
    love.graphics.circle("fill", levelButtonSize * DPI / 2, levelButtonSize * DPI / 2, levelButtonSize * DPI / 3, 30 * DPI)
    love.graphics.setColor(1, 1, 1)
  end)

  self.bigCircle = love.graphics.newCanvas(levelButtonSize * DPI, levelButtonSize * DPI)
  self.bigCircle:renderTo(function()
    love.graphics.circle("fill", levelButtonSize * DPI / 2, levelButtonSize * DPI / 2, levelButtonSize * DPI / 3, 30 * DPI)
  end)

  self.smallCircle = love.graphics.newCanvas(levelButtonSize * DPI, levelButtonSize * DPI)
  self.smallCircle:renderTo(function()
    love.graphics.circle("fill", levelButtonSize * DPI / 2, levelButtonSize * DPI / 2, levelButtonSize * DPI / 8, 30 * DPI)
  end)

  self.container = UI.Container(
    -- Botón de cerrar
    UI.Button(WIDTH - 12 - 24, 12, 24, 24, SPRITES.exit, {onRelease = function() sm:set("mainMenu") end})
  )
end

function funcs:init(...)
  local levelButtonSize = 48
  self.mode, self.numberOfLevels, self.completedLevels = ...
  self.levelLabel = ""
  self.notCompletedLevelMessage = nil

  -- Contenedor de los botones de los niveles
  self.levelButtons = UI.Container()

  for i = 1, self.numberOfLevels do -- Un botón por cada nivel
    local onHover = function() if love.mouse.isDown(1, 2, 3) then self.levelLabel = tostring(i) end end
    if i > self.completedLevels then -- Botón pequeño
      local onRelease
      local drawLevelAura
      if i == self.completedLevels + 1 then -- Si es el último nivel disponible
        onRelease = function() lm:set(i, self.mode); sm:set("level") end
        drawLevelAura = function(self) -- Se hace que la función de dibujar aura dibuje un aura
          love.graphics.setColor(1, 1, 1, .3)
          love.graphics.circle("fill", self.x + levelButtonSize / 2, self.y + levelButtonSize / 2,
          mymath.sinRange(TIME * 2, levelButtonSize / 4, levelButtonSize / 2), 30 * DPI)
          love.graphics.setColor(1, 1, 1, 1)
        end
      else
        -- Se crea el mensaje de nivel no desbloqueado
        onRelease = function()
          self.notCompletedLevelMessage = UI.Message("Level not unlocked!", WIDTH / 2 - 140 / 2, HEIGHT / 4 - 60 / 2, 140, 60, {1,1,1,1}, 1.5)
        end
        drawLevelAura = function() end
      end

      self.levelButtons:append(
        UI.Button(nil, nil, levelButtonSize, levelButtonSize, self.smallCircle, {
          onRelease = onRelease,
          onHover = onHover,
          onDraw = function(self)
            self:draw()
            drawLevelAura(self)
            if i == 20 then drawBorder(self.x, self.y, levelButtonSize) end
          end}, true
        )
      )
    else -- Botón grande
      local onRelease = function() lm:set(i, self.mode); sm:set("level") end
      local canvas = nil
      if lm:getRange(i, self.mode, savm:getMoves(SAVEDATA, i, self.mode)) == "purple" then
        canvas = self.purpleBigCircle
      elseif lm:getRange(i, self.mode, savm:getMoves(SAVEDATA, i, self.mode)) == "gold" then
        canvas = self.goldenBigCircle
      else
        canvas = self.bigCircle
      end
      self.levelButtons:append(
        UI.Button(nil, nil, levelButtonSize, levelButtonSize, canvas, {onRelease = onRelease, onHover = onHover, onDraw = function(self)
          self:draw()
          if i == 20 then drawBorder(self.x, self.y, levelButtonSize) end
        end}, true)
      )
    end
  end
  self.levelButtons:orderInPanel(0, HEIGHT / 8, WIDTH, HEIGHT * 7 / 8)
end

function funcs:update(dt)
  self.levelLabel = "" -- Se vacía el label para que solo aparezca la etiqueta cuando un botón esté pulsado
  self.levelButtons:onHover()
  shaders.multicolorbg:send("time", TIME)
end

function funcs:draw()
  -- Fondo
  love.graphics.setShader(shaders.multicolorbg)
    love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT)
  love.graphics.setShader()

  -- GUI
  love.graphics.setFont(FONT32)
  love.graphics.setColor(1, 1, 1, .4)
  love.graphics.printf(self.levelLabel, 0, math.floor(HEIGHT / 32), WIDTH, "center")
  love.graphics.setColor(1, 1, 1, 1)
  self.container:draw()
  self.levelButtons:draw()
  if self.notCompletedLevelMessage then self.notCompletedLevelMessage:draw() end
end

function funcs:mousepressed(x, y, button, isTouch)
  self.container:onPress()
  self.levelButtons:onPress()
end

function funcs:mousereleased(x, y, button, isTouch)
  self.container:onRelease()
  self.levelButtons:onRelease()
end

return Screen(name, funcs)
