-----------------------------------------------------------------------------------
-- MindState.lua
-- Enrique García ( enrique.garcia.cota [AT] gmail [DOT] com ) - 19 Oct 2009
-- Based on Unrealscript's stateful objects
-----------------------------------------------------------------------------------

require 'MiddleClass.lua'
--[[ StatefulObject declaration
  * Stateful classes have a list of states (accesible through class.states).
  * When a method is invoked on an instance of such classes, it is first looked up on the class current state (accesible through class.currentState)
  * If a method is not found on the current state, or if current state is nil, the method is looked up on the class itself
  * It is possible to change states by doing class:gotoState(stateName)
]]
StatefulObject = class('StatefulObject')

StatefulObject.states = {} -- the root state list

local private = setmetatable({}, {__mode = "k"})   -- weak table storing private references

-- Instance methods

--[[ constructor
  If your states need initialization, they can receive parameters via the initParameters parameter
  initParameters is a table with parameters used for initializing the states. These are needed mostly if
  your states have a custom superclass that needs parameters on their initialize() function.
]]
function StatefulObject:initialize(initParameters)
  super.initialize(self)
  initParameters = initParameters or {} --initialize to empty table if nil
  self.states = {}
  private[self] = {
    stateStack = {}
  }
  for stateName,stateClass in pairs(self.class.states) do 
    local state = stateClass:new(unpack(initParameters[stateName] or {}))
    state.name = stateName
    self.states[stateName] = state
  end
end

