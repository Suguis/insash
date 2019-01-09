local t = {}
t.init = {x = 3, y = 0}
t.layout = {}

t.layout[1] = {
  {1, 5, 1, 0},
  {0, 1, 6, 0},
}

t.moves = {2, 3}

t.message = "You need to destroy all colored blocks to pass to the next area"

return t
