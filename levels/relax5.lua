local t = {}
t.init = {x = 1, y = 2}
t.layout = {}

t.layout[1] = {
  {0, 5, 1},
  {1, 1, 1},
  {1, 6, 1}
}

t.moves = {2, 3}

t.message = {
  en = "If you get stuck you can use the level restart button on the top-left side of the screen",
  es = "Si te quedas atascado puedes puelsar el botón de reinicio de nivel que se encuentra arriba a la izquierda",
}

return t
