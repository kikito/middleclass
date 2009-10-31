-----------------------------------------------------------------------------------
-- MiddleClass.lua
-- Enrique García ( enrique.garcia.cota [AT] gmail [DOT] com ) - 19 Oct 2009
-- Based on YaciCode, from Julien Patte and LuaObject, from Sébastien Rocca-Serra
-----------------------------------------------------------------------------------

do

-- returns a copy of table t (shallow copy: only level 1 is copied, non-recursive)
local function duplicate(origin, destination, keys)
  -- no keys provided - duplicate all keys
  if keys==nil then for key,value in pairs(origin) do destination[key] = value end
  else for _,key in pairs(keys) do destination[key] = origin[key] end
  end
  return destination
end

-----------------------------------------------------------------------------------
-- The 'Object' class
Object = {
  name = "Object",
  superClass = nil,
  subClassOf = function(class, other) return false end, -- Object inherits from nothing

  made = function(class, obj)
    if type(obj)~="table" or type(obj.class)~="table" then return false end
    local c = obj.class
    if c==class then return true end
    if type(c)~="table" or type(c.subClassOf)~="function" then return false end
    return c:subClassOf(class)
  end,

  new = function (class, ...)
    local instance = setmetatable({ class = class }, { __index = class.instanceMethods })
    instance:init(...)
    return instance
  end,
  
  subClass = function(baseClass, name)
    if type(name)~="string" then name = "Unnamed" end
    
    local theClass = {
      name = name,
      superClass = baseClass,
      subClassOf = function (class, other) return (baseClass==other or baseClass:subClassOf(other)) end,
      instanceMethods = {}
    }

    duplicate(baseClass, theClass, {'includes', 'new', 'made', 'subClass'})

    duplicate(baseClass.instanceMethods, theClass.instanceMethods, {
      '__add', '__call', '__concat', '__div', '__eq', '__le', '__len', '__lt',
      '__mod', '__mul', '__pow', '__sub', '__tostring', '__unm'
    })
    
    setmetatable(theClass.instanceMethods, {__index = baseClass}) -- if a method is not found on instanceMethods, look on baseClass

    setmetatable(theClass, {
      __index = theClass.instanceMethods, -- if a method is not found, look on "instanceMethods"
      __newindex = function(class, methodName, method) -- add new items to the "instanceMethods" attribute, building "super" at the same time
        if type(method) == 'function' then
          local superMethod = function(self, ...) return baseClass.instanceMethods[methodName](self, ...) end
          local fenv = getfenv(method)
          local newEnv = setmetatable( { super = superMethod }, {__index = fenv, __newindex = fenv} )
          setfenv( method, newEnv )
        end
        rawset(class.instanceMethods, methodName, method)
      end,
      __tostring = function() return ("class ".. name) end,
      __call = newInstance
    })
    
    theClass.instanceMethods.init = function (instance,...) super(self) end

    return theClass
  end,
  
  -- Extension function - similar to ruby's include for modules
  -- adds the methods of t to the class
  -- will invoke the included method if present
  includes = function(self, t)
    duplicate(t, self)
    if t.included~=nil then t:included(self) end
  end
}

Object.instanceMethods = {
  init = function(instance, ...) end
}

setmetatable(Object.instanceMethods, {
  __tostring = function (instance) return ("a ".. instance.class.name) end
})

setmetatable(Object, {
  __tostring = function() return ("class Object") end,
  __call = newInstance
})

----------------------------------------------------------------------
-- function 'class'
function class(name, baseClass)
  baseClass = baseClass or Object
  return baseClass:subClass(name)
end

end
-- end of code
