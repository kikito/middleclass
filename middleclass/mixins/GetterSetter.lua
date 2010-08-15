-----------------------------------------------------------------------------------
-- GetterSetter.lua
-- Enrique García ( enrique.garcia.cota [AT] gmail [DOT] com ) - 11 Aug 2010
-- Small mixin for classes with getters and setters
-----------------------------------------------------------------------------------

--[[ Usage:

  require 'middleclass.mixins.GetterSetter' -- or 'middleclass.init'

  MyClass = class('MyClass')
  MyClass:include(GetterSetter)
  
  MyClass:getter('name', 'pete') -- default value
  MyClass:setter('age')
  MyClass:getterSetter('color', 'blue') -- default value

]]

assert(Object~=nil and class~=nil, 'MiddleClass not detected. Please require it before using GetterSetter')

GetterSetter = {}

function GetterSetter.getterFor(theClass, attr) return 'get' .. attr:gsub("^%l", string.upper) end
function GetterSetter.setterFor(theClass, attr) return 'set' .. attr:gsub("^%l", string.upper) end
function GetterSetter.getter(theClass, attributeName, defaultValue)
  theClass[theClass:getterFor(attributeName)] = function(self)
    if(self[attributeName]~=nil) then return self[attributeName] end
    return defaultValue
  end
end
function GetterSetter.setter(theClass, attributeName)
  theClass[theClass:setterFor(attributeName)] = function(self, value) self[attributeName] = value end
end
function GetterSetter.getterSetter(theClass, attributeName, defaultValue)
  theClass:getter(attributeName, defaultValue)
  theClass:setter(attributeName)
end
