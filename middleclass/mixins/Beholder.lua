-----------------------------------------------------------------------------------
-- Beholder.lua
-- Enrique García ( enrique.garcia.cota [AT] gmail [DOT] com ) - 4 Mar 2010
-- Small framework for event observers
-----------------------------------------------------------------------------------

assert(Object~=nil and class~=nil, 'MiddleClass not detected. Please require it before using Callbacks')
assert(Sender~=nil, 'The Beholder module requires the Sender module in order to work. Please require Sender before requiring Beholder')


--[[ Usage:

  require 'middleclass.mixins.Beholder' -- or 'middleclass.init'

  MyClass = class('MyClass')
  MyClass:includes(Beholder)
  function MyClass:foo(x,y) ... end
  
  local obj = MyClass:new()
  
  -- when the 'newgame' event is fired, call method foo with parameters 100 and 200
  obj:observe('newgame', 'foo', 100, 200)
  
  -- you can add more than one callbacks to the same event:
  obj:observe('newgame', 'foo', 300, 400)
  
  -- alternatively, use a function
  obj:observe('endgame', function(myself) myself.blah = 0 end)
  
  -- trigger the event:
  Beholder.trigger('newgame')
  
  -- stop observing an event:
  obj:stopObserving('newgame')


]]

--------------------------------
--    PRIVATE NODE CLASS
--------------------------------

local Node = class('Node')

function Node:initialize()
  super.initialize(self)
  self.children = {}
  self.objects=setmetatable({}, {__mode='k'})
end

function Node:getOrCreateChild(key)
  local child = self.children[key]
  if child == nil then
    child = Node:new()
    child.parent = self
    self.children[key] = child
  end
  return child
end

function Node:getOrCreateDescendant(key)
  if type(key) ~= 'table' then return self:getOrCreateChild(key) end
  local node = self
  for _,v in ipairs(key) do node = node:getOrCreateChild(v) end
  return node
end

function Node:getDescendant(key)
  if type(key) ~= 'table' then return self.children[key] end
  local node = self
  for _,v in ipairs(key) do
    node = node.children[v]
    if node == nil then return nil end
  end
  return node
end

function Node:getOrRegisterObject(object)
  self.objects[object] = self.objects[object] or {}
  return self.objects[object]
end

function Node:addAction(object, method, ...)
  local actions = self:getOrRegisterObject(object)
  table.insert(actions, { method = method, params = {...} })
end

function Node:removeAction(object, method)
  if method == nil then self.objects[object] = nil end
  local actions = self.objects[object]
  if actions==nil then return end

  local index = 1
  for i,v in ipairs(actions) do
    if v == method then index = i break end
  end

  if(index~=nil) then table.remove(actions, index) end
end


-- Private variable storing the list of event callbacks that can be used
--[[ structure:
  _root = {                      -- root node
    children = 
      'a' = {                    -- root->a node
        children = {
          'b' = {                -- root->a->b node
            children = {},
            objects = {          -- list of objects registered on node root->a->b
              obj1 = {           -- list of actions to perform on object1
                { method = 'method1', params = {} },
                { method = 'method2', params = {1,2}}
              }
            }
          }
        },
        objects = {}             -- node root->a does not have any object registered
      }
      'b' = {                    -- root->b node
        children = {},           -- no children nor objects
        objects = {}
      }
    }
  }
]]
local _root = Node:new()

-- The Beholder module
Beholder = {}

function Beholder:observe(eventId, methodOrName, ...)

  assert(self~=nil, "self is nil. invoke object:observe instead of object.observe")
  assert(eventId~=nil, "eventId can not be nil")
  local t = type(methodOrName)
  assert(t=='string' or t=='function', 'methodOrName must be a function or string')

  local node = _root:getOrCreateDescendant(eventId)

  node:addAction(self, methodOrName, ...)
end

function Beholder:stopObserving(eventId, methodOrName)
  local node = _root:getDescendant(eventId)
  if node==nil then return end
  node:removeAction(self, methodOrName)
end


--[[ Triggers events
   Usage:
     Beholder.trigger('passion.update', dt)
   All objects that are "observing" passion.update events will get their associated actions called.
]]

function Beholder.trigger(eventId, ...)

  local node = _root:getDescendant(eventId)
  if node==nil then return end
  
  for object,actions in pairs(node.objects) do
    for _,action in ipairs(actions) do
      local params = {}
      for k,v in ipairs(action.params) do params[k] = v end
      for _,v in ipairs({...}) do table.insert(params, v) end
      
      Sender.send(object, action.method, unpack(params))
    end
  end
end

