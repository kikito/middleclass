-----------------------------------------------------------------------------------
-- MiddleClass.lua
-- Enrique García ( enrique.garcia.cota [AT] gmail [DOT] com ) - 19 Oct 2009
-- Based on YaciCode, from Julien Patte and LuaObject, from Sébastien Rocca-Serra
-----------------------------------------------------------------------------------

-- The 'Object' class
Object = {
  name = "Object",
  superclass = nil,
  subclassOf = function(class, other) return false end, -- Object inherits from nothing
  __tostring = function(instance) return ("instance of ".. instance.class.name) end,

  -- Inverse of instance.instanceOf(class). This never fails - class.made(1) will return false,
  -- but 1.instanceOf(class) will return an error
  made = function(class, obj)
    if type(obj)~="table" or type(obj.class)~="table" then return false end
    local c = obj.class
    if c==class then return true end
    if type(c)~="table" or type(c.subclassOf)~="function" then return false end
    return c:subclassOf(class)
  end,

  -- create a new instance
  new = function (class, ...)
    local instance = setmetatable({ class = class }, class) -- the class is the instance's metatable
    instance:init(...)
    return instance
  end,

  -- creates a subclass
  subclass = function(superclass, name)
    if type(name)~="string" then name = "Unnamed" end
    
    local theClass = {
      name = name,
      superclass = superclass,
      subclassOf = function(class, other) return (superclass==other or superclass:subclassOf(other)) end
    }

    -- This may sound weird. Since:
    -- a) the class is the instances' metatable (so it must have an __index for looking up the methods) and
    -- b) The instance methods are in theClass, then ...
    theClass.__index = theClass

    -- additionally, set the metatable for theClass
    setmetatable(theClass, {
      __index = superclass, -- classes look up methods on their superclass
      __newindex = function(class, methodName, method) -- when adding new methods, include a "super" function
        if type(method) == 'function' then
          print('adding super to ' .. class.name .. '.' .. methodName)
          local superFunc = function(self, ...) 
            print(superclass.name .. '.' ..methodName)
            return superclass[methodName](self, ...)
          end
          local fenv = getfenv(method)
          local newenv = setmetatable({super = superFunc}, {__index = fenv, __newindex = fenv})
          method = setfenv(method, newenv)
        end
        rawset(class, methodName, method)
      end,
      __tostring = function() return ("class ".. name) end,
      __call = theClass.new
    })
    
    -- instance methods go after the setmetatable, so we can use "super"
    theClass.init = function(instance,...) super(self) end
    theClass.instanceOf = function(instance, class) return class:made(instance) end

    return theClass
  end,
  
  -- Mixin extension function - simulates very basically ruby's include(module)
  -- module is a lua table of functions. The functions will be copied to the class
  -- if present in the module, the included() method will be called
  includes = function(self, module)
    for methodName,method in pairs(module) do
      if methodName ~="included" then self[methodName] = method end
    end
    if type(module.included)=="function" then module:included(self) end
  end,

  -- end of the init() call chain
  init = function(instance, ...) end
}

setmetatable(Object, {
  __tostring = function() return ("class Object") end,
  __call = newInstance
})


function class(name, baseClass)
  baseClass = baseClass or Object
  return baseClass:subclass(name)
end
