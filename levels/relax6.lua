local t = {}
t.init = {x = 0, y = 0}
t.layout = {}

t.layout[1] = {
  {6, 1, 1},
  {2, 0, 1},
  {1, 5, 1},
}

t.moves = {2, 3}

t.message = {
  en = "There are blocks that need to be passed more than once to be destroyed",
  es = "Hay bloques por los que debes pasar más de una vez para que sean destruidos",
}

return t
