-----------------------------------------------------------------------------------------------------------------------
-- middleclass.lua - v1.4 (2011-03)
-- Enrique García Cota - enrique.garcia.cota [AT] gmail [DOT] com
-- Based on YaciCode, from Julien Patte and LuaObject, from Sébastien Rocca-Serra
-----------------------------------------------------------------------------------------------------------------------

local _nilf = function() end -- empty function

local _classes = setmetatable({}, {__mode = "k"})   -- keeps track of all the tables that are classes

Object = { name = "Object", __mixins = {} }

Object.__classDict = {
  initialize = _nilf, destroy = _nilf, subclassed = _nilf,
  __tostring = function(instance) return ("instance of ".. instance.class.name) end, -- root of __tostring method,
  __metamethods = { '__add', '__call', '__concat', '__div', '__le', '__lt', 
    '__mod', '__mul', '__pow', '__sub', '__tostring', '__unm' 
  }
}
Object.__classDict.__index = Object.__classDict -- instances of Object need this

setmetatable(Object, { 
  __index = Object.__classDict,    -- look up methods in the classDict
  __newindex = Object.__classDict, -- any new Object methods will be defined in classDict
  __call = Object.new,             -- allows instantiation via Object()
  __tostring = function() return "class Object" end -- allows tostring(obj)
})

_classes[Object] = true -- register Object on the list of classes.

-- creates the instance based of the class, but doesn't initialize it
function Object.allocate(theClass)
  assert(_classes[theClass], "Use Class:allocate instead of Class.allocate")
  return setmetatable({ class = theClass }, theClass.__classDict)
end

-- both creates and initializes an instance
function Object.new(theClass, ...)
  local instance = theClass:allocate()
  instance:initialize(...)
  return instance
end

-- creates a subclass
function Object.subclass(theClass, name)
  assert(_classes[theClass], "Use Class:subclass instead of Class.subclass")
  assert( type(name)=="string", "You must provide a name(string) for your class")

  local theSubClass = { name = name, superclass = theClass, __classDict = {}, __mixins={} }
  
  local dict = theSubClass.__classDict   -- classDict contains all the [meta]methods of the class
  dict.__index = dict                    -- It "points to itself" so instances can use it as a metatable.
  local superDict = theClass.__classDict -- The superclass' classDict

  setmetatable(dict, superDict) -- when a method isn't found on classDict, 'escalate upwards'.

  setmetatable(theSubClass, {
    __index = dict,                              -- look for stuff on the dict
    __newindex = function(_, methodName, method) -- ensure that __index isn't modified by mistake
        assert(methodName ~= '__index', "Can't modify __index. Include middleclass-extras.Indexable and use 'index' instead")
        rawset(dict, methodName , method)
      end,
    __tostring = function() return ("class ".. name) end,      -- allows tostring(MyClass)
    __call = function(_, ...) return theSubClass:new(...) end  -- allows MyClass(...) instead of MyClass:new(...)
  })

  for _,mmName in ipairs(theClass.__metamethods) do -- Creates the initial metamethods
    dict[mmName]= function(...)           -- by default, they just 'look up' for an implememtation
      local method = superDict[mmName]    -- and if none found, they throw an error
      assert( type(method)=='function', tostring(theSubClass) .. " doesn't implement metamethod '" .. mmName .. "'" )
      return method(...)
    end
  end

  theSubClass.initialize = function(instance,...) theClass.initialize(instance, ...) end
  _classes[theSubClass]= true -- registers the new class on the list of _classes
  theClass:subclassed(theSubClass)   -- hook method. By default it does nothing

  return theSubClass
end

-- Mixin extension function - simulates very basically ruby's include. Receives a table table, probably with functions.
-- Its contents are copied to theClass, with one exception: the included() method will be called instead of copied
function Object.include(theClass, mixin, ... )
  assert(_classes[theClass], "Use class:include instead of class.include")
  assert(type(mixin)=='table', "mixin must be a table")
  for methodName,method in pairs(mixin) do
    if methodName ~="included" then theClass[methodName] = method end
  end
  if type(mixin.included)=="function" then mixin:included(theClass, ... ) end
  theClass.__mixins[mixin] = mixin
  return theClass
end

-- Returns true if aClass is a subclass of other, false otherwise
function subclassOf(other, aClass)
  if not _classes[aClass] or not _classes[other] then return false end
  if aClass.superclass==nil then return false end -- aClass is Object, or a non-class
  return aClass.superclass == other or subclassOf(other, aClass.superclass)
end

-- Returns true if obj is an instance of aClass (or one of its subclasses) false otherwise
function instanceOf(aClass, obj)
  if not _classes[aClass] or type(obj)~='table' or not _classes[obj.class] then return false end
  if obj.class==aClass then return true end
  return subclassOf(aClass, obj.class)
end

-- Returns true if the mixin has already been included on a class (or a superclass)
function includes(mixin, aClass)
  if not _classes[aClass] then return false end
  if aClass.__mixins[mixin]==mixin then return true end
  return includes(mixin, aClass.superclass)
end

-- Creates a new class named 'name'. Uses Object if no baseClass is specified.
function class(name, baseClass, ...)
  baseClass = baseClass or Object
  return baseClass:subclass(name, ...)
end
