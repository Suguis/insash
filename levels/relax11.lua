local t = {}
t.init = {x = 0, y = 3}
t.layout = {}

t.layout[1] = {
  {0, 1, 2, 6},
  {1, 2, 3, 2},
  {1, 5, 2, 1},
  {6, 1, 1, 0}
}

t.moves = {3, 4}
-- 5924 movimientos diferentes!

return t
