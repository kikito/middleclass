-----------------------------------------------------------------------------------
-- Invoker.lua
-- Enrique García ( enrique.garcia.cota [AT] gmail [DOT] com ) - 4 Mar 2010
-- Helper function that simplifies method invocation via method names or functions
-----------------------------------------------------------------------------------

--[[ Usage:

  require 'middleclass.mixins.Invoker' -- or 'middleclass.init'

  MyClass = class('MyClass')
  MyClass:includes(Invoker)
  function MyClass:foo(x,y) print('foo executed with params', x, y) end

  local obj = MyClass:new()

  obj:invoke('foo', 1,2) -- foo executed with params 1 2
  obj:invoke( function(self, x, y)
    print('nameless function executed with params', x, y)
  , 3, 4) -- nameless function executed with params 3, 4
  
  Note that the function first parameter will allways be self
]]

assert(Object~=nil and class~=nil, 'MiddleClass not detected. Please require it before using Beholder')

Invoker = {

  invoke = function(self, methodOrName, ...)
    local method = methodOrName
    if(type(methodOrName)=='string') then method = self[methodOrName] end
    assert(type(method)=='function', 'Invoker:invoke requires a function or function name')
    return method(self, ...)
  end

}


