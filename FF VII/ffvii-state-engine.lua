-- base state
State = {}

function State:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function State:getPriority()
  return -1
end

function State:needToRun(game_context, bot_context)
  return false
end

function State:writeText(game_context, bot_context)
end

function State:run(game_context, bot_context)
end

-- state engine
StateEngine = {}

function StateEngine:new(states)
  local o = { _states = {} }
  setmetatable(o, { __index = StateEngine })

  for k, v in pairs(states) do
    o:addState(unpack(v))
  end
  
  return o
end

function StateEngine:addState(priority, state)
  self._states = self._states or {}
  self._states[#self._states+1] = { priority = priority, state = state }
end

function StateEngine:getStateToRun(game_context, bot_context, keys)
  -- loop through the states in descending priority order to find the appropriate state to run
  for index,state in spairs(self._states, function(t, a, b) return t[a].priority > t[b].priority end) do
    if state.state:needToRun(game_context, bot_context, keys) then
      return state.state
    end
  end
  
  return nil
end

function StateEngine:run(game_context, bot_context, keys)
  local state_to_run = self:getStateToRun(game_context, bot_context, keys)
  if state_to_run ~= nil then
    --state_to_run:writeText(game_context, bot_context)
    
    if not game_context.is_something_happening then
      state_to_run:run(game_context, bot_context, keys)
    end
  end
end
