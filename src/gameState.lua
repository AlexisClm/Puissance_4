local class = {}
local data

function class.getState()
  return data
end

function class.setState(state)
  data = state
end

return class