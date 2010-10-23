-----------------------------------------------------------------------------------
-- MiddleClass.lua
-- Enrique García ( enrique.garcia.cota [AT] gmail [DOT] com ) - 19 Oct 2009
-- Based on YaciCode, from Julien Patte and LuaObject, from Sébastien Rocca-Serra
-----------------------------------------------------------------------------------

local _classes = setmetatable({}, {__mode = "k"})   -- weak table storing references to all declared _classes and their included modules

Object = { name = "Object" } -- The 'Object' class

_classes[Object] = { modules={} } -- adds Object to the list of _classes

  -- creates a new instance
Object.new = function(theClass, ...)
  assert(_classes[theClass]~=nil, "Use class:new instead of class.new")

  local instance = setmetatable({ class = theClass }, theClass.__classDict)
  instance:initialize(...)
  return instance
end

local _metamethods = { '__add', '__sub', '__mul', '__div', '__mod', '__pow', '__unm', 
                       '__lt', '__le', '__call', '__gc', '__tostring', '__concat' }

-- creates a subclass
Object.subclass = function(theClass, name)
  assert(_classes[theClass]~=nil, "Use class:subclass instead of class.subclass")
  assert( type(name)=="string", "You must provide a name(string) for your class")

  local theSubclass = { name = name, superclass = theClass, __classDict = {} }
  local classDict = theSubclass.__classDict

  -- classDict is the instances' metatable. It "points to himself" so they start looking for methods there.
  classDict.__index = classDict

  -- metamethods & methods are "looked up" through implementation and __index
  for _,m in ipairs(_metamethods) do
    classDict[m]= function(...)
      assert( type(theClass.__classDict[m])=='function', "Class " .. theSubclass.name .. " does not implement the " .. m .. " metamethod")
      return theClass.__classDict[m](...)
    end
  end
  setmetatable(classDict, {__index = theClass.__classDict})

  -- control how the new methods are inserted on the subclass, and how they are looked up
  setmetatable(theSubclass, {
    __index = function(_,methodName)
        -- search first on the subclass's classdict, then on the superclass
        return classDict[methodName]~= nil and classDict[methodName] or theClass[methodName]
      end,
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

  _classes[theSubclass]={ modules={} } --registers the new class on the list of _classes

  theClass:subclassed(theSubclass) -- hook method. By default it does nothing

  return theSubclass
end

-- Mixin extension function - simulates very basically ruby's include(module)
-- module is a lua table of functions. The functions will be copied to the class
-- if present in the module, the included() method will be called
Object.include = function(theClass, module, ... )
  assert(_classes[theClass]~=nil, "Use class:includes instead of class.includes")
  for methodName,method in pairs(module) do
    if methodName ~="included" then theClass[methodName] = method end
  end
  if type(module.included)=="function" then module:included(theClass, ... ) end
  _classes[theClass].modules[module] = true
  return theClass
end

-- built-in methods
Object.__classDict = {
  initialize = function(instance, ...) end, -- empty method
  destroy = function(instance) end, -- empty method
  __tostring = function(instance) return ("instance of ".. instance.class.name) end,
  subclassed = function(theClass, other) end -- empty method
}
Object.__classDict.__index = Object.__classDict -- instances of Object need this

-- This allows doing tostring(obj) and Object() instead of Object:new()
setmetatable(Object, { __index = Object.__classDict, __newindex = Object.__classDict,
  __tostring = function() return ("class Object") end,
  __call = Object.new
})

-- Returns true if aClass is a subclass of other, false otherwise
function subclassOf(other, aClass)
  if _classes[aClass]==nil or _classes[other]==nil then return false end
  if aClass.superclass==nil then return false end -- aClass is Object, or a non-class
  return aClass.superclass == other or subclassOf(other, aClass.superclass)
end

-- Returns true if obj is an instance of aClass (or one of its subclasses) false otherwise
function instanceOf(aClass, obj)
  if _classes[aClass]==nil or type(obj)~='table' or _classes[obj.class]==nil then return false end
  if obj.class==aClass then return true end
  return subclassOf(aClass, obj.class)
end

-- Returns true if the a module has already been included on a class (or a superclass of that class)
function includes(module, aClass)
  if _classes[aClass]==nil or _classes[aClass].modules==nil then return false end
  if _classes[aClass].modules[module] then return true end
  return includes(module, aClass.superclass)
end

-- Creates a new class named 'name'. Uses Object if no baseClass is specified. Additional parameters for compatibility
function class(name, baseClass, ...)
  baseClass = baseClass or Object
  return baseClass:subclass(name, ...)
end
