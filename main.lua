-- TODO: Crear un sistema para elegir el idioma
-- TODO: Reorientar los niveles (NSEO)
-- TODO: Crear todos los niveles restantes
-- TODO: Poner algo para dar créditos
-- Nota para la cración de niveles: en cada nivel la celda final sigue un patrón de posición N-S-E-O (¡respecto al jugador!)

if love.system.getOS() == "Windows" then love.window.setFullscreen(false) end

-- Librerías
local utf8 = require("utf8") -- Para el error handler
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

-- Varaibles/constantes globales:
-- Ponemos las dimensiones del dispositivo para que todo se posicione correctamente en portrait
WIDTH = love.graphics.getWidth()
HEIGHT = love.graphics.getHeight()

TITLE = "INSASH"
VERSION = "1.0.0"

TILESIZE = 32 -- Tamaño de la cuadrícula
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
DEBUGGING = false -- Si esto está desactivado cuando se produzcan errores no aparecerá la pantalla azul, sino que te mandará a escribir un correo para reportar el error

-- Solo activar este código cuando se necesite hacer un atlas
--[[
require "lib.atlas.atlas"
atlas = Atlas(0, 0, false, "res/sprites/__singleSprites", "atlas", true, false)
--]]

sm:load()

function love.load()
  BGM:play()
  camera = Camera()
  sm:set("load") -- Primera screen
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
  if key == 'd' and love.keyboard.isDown('lctrl') then love.system.openURL("http://127.0.0.1:8000") end -- Se abre lovebird al pulsar 'Ctrl + D'
  if key == 's' and love.keyboard.isDown('lctrl') then ai.solve(player.x, player.y) end -- Se ejecuta la IA para resolver el nivel
end

function love.touchpressed(id, x, y, dx, dy, pressure)
  sm:get():touchpressed(id, x, y)
end

function love.touchreleased(id, x, y, dx, dy, pressure)
  sm:get():touchreleased(id, x, y)
end

local function error_printer(msg, layer)
	print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

local function deferrhand(msg)
  msg = tostring(msg)

	error_printer(msg, 2)

	if not love.window or not love.graphics or not love.event then
		return
	end

	if not love.graphics.isCreated() or not love.window.isOpen() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end

	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
		if love.mouse.isCursorSupported() then
			love.mouse.setCursor()
		end
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end

	love.graphics.reset()
	local font = love.graphics.setNewFont(14)

	love.graphics.setColor(1, 1, 1, 1)

	local trace = debug.traceback()

	love.graphics.origin()

	local sanitizedmsg = {}
	for char in msg:gmatch(utf8.charpattern) do
		table.insert(sanitizedmsg, char)
	end
	sanitizedmsg = table.concat(sanitizedmsg)

	local err = {}

	table.insert(err, "Error\n")
	table.insert(err, sanitizedmsg)

	if #sanitizedmsg ~= #msg then
		table.insert(err, "Invalid UTF-8 string in error message.")
	end

	table.insert(err, "\n")

	for l in trace:gmatch("(.-)\n") do
		if not l:match("boot.lua") then
			l = l:gsub("stack traceback:", "Traceback\n")
			table.insert(err, l)
		end
	end

	local p = table.concat(err, "\n")

	p = p:gsub("\t", "")
	p = p:gsub("%[string \"(.-)\"%]", "%1")

	local function draw()
		local pos = 70
		love.graphics.clear(89/255, 157/255, 220/255)
		love.graphics.printf(p, pos, pos, love.graphics.getWidth() - pos)
		love.graphics.present()
	end

	local fullErrorText = p
	local function copyToClipboard()
		if not love.system then return end
		love.system.setClipboardText(fullErrorText)
		p = p .. "\nCopied to clipboard!"
		draw()
	end

	if love.system then
		p = p .. "\n\nPress Ctrl+C or tap to copy this error"
	end

	return function()
		love.event.pump()

		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return 1
			elseif e == "keypressed" and a == "escape" then
				return 1
			elseif e == "keypressed" and a == "c" and love.keyboard.isDown("lctrl", "rctrl") then
				copyToClipboard()
			elseif e == "touchpressed" then
				local name = love.window.getTitle()
				if #name == 0 or name == "Untitled" then name = "Game" end
				local buttons = {"OK", "Cancel"}
				if love.system then
					buttons[3] = "Copy to clipboard"
				end
				local pressed = love.window.showMessageBox("Quit "..name.."?", "", buttons)
				if pressed == 1 then
					return 1
				elseif pressed == 3 then
					copyToClipboard()
				end
			end
		end

		draw()

		if love.timer then
			love.timer.sleep(0.1)
		end
	end
end

local function myerrhand(msg)
  msg = tostring(msg)

  error_printer(msg, 2)

  if not love.window or not love.graphics or not love.event then
    return
  end

  if not love.graphics.isCreated() or not love.window.isOpen() then
    local success, status = pcall(love.window.setMode, 800, 600)
    if not success or not status then
      return
    end
  end

  -- Reset state.
  if love.mouse then
    love.mouse.setVisible(true)
    love.mouse.setGrabbed(false)
    love.mouse.setRelativeMode(false)
    if love.mouse.isCursorSupported() then
      love.mouse.setCursor()
    end
  end
  if love.joystick then
    -- Stop all joystick vibrations.
    for i,v in ipairs(love.joystick.getJoysticks()) do
      v:setVibration()
    end
  end
  if love.audio then love.audio.stop() end

  love.graphics.reset()
  local font = love.graphics.setNewFont(14)

  love.graphics.setColor(1, 1, 1, 1)

  local trace = debug.traceback()

  love.graphics.origin()

  local sanitizedmsg = {}
  for char in msg:gmatch(utf8.charpattern) do
    table.insert(sanitizedmsg, char)
  end
  sanitizedmsg = table.concat(sanitizedmsg)

  local err = {}

  table.insert(err, "Error\n")
  table.insert(err, sanitizedmsg)

  if #sanitizedmsg ~= #msg then
    table.insert(err, "Invalid UTF-8 string in error message.")
  end

  table.insert(err, "\n")

  for l in trace:gmatch("(.-)\n") do
    if not l:match("boot.lua") then
      l = l:gsub("stack traceback:", "Traceback%0D%0A")
      table.insert(err, l)
    end
  end

  local p = table.concat(err, "%0D%0A")

  p = p:gsub("\t", "")
  p = p:gsub("%[string \"(.-)\"%]", "%1")

  local fullErrorText = p

  return function()
    local button = love.window.showMessageBox("Error", "Sorry, an error has ocurred! Would you like to report it to let me know the error and solve it?", {"Yes", "No"})
    if button == 1 then
      love.system.openURL("mailto:adrisolgo7373@gmail.com?subject=*Insash error* ".. msg .. "&body=Sorry for the error! Please, explain what happened below this line, and do not change other parts of this email to help me to solve the error. Thanks!:%0D%0A*Your explanation...*%0D%0A%0D%0A------------------------------------------------%0D%0A" .. p)
    end

    return 1
  end
end

function love.errorhandler(msg)
  if DEBUGGING then return deferrhand(msg)
  else return myerrhand(msg) end
end
