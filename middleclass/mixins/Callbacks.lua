-----------------------------------------------------------------------------------
-- Callbacks.lua
-- Enrique García ( enrique.garcia.cota [AT] gmail [DOT] com )
-- Mixin that adds callbacks support (i.e. beforeXXX or afterYYY) to classes)
-----------------------------------------------------------------------------------

--[[ Usage:

  MyClass = class('MyClass')
  MyClass:include(Callbacks)
  
  MyClass:addCallbacksAround('foo') -- this defines methods 'beforeFoo' and 'afterFoo'
  
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

--[[ holds all the callbacks entries.
     callback entries are just lists of methods to be called before / after some other method is called

  _callbackEntries = {
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
local _callbackEntries = {}

-- cache for not re-creating methods every time they are needed
local _methodCache = {}

-- private class methods

local function _getCallbackEntry(theClass, callbackName)
  if theClass==nil or callbackName==nil or _callbackEntries[theClass]==nil then return nil end
  return _callbackEntries[theClass][callbackName]
end

-- creates one of the "level 2" entries on callbacks, like beforeUpdate, afterupdate or update, above
local function _getOrCreateCallbackEntry(theClass, callbackName)
  if not theClass or not callbackName then return {} end
  _callbackEntries[theClass] = _callbackEntries[theClass] or {}
  local classEntries = _callbackEntries[theClass]
  classEntries[callbackName] = classEntries[callbackName] or {methods={}, before={}, after={}}
  
  local existingMethod = rawget(theClass.__classDict, callbackName)
  if(type(existingMethod) == 'function') then
    
  end

  return classEntries[callbackName]
end

-- returns all the methods that should be called when a callback is invoked, including superclasses
local function _getCallbackEntryChainMethods(theClass, callbackName)
  if theClass==nil then return {} end
  local methods = _getOrCreateCallbackEntry(theClass, callbackName).methods
  local superMethods = _getCallbackEntryChainMethods(theClass.superclass, callbackName)

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

  assert(theClass[callbackName]==nil, "Could not define " .. theClass.name .. '.'  .. callbackName .. ": already defined")
  
  theClass[callbackName] = function(theClass, ...)
    local methods = {...}
    local existingMethods = _getOrCreateCallbackEntry(theClass, callbackName).methods
    for _,method in ipairs(methods) do
      table.insert(existingMethods, method)
    end
  end

  _getOrCreateCallbackEntry(theClass, callbackName)

  return theClass[callbackName]
end

-- private instance methods

-- given a callback name (e.g. beforeUpdate), obtain all the methods that must be called and execute them
local function _runCallbackChain(object, callbackName)
  if callbackName==nil then return true end
  local methods = _getCallbackEntryChainMethods(object.class, callbackName)
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

-- given a class and a method, this returns a new version of that method that invokes callbacks
-- uses a cache for not calculating the methods every time
function _getChainedMethod(theClass, method, entry)
  _methodCache[theClass] = _methodCache[theClass] or {}
  local classCache = _methodCache[theClass]
  
  local chainedMethod = classCache[method]
  
  if(chainedMethod == nil) then
    chainedMethod = function(self, ...)
      for _,beforeCallbackName in ipairs(entry.before) do
        if _runCallbackChain(self, beforeCallbackName) == false then return false end
      end

      local result = method(self, ...)

      for _,afterCallbackName in ipairs(entry.after) do
        if _runCallbackChain(self, afterCallbackName) == false then return false end
      end

      return result
    end
    classCache[method] = chainedMethod
  end

  return chainedMethod
end

function _addCallbacks(theClass, before_or_after, methodName, callbackMethodName)
  assert(type(methodName)=='string', 'methodName must be a string')
  callbackMethodName = callbackMethodName or before_or_after .. methodName:gsub("^%l", string.upper)

  _defineCallbackMethod(theClass, callbackMethodName)

  local entry = _getOrCreateCallbackEntry(theClass, methodName)

  table.insert(entry[before_or_after], callbackMethodName)
end

--------------------------------
--      PUBLIC STUFF
--------------------------------

Callbacks = {}

function Callbacks:included(theClass)

  if includes(Callbacks, theClass) then return end

  -- Modify the instance indexes so they add callbacks to existing functions
    local mt = {
    __index = function(instance, methodName)
      local method = theClass.__classDict[methodName]
      if type(method) ~= 'function' then return method end
      
      local entry = _getCallbackEntry(theClass, methodName)
      if entry == nil then return method end

      return _getChainedMethod(theClass, method, entry)
    end
  }
  setmetatable(mt, { __index = theClass.__classDict })

  theClass.new = function(theClass, ...)
    local instance = setmetatable({ class = theClass }, mt)
    instance:initialize(...)
    return instance
  end
 
end

-- usage: Actor:addCallbacksBefore('update')
-- callbackMethodName is optional, defaulting to 'beforeUpdate'
function Callbacks.addCallbacksBefore(theClass, methodName, callbackMethodName)
  _addCallbacks(theClass, 'before', methodName, callbackMethodName)
end

-- usage: Actor:addCallbacksAfter('initialize')
-- callbackMethodName is optional, defaulting to 'afterInitialize'
function Callbacks.addCallbacksAfter(theClass, methodName, callbackMethodName)
  _addCallbacks(theClass, 'after', methodName, callbackMethodName)
end

-- usage: Actor:addCallbackAround('update')
-- before & afterCallbackMethodName are optional, defaulting to 'beforeUpdate' and 'afterUpdate'
function Callbacks.addCallbacksAround(theClass, methodName, beforeCallbackMethodName, afterCallbackMethodName)
  _addCallbacks(theClass, 'before', methodName, beforeCallbackMethodName)
  _addCallbacks(theClass, 'after', methodName, afterCallbackMethodName)
end
