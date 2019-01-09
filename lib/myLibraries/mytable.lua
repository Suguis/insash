local mytable = {}

function mytable.merge(t1, t2)
  local t = {}
  for k, v in ipairs(t1) do
    table.insert(t, v)
  end
  for k, v in ipairs(t2) do
    table.insert(t, v)
  end
  return t
end

function mytable.copy(orig)
  function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
  end

  return deepcopy(orig)
end


return mytable
