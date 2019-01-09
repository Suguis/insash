local UI = {}

-----------------------------------------------------------------------

UI.Container = Class:extend() -- Aquí se meten todos los objetos de una screen para actualizarlos todos a la vez por ejemplo

function UI.Container:new(...)
  self:append(...)
end

function UI.Container:append(...) -- Agrega elementos al contenedor
  local elements = {...}

  for i = 1, #elements do
    table.insert(self, elements[i])
  end
end

function UI.Container:orderInPanel(x, y, width, height) -- Ordena elementos de tal forma que estén en un panel
  local elementW = self[1].w
  local elementH = self[1].h
  local elementHorLim = math.floor(width / elementW) -- Número máximo de elementos en horizontal

  local rowNum = math.ceil(#self / elementHorLim)
  for row = 1, rowNum do
    local colNum = ((#self - (row - 1) * elementHorLim) >= elementHorLim) and elementHorLim or (#self - (row - 1) * elementHorLim)
    for col = 1, colNum do
      self[col + elementHorLim * (row - 1)].x = width / 2 + (col-1) * elementW - ((colNum) * elementW) / 2 + x
      self[col + elementHorLim * (row - 1)].y = height / 2 + (row-1) * elementW - ((rowNum) * elementH) / 2 + y
    end
  end
end

-- Callbacks

function UI.Container:onHover()
  for i, element in ipairs(self) do
    element:onHover()
  end
end

function UI.Container:onPress()
  for i, element in ipairs(self) do
    element:onPress()
  end
end

function UI.Container:onRelease()
  for i, element in ipairs(self) do
    element:onRelease()
  end
end

function UI.Container:draw()
  for i, element in ipairs(self) do
    element.onDraw()
  end
end

-----------------------------------------------------------------------

UI.Button = Class:extend()

function UI.Button:new(x, y, width, height, sprite, functions, releaseOnEverything)
  self.releaseOnEverything = releaseOnEverything -- Si es verdadero, el botón se activa al hacer click desde cualquier punto y soltar en él
  self.x = x
  self.y = y
  self.w = width
  self.h = height
  if sprite:typeOf("Quad") then
    self.sprite = {quad = sprite}
    self.sprite.x, self.sprite.y, self.sprite.w, self.sprite.h = sprite:getViewport()
  else
    self.sprite = sprite
  end
  self.state = "noAction"

  -- Hitbox
  self.hx = (hitbox and hitbox.x) or 0
  self.hy = (hitbox and hitbox.y) or 0
  self.hw = (hitbox and hitbox.w) or width
  self.hh = (hitbox and hitbox.h) or height

  self.onHover = function()
    local x = love.mouse.getX(); local y = love.mouse.getY()
    if (x >= self.x + self.hx and x < self.x + self.hx + self.hw) and (y >= self.y + self.hy and y < self.y + self.hy + self.hh) then
      if functions.onHover then functions.onHover() end
    end
  end

  self.onPress = function()
    local x = love.mouse.getX(); local y = love.mouse.getY()
    if (x >= self.x + self.hx and x < self.x + self.hx + self.hw) and (y >= self.y + self.hy and y < self.y + self.hy + self.hh) then
      if functions.onPress then functions.onPress() end
      self.state = "pressed"
    end
  end

  self.onRelease = function()
    local x = love.mouse.getX(); local y = love.mouse.getY()
    if (x >= self.x + self.hx and x < self.x + self.hx + self.hw) and (y >= self.y + self.hy and y < self.y + self.hy + self.hh) then
      if (self.state == "pressed" or self.releaseOnEverything) and functions.onRelease then PRESS:play(); functions.onRelease() end
    end
    self.state = "noAction"
  end

  self.onDraw = function()
    if functions.onDraw then functions.onDraw(self) else self:draw() end
  end
end

function UI.Button:draw()
  if type(self.sprite) == "table" then -- Los botones con quad tienen en su elemento sprite una tabla con sus datos
    love.graphics.draw(SPRITES.atlas, self.sprite.quad, self.x, self.y, 0, self.w / self.sprite.w, self.h / self.sprite.h)
  else
    love.graphics.draw(self.sprite, self.x, self.y, 0, self.w / self.sprite:getWidth(), self.h / self.sprite:getHeight())
  end
end

-----------------------------------------------------------------------

UI.Message = Class:extend()

function UI.Message:new(text, x, y, width, height, color, vanishType)
  self.text = text
  self.x = x
  self.y = y
  self.w = width
  self.h = height
  self.color = color

  if type(vanishType) == "number" then
    flux.to(self.color, .5, {[4] = 0}):delay(vanishType)
  elseif vanishType == "onRelease" then
    self.onRelease = function()
      local x = love.mouse.getX(); local y = love.mouse.getY()
      if (x >= self.x and x < self.x + self.w) and (y >= self.y and y < self.y + self.h) then
        flux.to(self.color, .5, {[4] = 0})
      end
    end
  end

  self.onDraw = function()
    self:draw()
  end
end

function UI.Message:draw()
  love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.color[4] / 2)
  love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, 8, 8, 20)
  love.graphics.setColor(1, 1, 1, self.color[4])
  love.graphics.setFont(FONT16)
  love.graphics.printf(self.text, self.x, self.y, self.w, "center")
  love.graphics.setColor(1, 1, 1, 1)
end

return UI
