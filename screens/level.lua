local funcs = {}
local name = "level"

-- Funciones locales
local function toNode(x, y) -- Convierte una posición en un nodo atendiendo a la posicion y a la escala de la cámara
  x, y = camera:worldCoords(x, y)
  return math.floor(x / TILESIZE), math.floor(y / TILESIZE)
end

function funcs:load()
  self.camZoomFlux = nil
  self.nodeConnect = love.audio.newSource("res/sound/water_drop_init.mp3", "static")
  self.wayComplete = love.audio.newSource("res/sound/water_drop_final.mp3", "static")
  self.container = UI.Container(
    UI.Button(WIDTH - 12 - 24, 12, 24, 24, SPRITES.exit, {onRelease = function()
      if BGM2:isPlaying() then BGM2:stop(); BGM:play() end
        sm:set("levelSelection", lm:getMode(), lm:getTotalLevels(lm:getMode()), savm:getCompletedLevels(SAVEDATA, lm:getMode()))
        way:disable()
        way:reset()
      end
    }),

    UI.Button(12, 12, 24, 24, SPRITES.restart, {onRelease = function()
        camera:zoom(0)
        lm:set(lm:get())
      end
    })
  )
end

-- Callbacks
function funcs:init(...)
  if lm:get() == lm:getTotalLevels("relax") then BGM:stop(); BGM2:play() end

  self.camX = 0
  self.camY = 0
  self.camScale = 1.1
  self.moveOrigin = nil
  self.lastPos = {x = 0, y = 0}

  -- Mensaje de introducción
  if lm:getMessage() then
    self.message = UI.Message(lm:getMessage(), WIDTH / 2 - 200 / 2, HEIGHT / 4 - 150 / 2, 200, 150, {1,1,1,1}, "onRelease")
  else self.message = nil end

  if self.camZoomFlux then self.camZoomFlux:stop() end
  flux.to(camera, 0, {scale = 0})
  camera:lookAt(player.x * TILESIZE + TILESIZE / 2, player.y * TILESIZE + TILESIZE / 2)
end

function funcs:draw()
  -- Fondo
  love.graphics.setShader(shaders.multicolorbg)
    love.graphics.setColor(1, 1, 1, 1 - (lm:get() - 1) / (lm:getTotalLevels(lm:getMode()) - 1))
    love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT)
    love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setShader()

  -- Pantalla
  camera:attach()
    lm:draw(lm:get()) -- Se dibuja la cuadrícula del nivel
    if way:isActive() then way:draw(1, 1, 1, .8) end -- Se dibuja el way (la línea que une los nodos)
    player:draw()
  camera:detach()

  -- GUI
  self.container:draw() -- Dibuja los elementos del contenedor
  if self.message then self.message:draw() end
end

function funcs:update(dt)
  local x, y = toNode(love.mouse.getX(), love.mouse.getY())

  shaders.multicolorbg:send("time", TIME)

  player:update(dt)
  gestures:updateTouches()
  self.camZoomFlux = camera:smoothFluxZoom(self.camScale, 0.05, "linear") -- Se encarga de ampliar constantemente al valor de self.camScale
  if self.moveOrigin then
    local x = love.system.getOS() == "Android" and gestures.touches[1].x or love.mouse.getX()
    local y = love.system.getOS() == "Android" and gestures.touches[1].y or love.mouse.getY()
    self.camX = self.moveOrigin.x - x + self.lastPos.x
    self.camY = self.moveOrigin.y - y + self.lastPos.y
  end
  camera:lockPosition(player.x * TILESIZE + TILESIZE / 2 + self.camX/self.camScale, player.y * TILESIZE + TILESIZE / 2 + self.camY/self.camScale, camera.smooth.damped(SMOOTHSPEED)) -- Para que al hacer pich zoom se mueva directamente a la posición
  if way:isActive() and love.mouse.isDown(1, 2, 3) then
    way:updateMouse(camera:worldCoords(love.mouse.getPosition())) -- Se actualiza la posición del mouse según la configuración de la cámara
    -- Si el mouse está sobre un nodo aún no añadido entonces se añade
    if way:nodeAvaliable(x, y) then
      way:addNode(x, y)
      self.nodeConnect:stop()
      self.nodeConnect:play()
    elseif #way.nodes > 2 and x == way.nodes[#way.nodes-3] and y == way.nodes[#way.nodes-2] then -- Si el mouse está en penúltimo nodo puesto
      way:removeLastNode() -- Se elimina el último nodo
    end
  end
end

function funcs:mousepressed(x, y, button, istouch, presses)
  self.container:onPress()
  x, y = toNode(x, y)
  -- Cuando se pulsa sobre el jugador (si no se ha pulsado ya), se activa el way y se añaden la posición del jugador y y del mouse
  if player.x == x and player.y == y then
    way:enable()
    way:addNode(x, y)
    way:updateMouse(camera:worldCoords(love.mouse.getPosition()))
  elseif love.system.getOS() == "Windows" and not way:isActive() then
    self.moveOrigin = {x = love.mouse.getX(), y = love.mouse.getY()}
  end
end

function funcs:mousereleased(x, y, button, isTouch)
  self.container:onRelease()
  if self.message then self.message:onRelease() end

  -- Si hay más de un nodo, se mueve al jugador al último nodo
  if way:isActive() then -- Al dejar de pulsar se desactiva y resetea el way, y se baja en 1 el número de dashes restante
    if #way.nodes > 2 then
      self.wayComplete:play()
      player:set(way:getLastNode())
      lm:applyNodes(way.nodes)
    end
    way:disable()
    way:reset()
  elseif love.system.getOS() == "Windows" then
    self.lastPos = {x = self.camX, y = self.camY}
    self.moveOrigin = nil
  end
end

function funcs:touchpressed(id, x, y)
  local nx, ny = toNode(x, y)
    if (not (player.x == nx and player.y == ny) or gestures:getActiveTouches() > 1) and not way:isActive() then
    gestures:addTouch(id, x, y)
    self.lastPos = {x = self.camX, y = self.camY}
    self.moveOrigin = {x = x, y = y}
  end
end

function funcs:touchreleased(id, x, y)
  gestures:removeTouch(id)
  self.lastPos = {x = self.camX, y = self.camY}
  if gestures:getActiveTouches() == 1 then
    self.moveOrigin = {x = gestures.touches[1].x, y = gestures.touches[1].y}
  else
    self.moveOrigin = nil
  end
end

return Screen(name, funcs)
