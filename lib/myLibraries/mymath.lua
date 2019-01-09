mymath = {}

function mymath.nsin(x)
  return (math.sin(x) + 1) / 2
end

function mymath.sinRange(x, x1, x2)
  return mymath.nsin(x) * (x2 - x1) + x1
end

function mymath.ncos(x)
  return (math.cos(x) + 1) / 2
end

function mymath.cosRange(x, x1, x2)
  return mymath.ncos(x) * (x2 - x1) + x1
end

function mymath.hsv(h, s, v, a)
    if s <= 0 then return v,v,v end
    h, s, v = (h*255)/256*6, s, v
    local c = v*s
    local x = (1-math.abs((h%2)-1))*c
    local m,r,g,b = (v-c), 0,0,0
    if h < 1     then r,g,b = c,x,0
    elseif h < 2 then r,g,b = x,c,0
    elseif h < 3 then r,g,b = 0,c,x
    elseif h < 4 then r,g,b = 0,x,c
    elseif h < 5 then r,g,b = x,0,c
    else              r,g,b = c,0,x
    end return (r+m),(g+m),(b+m), a
end

return mymath
