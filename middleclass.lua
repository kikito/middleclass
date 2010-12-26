-----------------------------------------------------------------------------------------------------------------------
-- middleclass.lua - v1.2
-- Enrique García ( enrique.garcia.cota [AT] gmail [DOT] com ) - 19 Oct 2009
-- Based on YaciCode, from Julien Patte and LuaObject, from Sébastien Rocca-Serra
-----------------------------------------------------------------------------------------------------------------------

local _nilf = function() end -- empty function

local _classes = setmetatable({}, {__mode = "kv"})   -- weak table storing references to all declared classes

local _metamethods = { -- all metamethods except __index
  '__add', '__call', '__concat', '__div', '__le', '__lt', '__mod', '__mul', '__pow', '__sub', '__tostring', '__unm' 
}

Object = { name = "Object", __modules = {} }

Object.__classDict = {
  initialize = _nilf, destroy = _nilf, subclassed = _nilf,
  __tostring = function(instance) return ("instance of ".. instance.class.name) end -- root of __tostring method
}
Object.__classDict.__index = Object.__classDict -- instances of Object need this

setmetatable(Object, { 
  __index = Object.__classDict,    -- look up methods in the classDict
  __newindex = Object.__classDict, -- any new object methods will be defined in classDict
  __call = Object.new,             -- allows instantiation via Object()
  __tostring = function() return "class Object" end -- allows tostring(obj)
})

_classes[Object] = Object -- register Object on the list of classes.

-- creates a new instance
Object.new = function(theClass, ...)
  assert(_classes[theClass]~=nil, "Use class:new instead of class.new")

  local instance = setmetatable({ class = theClass }, theClass.__classDict)
  instance:initialize(...)
  return instance
end

-- creates a subclass
Object.subclass = function(theClass, name)
  assert(_classes[theClass]~=nil, "Use class:subclass instead of class.subclass")
  assert( type(name)=="string", "You must provide a name(string) for your class")

  local theSubClass = { name = name, superclass = theClass, __classDict = {}, __modules={} }
  
  local dict = theSubClass.__classDict   -- classDict contains all the [meta]methods of the class
  dict.__index = dict                    -- It "points to itself" so instances can use it as a metatable.
  local superDict = theClass.__classDict -- The superclass' classDict

  setmetatable(dict, superDict) -- when a method isn't found on classDict, 'escalate upwards'.

  for _,mmName in ipairs(_metamethods) do -- Creates the initial metamethods
    dict[mmName]= function(...)           -- by default, they just 'look up' for an implememtation
      local method = superDict[mmName]    -- and if none found, they throw an error
      assert( type(method)=='function', tostring(theSubClass) .. " doesn't implement metamethod '" .. mmName .. "'" )
      return method(...)
    end
  end

  setmetatable(theSubClass, {
    __index = dict,                              -- look for stuff on the dict
    __newindex = function(_, methodName, method) -- add 'super' to methods
        assert(methodName ~= '__index', "Can't modify __index. Include middleclass-extras.Indexable and use 'index' instead")
        if type(method) == 'function' then
          local fenv = getfenv(method)
          local newenv = setmetatable( {super = superDict},  {__index = fenv, __newindex = fenv} )
          setfenv( method, newenv )
        end
        rawset(dict, methodName , method)
      end,
    __tostring = function() return ("class ".. name) end,      -- allows tostring(MyClass)
    __call = function(_, ...) return theSubClass:new(...) end  -- allows MyClass(...) instead of MyClass:new(...)
  })

  theSubClass.initialize = function(instance,...) super.initialize(instance) end -- default initialize method
  _classes[theSubClass]= theSubClass -- registers the new class on the list of _classes
  theClass:subclassed(theSubClass)   -- hook method. By default it does nothing

  return theSubClass
end

-- Mixin extension function - simulates very basically ruby's include. Receives a table table, probably with functions.
-- Its contents are copied to theClass, with one exception: the included() method will be called instead of copied
Object.include = function(theClass, module, ... )
  assert(_classes[theClass]~=nil, "Use class:includes instead of class.includes")
  assert(type(module=='table'), "module must be a table")
  for methodName,method in pairs(module) do
    if methodName ~="included" then theClass[methodName] = method end
  end
  if type(module.included)=="function" then module:included(theClass, ... ) end
  theClass.__modules[module] = module
  return theClass
end

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
  if _classes[aClass]==nil then return false end
  if aClass.__modules[module]==module then return true end
  return includes(module, aClass.superclass)
end

-- Creates a new class named 'name'. Uses Object if no baseClass is specified. Additional parameters for compatibility
function class(name, baseClass, ...)
  baseClass = baseClass or Object
  return baseClass:subclass(name, ...)
end
