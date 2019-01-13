local t = {}
t.init = {x = 2, y = 2}
t.layout = {}

t.layout[1] = {
  {0, 0, 1, 1, 1},
  {1, 1, 3, 5, 1},
  {1, 0, 4, 3, 1},
  {2, 3, 0, 0, 1},
  {0, 2, 1, 2, 2}
}

t.moves = {8, 9}

return t