--[[ Changes the current state.
  If the current state has a method called onExitState, it will be called, with the instance as a parameter.
  If the "next" state exists and has a method called onExitState, it will be called, with the instance as a parameter.
  use gotoState(nil) for setting states to nothing
  This method invokes the exitState and enterState functions if they exist on the current state
  Second parameter is optional. If true, the stack will be conserved. Otherwise, it will be popped.
]]
function StatefulObject:gotoState(newStateName, keepStack)
  assert(self.states~=nil, "Attribute 'states' not detected. check that you called instance:gotoState and not instance.gotoState, and that you invoked super.initialize(self) in the constructor.")

  local prevState = self:getCurrentState()

  -- If we're trying to go to a state in which we already are, return (do nothing)
  if(prevState~=nil and prevState.name == newStateName) then return end

  local nextState
  if(newStateName~=nil) then
    nextState = self.states[newStateName]
    assert(nextState~=nil, "State '" .. newStateName .. "' not found")
  end

  -- Invoke exitState on the previous state
  if(prevState~=nil and type(prevState.exitState) == "function") then prevState.exitState(self, newStateName) end

  -- Empty the stack unless keepStack is true.
  if(keepStack~=true) then self:popAllStates() end

  -- replace the top of the stack with the new state
  local stack = private[self].stateStack
  stack[math.max(#stack,1)] = nextState

  -- Invoke enterState on the new state. 2nd parameter is the name of the previous state, or nil
  if(nextState~=nil and type(nextState.enterState) == "function") then
    nextState.enterState(self, prevState~=nil and prevState.name or nil)
  end
end

function StatefulObject:pushState(newStateName)
  assert(type(newState)=='string', "newStateName must be a string.")
  assert(self.states~=nil, "Attribute 'states' not detected. check that you called instance:pushState and not instance.pushState, and that you invoked super.initialize(self) in the constructor.")

  local nextState = self.states[newStateName]
  assert(nextState~=nil, "State '" .. newStateName .. "' not found")

  -- If we attempt to push a state and the state is already on return (do nothing)
  local stack = private[self].stateStack
  for _,state in ipairs(stack) do 
    if(state.name == newStateName) then return end
  end

  -- Invoke pausedState on the previous state
  local prevState = self:getCurrentState()
  if(prevState~=nil and type(prevState.pausedState) == "function") then prevState.pausedState(self) end

  -- Do the push
  table.insert(stack, nextState)

  -- Invoke pushState on the next state
  if(type(nextState.pushedState) == "function") then nextState.pushedState(self) end
  
  return nextState
end

-- If a state name is given, it will attempt to remove it from the stack. If not found on the stack it will do nothing.
-- If no state name is give, this pops the top state from the stack, if any. Otherwise it does nothing.
-- Callbacks will be called when needed.
function StatefulObject:popState(stateName)
  assert(self.states~=nil, "Attribute 'states' not detected. check that you called instance:popState and not instance.popState, and that you invoked super.initialize(self) in the constructor.")

  -- Invoke poppedState on the previous state
  local prevState = self:getCurrentState()
  if(prevState~=nil and type(prevState.poppedState) == "function") then prevState.poppedState(self) end

  -- Do the pop
  local stack = private[self].stateStack
  table.remove(stack, #stack)

  -- Invoke continuedState on the new state
  local newState = self:getCurrentState()
  if(newState~=nil and type(newState.continuedState) == "function") then newState.continuedState(self) end
  
  return newState
end

function StatefulObject:popAllStates()
  local state = self:popState()
  while(state~=nil) do state = self:popState() end
end

function StatefulObject:getCurrentState()
  local stack = private[self].stateStack
  if #stack == 0 then return nil end
  return(stack[#stack])
end

--[[
  Returns true if the object is in the state named 'stateName'
  If second(optional) parameter is true, this method returns true if the state is on the stack instead
]]
function StatefulObject:inState(stateName, testStateStack)
  local stack = private[self].stateStack

  if(testStateStack==true) then
    for _,state in ipairs(stack) do 
      if(state.name == stateName) then return true end
    end
  else --testStateStack==false
    local state = stack[#stack]
    if(state~=nil and state.name == stateName) then return true end
  end

  return false
end


-- Class methods

--[[ Adds a new state to the "states" class member.
  superState is optional. If nil, Object will be the parent class of the new state
  returns the newly created state
]]
function StatefulObject:addState(stateName, superState)
  assert(subclassOf(StatefulObject, self), "Use class:addState instead of class.addState")
  assert(self.states[stateName]==nil, "The class " .. self.name .. " already has a state called '" .. stateName)
  assert(type(stateName)=="string", "stateName must be a string")
  -- states are just regular classes. If superState is nil, this uses Object as superClass
  local state = class(stateName, superState)
  self.states[stateName] = state
  return state
end

-- These methods will not be overriden by the states.
local ignoredMethods = {
  states=1, initialize=1,
  gotoState=1, pushState=1, popState=1, popAllStates=1, getCurrentState=1, inState=1,
  enterState=1, exitState=1, pushedState=1, poppedState=1, pausedState=1, continuedState=1,
  addState=1, subclass=1, includes=1
}
local prevSubclass = StatefulObject.subclass
--[[ creates a stateful subclass
  Subclasses inherit all the states of their superclases, in a special way:
  If class A has a state called Sleeping and B = A.subClass('B'), then B.states.Sleeping is a subclass of A.states.Sleeping
  returns the newly created stateful class
]]
function StatefulObject:subclass(name)
  --assert(subclassOf(StatefulObject, self), "Use class:subclass instead of class.subclass")
  local theClass = prevSubclass(self, name) --for now, theClass is just a regular subclass
  
  --the states of the subclass are subclasses of the superclass' states
  theClass.states = {}
  for stateName,state in pairs(self.states) do 
    theClass:addState(stateName, state)
  end

  --make sure that the currentState is used on the method lookup function before looking on the class dict
  local classDict = theClass.__classDict
  classDict.__index = function(instance, methodName)
    -- If the method isn't on the 'ignoredMethods' list, look through the stack to see if it is defined
    if(ignoredMethods[methodName]~=1) then
      local stack = private[instance].stateStack
      local method
      for i = #stack,1,-1 do -- reversal loop
        method = stack[i][methodName]
        if(method~=nil) then return method end
      end
    end
    --if ignored or not found, look on the class itself
    return classDict[methodName]
  end

  return theClass
end


--[[ Include override for stateful classes.
     This is exactly like MiddleClass' include function, except that it module has a property called "states"
     then each member of that module.states is included on the StatefulObject class.
     If module.states has a state that doesn't exist on StatefulObject, a new state will be created.
]]
function StatefulObject:includes(module, ...)
  assert(subclassOf(StatefulObject, self), "Use class:includes instead of class.includes")
  for methodName,method in pairs(module) do
    if methodName ~="included" and methodName ~= "states" then
      self[methodName] = method
    end
  end
  if type(module.included)=="function" then module.included(self, ...) end
  if type(module.states)=="table" then
    for stateName,moduleState in pairs(module.states) do 
      local state = self.states[stateName]
      if(state==nil) then state = theClass:addState(stateName) end
      state:includes(moduleState, ...)
    end
  end
end
