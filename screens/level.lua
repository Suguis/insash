local funcs = {}
local name = "level"

-- Variables locales
local initDistance = nil

-- Funciones locales
local function toNode(x, y) -- Convierte una posición en un nodo atendiendo a la posicion y a la escala de la cámara
  x, y = camera:worldCoords(x, y)
  return math.floor(x / TILESIZE), math.floor(y / TILESIZE)
end

function funcs:load()
  self.nodeConnect = love.audio.newSource("res/sound/water_drop_init.mp3", "static")
  self.wayComplete = love.audio.newSource("res/sound/water_drop_final.mp3", "static")
  self.container = UI.Container(
    UI.Button(WIDTH - 12 - 24, 12, 24, 24, SPRITES.exit, {onRelease = function()
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
  -- Mensaje de introducción
  if lm:getMessage() then
    self.message = UI.Message(lm:getMessage(), WIDTH / 2 - 200 / 2, HEIGHT / 4 - 150 / 2, 200, 150, {1,1,1,1}, "onRelease")
  else self.message = nil end

  -- Establecemos los valores iniciales de la cámara
  camera:zoom(0)
  camera:lookAt(player.x * TILESIZE + TILESIZE / 2, player.y * TILESIZE + TILESIZE / 2)
end

function funcs:draw()
  -- Fondo
  love.graphics.setShader(shaders.multicolorbg)
    love.graphics.setColor(.5, .5, .5, 1 - (lm:get() - 1) / (lm:getTotalLevels(lm:getMode()) - 1))
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
  shaders.multicolorbg:send("time", TIME)

  player:update(dt)
  gestures:updateTouches()
  camera:smoothZoom(SCALE, 0.05, "linear") -- Se encarga de ampliar constantemente al valor de SCALE
  if initDistance then -- Si la variable initDistance existe (existirá cuando haya únicamente dos touches activos, ver touchpresed y touchreleased)
    SCALE = gestures:getTouchesDistance(1, 2) / initDistance -- Se ajusta la escala según la distancia de los touches
  end
  camera:lockPosition(player.x * TILESIZE + TILESIZE / 2, player.y * TILESIZE + TILESIZE / 2, camera.smooth.damped(SMOOTHSPEED))
  if way:isActive() and love.mouse.isDown(1, 2, 3) then
    way:updateMouse(camera:worldCoords(love.mouse.getPosition())) -- Se actualiza la posición del mouse según la configuración de la cámara
    -- Si el mouse está sobre un nodo aún no añadido entonces se añade
    local x, y = toNode(love.mouse.getX(), love.mouse.getY())
    if way:nodeAvaliable(x, y) then
      way:addNode(x, y)
      self.nodeConnect:stop()
      self.nodeConnect:play()
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
  end
end

function funcs:touchpressed(id, x, y)
  gestures:addTouch(id, x, y)
  if gestures:getActiveTouches() == 2 then initDistance = gestures:getTouchesDistance(1, 2) / SCALE
    --[[                                                ^
    Se establece initDistance a la distancia de los touches, pero dividida por SCALE, para que no vuelva al
    zoom inicial al hacer pinch, ya que en funcs:update, SCALE se establece como el cociente entre la posición
    actual de los touches y esta variable, y para conservar el zoom modificado antes de volver a hacer pinch,
    se divide esta variable por el zoom que hay justo cuando empieza a haber dos touches activos.
    ]]
  elseif gestures:getActiveTouches() ~= 2 then initDistance = nil
  end
end

function funcs:touchreleased(id, x, y)
  gestures:removeTouch(id)
  if gestures:getActiveTouches() == 2 then initDistance = gestures:getTouchesDistance(1, 2) / SCALE
  elseif gestures:getActiveTouches() ~= 2 then initDistance = nil
  end
end

return Screen(name, funcs)
