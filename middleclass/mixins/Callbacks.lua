-----------------------------------------------------------------------------------
-- Callbacks.lua
-- Enrique García ( enrique.garcia.cota [AT] gmail [DOT] com )
-- Mixin that adds callbacks support (i.e. beforeXXX or afterYYY) to classes)
-----------------------------------------------------------------------------------

--[[ Usage:

  MyClass = class('MyClass')
  MyClass:include(Callbacks)
  
  MyClass:defineCallbacks('foo', 'beforeFoo', 'afterFoo')
  
  MyClass:beforeFoo('bar') -- can use either method names or functions
  MyClass:afterFoo(function() print('baz') end)
  
  function MyClass:foo() print 'foo' end
  function MyClass:bar() print 'bar' end
  
  local obj = MyClass:new()
  
  obj:foo() -- prints 'bar foo baz'
]]

--------------------------------
--      PRIVATE STUFF
--------------------------------

--[[ holds all the callbacks; callbacks are just lists of methods

  _callbacks = {
    Actor = {
      beforeUpdate = { methods = {m1, m2, m3 } }, -- m1, m2, m3 & m4 can be method names or functions
      afterUpdate = { methods = { 'm4' } },
      update = {
        before = { 'beforeUpdate' },
        after = { 'afterUpdate' }
      }
    }
  }

]]
local _callbacks = {} 

-- private class methods

local function _getCallback(theClass, callbackName)
  if theClass==nil or callbackName==nil or _callbacks[theClass]==nil then return nil end
  return _callbacks[theClass][callbackName]
end

-- creates one of the "level 2" entries on callbacks, like beforeUpdate, afterupdate or update, above
local function _getOrCreateCallback(theClass, callbackName)
  if not theClass or not callbackName then return {} end
  _callbacks[theClass] = _callbacks[theClass] or {}
  local classCallbacks = _callbacks[theClass]
  classCallbacks[callbackName] = classCallbacks[callbackName] or {methods={}, before={}, after={}}
  
  local existingMethod = rawget(theClass.__classDict, callbackName)
  if(type(existingMethod) == 'function') then
    
  end

  return classCallbacks[callbackName]
end

-- returns all the methods that should be called when a callback is invoked, including superclasses
local function _getCallbackChainMethods(theClass, callbackName)
  if theClass==nil then return {} end
  local methods = _getOrCreateCallback(theClass, callbackName).methods
  local superMethods = _getCallbackChainMethods(theClass.superclass, callbackName)

  local result = {}
  for i,method in ipairs(methods) do result[i]=method end
  for _,method in ipairs(superMethods) do table.insert(result, method) end

  return result
end

-- defines a callback method. These methods are used to add "methods" to the callback.
-- for example, after calling _defineCallbackMethod(Actor, 'afterUpdate') you can then do
-- Actor:afterUpdate('removeFromList', 'dance', function(actor) actor:doSomething() end)
local function _defineCallbackMethod(theClass, callbackName)
  if callbackName == nil then return nil end
  
  print('defining callbackMethod' , theClass.name, callbackName)

  assert(theClass[callbackName]==nil, "Could not define " .. theClass.name .. '.'  .. callbackName .. ": already defined")
  
  theClass[callbackName] = function(theClass, ...)
    local methods = {...}
    local existingMethods = _getOrCreateCallback(theClass, callbackName).methods
    for _,method in ipairs(methods) do
      print('inserting', method, 'in', theClass.name, callbackName)
      table.insert(existingMethods, method)
    end
    print(#existingMethods)
  end

  _getOrCreateCallback(theClass, callbackName)

  return theClass[callbackName]
end

-- private instance methods

-- given a callback name (e.g. beforeUpdate), obtain all the methods that must be called and execute them
local function _runCallbackChain(object, callbackName)
  if callbackName==nil then return true end
  local methods = _getCallbackChainMethods(object.class, callbackName)
  for _,method in ipairs(methods) do
    if type(method)=='string' then
      local methodName = method
      method = object[methodName]
      assert(type(method) == 'function', methodName .. ' is not the name of an existing method of ' .. object.class.name)
    end

    assert(type(method) == 'function', "callbacks can only be functions or valid method names")

    if method(object) == false then return false end
  end
  return true
end

local function _insertCallbacksDict(theClass)
  local classDict = theClass.__classDict
  local classDictMetatable = getmetatable(classDict)
  local callbacksDict = {}
  setmetatable(callbacksDict, { classDictMetatable.__index })
  classDictMetatable.__index = callbacksDict
  rawset(theClass, '__callbacksDict', callbacksDict)
end

local function _addToCallbacksDict(theClass, methodName, method)

  if type(method) ~= 'function' then return method end

  local callback = _getCallback(theClass, methodName)
  if callback == nil then return method end
  
  local existingMethod = rawget(theClass.__callbacksDict, methodName)
  if(type(existingMethod)=='function') then return existingMethod end

  -- newMethod surrounds regularMethod with before and after callbacks
  -- notice that the execution is cancelled if any callback returns false
  local newMethod = function(self, ...)

    for _,beforeCallbackName in ipairs(callback.before) do
      if _runCallbackChain(self, beforeCallbackName) == false then return false end
    end

    local result = method(self, ...)

    for _,afterCallbackName in ipairs(callback.after) do
      if _runCallbackChain(self, afterCallbackName) == false then return false end
    end

    return result
  end

  rawset(theClass.__classDict, methodName, nil)
  rawset(theClass.__callbacksDict, methodName, newMethod)

  return newMethod

end

--------------------------------
--      PUBLIC STUFF
--------------------------------

Callbacks = {}

function Callbacks:included(theClass)

  if includes(Callbacks, theClass) then return end

  -- 1. Subclassing must create a __callbacksDict attribute
  rawset(theClass, '__callbacksDict', {})
  local originalSubclass = theClass.subclass
  theClass.subclass = function(theClass, name, ...)
    local theSubClass = originalSubclass(theClass, name, ...)
    _rawset(theSubClass, __callbacksDict, {})
    return theSubClass
  end

  -- 2. Make inherited methods receive callbacks
  local mt = getmetatable(theClass.__classDict)
  local prevIndex = mt.__index
  
  mt.__index = function(t,methodName)
    return _addToCallbacksDict(theClass, methodName, prevIndex[methodName])
  end

  -- 3. New methods should handle callbacks
  local mt = getmetatable(theClass)
  local originalNewIndex = mt.__newindex

  mt.__newindex = function(_, methodName, method)
    rawset(theClass.__classDict, methodName, nil)
    rawset(theClass.__callbacksDict, methodName, nil)
    -- start by inserting a modified version of method with a "super" variable
    originalNewIndex(_, methodName, method)
    -- then, if callbacks exist for that method, give it special treatment
    _addToCallbacksDict(theClass, methodName, theClass.__classDict[methodName])
  end
 
end

-- usage: Actor:defineCallbacks('update', 'beforeUpdate', 'afterUpdate')
function Callbacks.defineCallbacks(theClass, methodName, beforeName, afterName)
  assert(type(methodName)=='string', 'methodName must be a string')
  assert(type(beforeName)=='string' or type(afterName)=='string', 'at least one of beforeName or afterName must be a string')

  _defineCallbackMethod(theClass, beforeName)
  _defineCallbackMethod(theClass, afterName)

  local methodCallback = _getOrCreateCallback(theClass, methodName)

  if(beforeName) then table.insert(methodCallback.before, beforeName) end
  if(afterName) then table.insert(methodCallback.after, afterName) end
  
  _addToCallbacksDict(theClass, methodName)

end
