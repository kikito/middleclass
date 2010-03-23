-----------------------------------------------------------------------------------
-- MiddleClass.lua
-- Enrique García ( enrique.garcia.cota [AT] gmail [DOT] com ) - 19 Oct 2009
-- Based on YaciCode, from Julien Patte and LuaObject, from Sébastien Rocca-Serra
-----------------------------------------------------------------------------------

local _classes = setmetatable({}, {__mode = "k"})   -- weak table storing references to all declared _classes

-- The 'Object' class
Object = { name = "Object" }

_classes[Object]=Object -- adds Object to the list of _classes

  -- creates a new instance
Object.new = function(theClass, ...)
  assert(_classes[theClass]~=nil, "Use class:new instead of class.new")

  local instance = setmetatable({ class = theClass }, theClass.__classDict) -- the class dictionary is the instance's metatable
  instance:initialize(...)
  return instance
end

-- creates a subclass
Object.subclass = function(theClass, name)
  assert(_classes[theClass]~=nil, "Use class:subclass instead of class.subclass")
  if type(name)~="string" then name = "Unnamed" end

  local theSubclass = { name = name, superclass = theClass, __classDict = {} }
  local classDict = theSubclass.__classDict

  -- This one is weird. Since:
  -- a) the class dict is the instances' metatable (so it must have an __index for looking up the methods) and
  -- b) The instance methods are in the class dict itself, then ...
  classDict.__index = classDict
  -- if a method isn't found on the class dict, look on its super class
  setmetatable(classDict, {__index = theClass.__classDict} )

  setmetatable(theSubclass, {   -- theSubclass' metamethods
    __index = function(_,methodName)
        local localMethod = classDict[methodName] -- this allows using classDic as a class method AND instance method dict
        if localMethod ~= nil then return localMethod end
        return theClass[methodName]
      end,
    -- FIXME add support for __index method here
    __newindex = function(_, methodName, method) -- when adding new methods, include a "super" function
        if type(method) == 'function' then
          local fenv = getfenv(method)
          local newenv = setmetatable( {super = theClass.__classDict},  {__index = fenv, __newindex = fenv} )
          setfenv( method, newenv )
        end
        rawset(classDict, methodName, method)
      end,
    __tostring = function() return ("class ".. name) end,
    __call = function(_, ...) return theSubclass:new(...) end
  })
  -- instance methods go after the setmetatable, so we can use "super"
  theSubclass.initialize = function(instance,...) super.initialize(instance) end

  _classes[theSubclass]=theSubclass --registers the new class on the list of _classes

  return theSubclass
end

-- Mixin extension function - simulates very basically ruby's include(module)
-- module is a lua table of functions. The functions will be copied to the class
-- if present in the module, the included() method will be called
Object.includes = function(theClass, module, ... )
  assert(_classes[theClass]~=nil, "Use class:includes instead of class.includes")
  for methodName,method in pairs(module) do
    if methodName ~="included" then theClass[methodName] = method end
  end
  if type(module.included)=="function" then module:included(theClass, ... ) end
end

-- root of initialize and __tostring methods
Object.__classDict = {
  initialize = function(instance, ...) end,   -- end of the initialize() call chain
  __tostring = function(instance) return ("instance of ".. instance.class.name) end
}

-- This allows doing tostring(obj) and Object() instead of Object:new()
setmetatable(Object, { __index = Object.__classDict, __newindex = Object.__classDict,
  __tostring = function() return ("class Object") end,
  __call = Object.new
})

-- Getter/Setter related methods
function Object.getterFor(theClass, attr) return 'get' .. attr:gsub("^%l", string.upper) end
function Object.setterFor(theClass, attr) return 'set' .. attr:gsub("^%l", string.upper) end
function Object.getter(theClass, attributeName, defaultValue)
  theClass[theClass:getterFor(attributeName)] = function(self) 
    if(self[attributeName]~=nil) then return self[attributeName] end
    return defaultValue
  end
end
function Object.setter(theClass, attributeName)
  theClass[theClass:setterFor(attributeName)] = function(self, value) self[attributeName] = value end
end
function Object.getterSetter(theClass, attributeName, defaultValue)
  theClass:getter(attributeName, defaultValue)
  theClass:setter(attributeName)
end

-- Returns true if aClass is a subclass of other, false otherwise
function subclassOf(other, aClass)
  if aClass == nil or other==nil then return false end
  if aClass.superclass==nil then return false end -- aClass is Object, or a non-class
  return aClass.superclass == other or subclassOf(other, aClass.superclass)
end

-- Returns true if obj is an instance of aClass (or one of its subclasses) false otherwise
function instanceOf(aClass, obj)
  if obj==nil or _classes[aClass]==nil or _classes[obj.class]==nil then return false end
  if obj.class==aClass then return true end
  return subclassOf(aClass, obj.class)
end

-- Creates a new class named 'name'. It uses baseClass as the parent (Object if none specified)
function class(name, baseClass)
  baseClass = baseClass or Object
  return baseClass:subclass(name)
end
