-----------------------------------------------------------------------------------------------------------------------
-- middleclass.lua - v2.0 (2011-08)
-- Enrique Garcia Cota - enrique.garcia.cota [AT] gmail [DOT] com
-- Based on YaciCode, from Julien Patte and LuaObject, from Sebastien Rocca-Serra
-----------------------------------------------------------------------------------------------------------------------

local _classes = setmetatable({}, {__mode = "k"})

local function _initializeClass(klass, super)

  local dict = klass.__instanceDict

  if super then
    setmetatable(dict, { __index = super.__instanceDict })
    setmetatable(klass.static, { __index = function(_,k) return dict[k] or super[k] end })
  else
    setmetatable(klass.static, { __index = function(_,k) return dict[k] end })
  end

  setmetatable(klass, {
    __tostring = function() return "class " .. klass.name end,
    __index    = klass.static,
    __newindex = klass.__instanceDict,
    __call     = function(_, ...) return klass:new(...) end
  })

  _classes[klass] = true
end

Object = {
  name = "Object",
  static = {},
  __mixins = {},
  __instanceDict = {},
  __metamethods = { '__add', '__call', '__concat', '__div', '__le', '__lt', 
                    '__mod', '__mul', '__pow', '__sub', '__tostring', '__unm' }
}

_initializeClass(Object)

Object.initialize = function() end

function Object.static:allocate()
  assert(_classes[self], "Make sure that you are using 'Class:allocate' instead of 'Class.allocate'")
  return setmetatable({ class = self }, {__index = self.__instanceDict })
end

function Object.static:new(...)
  local instance = self:allocate()
  instance:initialize(...)
  return instance
end

function Object.static:subclass(name)
  assert(_classes[self], "Make sure that you are using 'Class:subclass' instead of 'Class.subclass'")
  assert(type(name) == "string", "You must provide a name(string) for your class")

  local subclass = { name = name, superclass = self, static = {}, __mixins = {}, __instanceDict={} }

  _initializeClass(subclass, self)

  return subclass
end

--[[

-- creates a subclass
function Object.subclass(klass, name)

  setmetatable(thesubclass, {
    __index = dict,                              -- look for stuff on the dict
    __newindex = function(_, methodName, method) -- ensure that __index isn't modified by mistake
        assert(methodName ~= '__index', "Can't modify __index. Include middleclass-extras.Indexable and use 'index' instead")
        rawset(dict, methodName , method)
      end,
    __tostring = function() return ("class ".. name) end,      -- allows tostring(MyClass)
    __call = function(_, ...) return thesubclass:new(...) end  -- allows MyClass(...) instead of MyClass:new(...)
  })

  for _,mmName in ipairs(klass.__metamethods) do -- Creates the initial metamethods
    dict[mmName]= function(...)           -- by default, they just 'look up' for an implememtation
      local method = superDict[mmName]    -- and if none found, they throw an error
      assert( type(method)=='function', tostring(thesubclass) .. " doesn't implement metamethod '" .. mmName .. "'" )
      return method(...)
    end
  end

  thesubclass.initialize = function(instance,...) klass.initialize(instance, ...) end
  _classes[thesubclass]= true -- registers the new class on the list of _classes
  klass:subclassed(thesubclass)   -- hook method. By default it does nothing

  return thesubclass
end

-- Mixin extension function - simulates very basically ruby's include. Receives a table table, probably with functions.
-- Its contents are copied to klass, with one exception: the included() method will be called instead of copied
function Object.include(klass, mixin, ... )
  assert(_classes[klass], "Use class:include instead of class.include")
  assert(type(mixin)=='table', "mixin must be a table")
  for methodName,method in pairs(mixin) do
    if methodName ~="included" then klass[methodName] = method end
  end
  if type(mixin.included)=="function" then mixin:included(klass, ... ) end
  klass.__mixins[mixin] = mixin
  return klass
end

-- Returns true if the mixin has already been included on a class (or a super)
function includes(mixin, aClass)
  if not _classes[aClass] then return false end
  if aClass.__mixins[mixin]==mixin then return true end
  return includes(mixin, aClass.super)
end

]]

function class(name, super, ...)
  super = super or Object
  return super:subclass(name, ...)
end

function instanceOf(aClass, obj)
  if not _classes[aClass] or type(obj) ~= 'table' or not _classes[obj.class] then return false end
  if obj.class == aClass then return true end
  return subclassOf(aClass, obj.class)
end

function subclassOf(other, aClass)
  if not _classes[aClass] or not _classes[other] or  aClass.superclass == nil then return false end
  return aClass.superclass == other or subclassOf(other, aClass.superclass)
end


