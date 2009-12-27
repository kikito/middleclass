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

-- Instance methods

--[[ constructor
  If your states need initialization, they can receive parameters via the initParameters parameter
  initParameters is a table with parameters used for initializing the states. These are needed mostly if
  your states have a custom superclass that needs parameters on their initialize() function.
]]
function StatefulObject:initialize(initParameters)
  super(self)
  initParameters = initParameters or {} --initialize to empty table if nil
  self.states = {}
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
]]
function StatefulObject:gotoState(stateName)
  assert(self.states~=nil, "Attribute 'states' not detected. check that you called instance:gotoState and not instance.gotoState, and that you invoked super(self) in the constructor.")

  local nextState = self.states[stateName]
  assert(type(stateName)=='string' and nextState~=nil, "State '" .. stateName .. "' not found")

  local prevState = self.currentState
  if(prevState~=nil and type(prevState.exitState) == "function") then
    prevState.exitState(self)
  end

  self.previousState = prevState
  self.currentState = nextState

  if(nextState~=nil and type(nextState.enterState) == "function") then
    nextState.enterState(self)
  end
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

do --create an environment to keep the following variables local
  local ignoredMethods = {states=1, initialize=1, gotoState=1, addState=1, subclass=1, includes=1, exitState=1, enterState=1}
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
    classDict.__index = function(instance, method)
      --first look on the current state
      local currentState = rawget(instance, 'currentState')
      if( currentState~=nil and
          currentState[method]~=nil and
          ignoredMethods[method]==nil) then
        return currentState[method]
      else
      --if not found, look on the class itself
        return classDict[method]
      end
    end

    return theClass
  end
end -- end of the environment to keep ignoredMethods local

--[[ Include override for stateful classes.
     This is exactly like MiddleClass' include function, except that it module has a property called "states"
     then each member of that module.states is included on the StatefulObject class.
     If module.states has a state that doesn't exist on StatefulObject, a new state will be created.
]]
function StatefulObject:includes(module)
  assert(subclassOf(StatefulObject, self), "Use class:includes instead of class.includes")
  for methodName,method in pairs(module) do
    if methodName ~="included" and methodName ~= "states" then
      self[methodName] = method
    end
  end
  if type(module.included)=="function" then module:included(self) end
  if type(module.states)=="table" then
    for stateName,moduleState in pairs(module.states) do 
      local state = self.states[stateName]
      if(state==nil) then state = theClass:addState(stateName) end
      state:includes(moduleState)
    end
  end
end
