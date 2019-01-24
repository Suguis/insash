local Screen = Class:extend()

-- El constructor de las screen tiene una array con los callbacks como argumento
function Screen:new(name, funcList)
  local function void() end
  self.name = name
  self.load = funcList.load or void
  self.init = funcList.init or void
  self.draw = funcList.draw or void
  self.update = funcList.update or void
  self.mousepressed = funcList.mousepressed or void
  self.mousereleased = funcList.mousereleased or void
  self.touchpressed = funcList.touchpressed or void
  self.touchreleased = funcList.touchreleased or void
  self.keypressed = funcList.keypressed or void
end

return Screen
