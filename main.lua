-- TODO: Rediseñar la pantalla principal
-- TODO: Hacer un efecto de desvanecimiento con los ways, y que algunas baldosas tengan animaciones al ser pisadas
-- TODO: Optimizar el juego agrupando todas las imágenes en una
-- TODO: Hacer una pantalla de carga usando threads, y con una barra de progreso si puede ser, o un porcentaje en número
-- TODO: Mejorar los mensajes de la UI, haciendo que éstos permitan colores y opciones de desaparición (hacer click, esperar x segundos...)
-- TODO: Mejorar la IA para que ponga el tiempo aproximado que tardará en computar un nivel
-- Nota para la cración de niveles: en cada nivel la celda final sigue un patrón de posición N-S-E-O (¡respecto al jugador!)

-- Librerías
Class = require "lib.classic.classic" -- Generador de clases
Camera = require "lib.hump.camera" -- Cámara
lovebird = require "lib.lovebird.lovebird" -- Debugger Lovebird
UI = require "lib.ui.ui" -- Interfaz de usuario
gestures = require "lib.gestures.gestures" -- Gestos (pellizcar, etc.)
flux = require "lib.flux.flux" -- Numeros que cambian suavemente
serialize = require "lib.ser.ser" -- Para guardar tablas

-- Librerías de ampliación
mytable = require "lib.myLibraries.mytable"
mymath = require "lib.myLibraries.mymath"

-- Clases y objetos:
Screen = require "objects.screen"
player = require "objects.player"

-- Sprites
require "res.sprites"

-- Systems:
way = require "systems.way"
sm = require "systems.screenManager"
lm = require "systems.levelManager"
tm = require "systems.tileManager"
savm = require "systems.saveManager"
ai = require "systems.AI"
wins = require "systems.winstate"

-- Shaders:
shaders = {}
shaders.multicolorbg = love.graphics.newShader("shaders/multicolor.glsl")

-- Constantes globales:
-- Ponemos las dimensiones del dispositivo para que todo se posicione correctamente en portrait
WIDTH = love.graphics.getWidth()
HEIGHT = love.graphics.getHeight()

TILESIZE = 32 -- Tamaño de la cuadrícula
SCALE = 1 -- Escala constante de la cámara
SMOOTHSPEED = 16 -- Velocidad de los efectos suaves de la cámara
DPI = 1
TIME = 0
BGM = love.audio.newSource("res/sound/mellow_puzzler.mp3", "stream")
BGM:setLooping(true)
PRESS = love.audio.newSource("res/sound/balloon_snap.mp3", "static")
WIN = love.audio.newSource("res/sound/beep.mp3", "static")
FONT32 = love.graphics.newFont("res/fonts/CaviarDreams_Bold.ttf", 32)
FONT16 = love.graphics.newFont("res/fonts/CaviarDreams_Bold.ttf", 16)
MUSICSWITCH = true
SAVEDATA = savm:load() or {
  relax = {
    levelMoves = {}
  }
}

-- Solo activar este código cuando se necesite hacer un atlas
--[[
require "lib.atlas.atlas"
atlas = Atlas(0, 0, false, "res/sprites", "atlas", true, false)
--]]

sm:load()

function love.load()
  BGM:play()
  camera = Camera()
  sm:set("intro") -- Primera screen
end

function love.draw()
  sm:get():draw()
  love.graphics.setFont(FONT16)
  wins:draw() -- Hay que mostrarlo siempre, ya que es como una especie de notificación que permanece en el resto de pantallas
end

function love.update(dt)
  TIME = TIME + dt
  flux.update(dt)
  lovebird.update()
  sm:get():update(dt)
end

function love.mousepressed(x, y, button)
  sm:get():mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
  sm:get():mousereleased(x, y, button)
end

function love.keypressed(key, scancode, isrepeat)
  if key == 'left' then
    camera:move(-1, 0)
  elseif key == 'right' then
    camera:move(1, 0)
  elseif key == '+' then
    SCALE = SCALE * 2
  elseif key == '-' then
    SCALE = SCALE / 2
  end

  if key == 'd' and love.keyboard.isDown('lctrl') then love.system.openURL("http://127.0.0.1:8000") end -- Se abre lovebird al pulsar 'Ctrl + D'
  if key == 's' and love.keyboard.isDown('lctrl') then ai.solve(player.x, player.y) end -- Se ejecuta la IA para resolver el nivel
end

function love.touchpressed(id, x, y, dx, dy, pressure)
  sm:get():touchpressed(id, x, y)
end

function love.touchreleased(id, x, y, dx, dy, pressure)
  sm:get():touchreleased(id, x, y)
end
