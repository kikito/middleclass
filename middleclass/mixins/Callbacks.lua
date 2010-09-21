-----------------------------------------------------------------------------------
-- Callbacks.lua
-- Enrique García ( enrique.garcia.cota [AT] gmail [DOT] com )
-- Mixin that adds callbacks support (i.e. beforeXXX or afterYYY) to classes)
-----------------------------------------------------------------------------------

assert(Object~=nil and class~=nil, 'MiddleClass not detected. Please require it before using Callbacks')
assert(Sender~=nil, 'The Callbacks module requires the Sender module in order to work. Please require Sender before requiring Callbacks')

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
        before = 'beforeUpdate',
        after = 'afterUpdate'
      }
    }
  }

]]
local _callbackEntries = setmetatable({}, {__mode = "k"}) -- weak table

-- cache for not re-creating methods every time they are needed
local _methodCache = setmetatable({}, {__mode = "k"})

-- private class methods

local function _getCallbackEntry(theClass, callbackName)
  if theClass==nil or callbackName==nil or _callbackEntries[theClass]==nil then return nil end
  return _callbackEntries[theClass][callbackName]
end

-- creates one of the "level 2" entries on callbacks, like beforeUpdate or afterupdate, above
local function _getOrCreateCallbackEntry(theClass, callbackName)
  if not theClass or not callbackName then return {} end
  _callbackEntries[theClass] = _callbackEntries[theClass] or setmetatable({}, {__mode = "k"})
  local classEntries = _callbackEntries[theClass]
  classEntries[callbackName] = classEntries[callbackName] or setmetatable({ methods={} }, {__mode = "k"}) 

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

-- given a callback entry, obtain all the methods that must be called for that callback and execute them
local function _runCallbackChain(object, entry, before_or_after)
  if entry == nil then return true end
  callbackName = entry[before_or_after]
  if callbackName==nil then return true end
  local methods = _getCallbackEntryChainMethods(object.class, callbackName)
  for _,method in ipairs(methods) do
    if Sender.send(object, method) == false then return false end
  end
  return true
end

-- given a class and a method, this returns a new version of that method that invokes callbacks
-- uses a cache for not calculating the methods every time
function _getChainedMethod(theClass, methodName, method)
  local entry = _getCallbackEntry(theClass, methodName)

  if(entry==nil) then return method end

  _methodCache[theClass] = _methodCache[theClass] or setmetatable({}, {__mode = "k"})
  local classCache = _methodCache[theClass]
  
  local chainedMethod = classCache[methodName]
  
  if chainedMethod == nil then
    chainedMethod = function(self, ...)
      if _runCallbackChain(self, entry, 'before') == false then return false end
      local result = method(self, ...)
      if _runCallbackChain(self, entry, 'after') == false then return false end
      return result
    end
    classCache[methodName] = chainedMethod
  end

  return chainedMethod
end

-- helper function used by addCallbacksBefore, after and around
function _addCallbacks(theClass, before_or_after, methodName, callbackMethodName)
  assert(type(methodName)=='string', 'methodName must be a string')
  assert(before_or_after == 'before' or before_or_after == 'after', 'Parameter must be "before" or "after"')

  local entry = _getOrCreateCallbackEntry(theClass, methodName)

  assert(entry[before_or_after] == nil, 'The "' .. tostring(before_or_after) .. '" callback is already defined as "' .. tostring(entry[before_or_after]) .. '". Use that callback method instead or adding a new one' )
  callbackMethodName = callbackMethodName or before_or_after .. methodName:gsub("^%l", string.upper)

  _defineCallbackMethod(theClass, callbackMethodName)

  entry[before_or_after]= callbackMethodName
end

--------------------------------
--      PUBLIC STUFF
--------------------------------

Callbacks = {}

function Callbacks:included(theClass)

  if includes(Callbacks, theClass) then return end

  -- Modify the instances __index metamethod so it adds callback chains to methods with callback entries

  local oldNew = theClass.new
  
  theClass.new = function(theClass, ...)
    local instance = oldNew(theClass, ...)

    local prevIndex = getmetatable(instance).__index
    local tIndex = type(prevIndex)

    setmetatable(instance, {
      __index = function(instance, methodName)
        local method

        if     tIndex == 'table'    then method = prevIndex[methodName]
        elseif tIndex == 'function' then method = prevIndex(instance, methodName)
        end

        if type(method) ~= 'function' then return method end

        return _getChainedMethod(theClass, methodName, method)
      end
    })

    -- special treatment for afterInitialize callbacks
    local entry = _getCallbackEntry(theClass, 'initialize')
    if _runCallbackChain(instance, entry, 'after') == false then return false end

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
