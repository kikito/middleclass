local class = require 'middleclass'

local it = require('busted').it
local describe = require('busted').describe
local before_each = require('busted').before_each
local assert = require('busted').assert

describe('Lua 5.2 Metamethods', function()
  local Vector, a, b
  before_each(function()
    Vector= class('Vector')
    function Vector.initialize(a,x,y,z) a.x, a.y, a.z = x,y,z end
    function Vector.__eq(a,b)     return a.x==b.x and a.y==b.y and a.z==b.z end

    function Vector.__len(a)    return 3 end
    function Vector.__pairs(a)
      local t = {x=a.x,y=a.y,z=a.z}
      return coroutine.wrap(function()
        for k,v in pairs(t) do
          coroutine.yield(k,v)
        end
      end)
    end
    function Vector.__ipairs(a)
      local t = {a.x,a.y,a.z}
      return coroutine.wrap(function()
        for k,v in ipairs(t) do
          coroutine.yield(k,v)
        end
      end)
    end

    a = Vector:new(1,2,3)
    b = Vector:new(2,4,6)
  end)

  it('implements __len', function()
    assert.equal(#a, 3)
  end)

  it('implements __pairs',function()
    local output = {}
    for k,v in pairs(a) do
      output[k] = v
    end
    assert.are.same(output,{x=1,y=2,z=3})
  end)

  it('implements __ipairs',function()
    local output = {}
    for _,i in ipairs(a) do
      output[#output+1] = i
    end
    assert.are.same(output,{1,2,3})
  end)

  describe('Inherited Metamethods', function()
    local Vector2, c, d
    before_each(function()
      Vector2= class('Vector2', Vector)
      function Vector2:initialize(x,y,z) Vector.initialize(self,x,y,z) end

      c = Vector2:new(1,2,3)
      d = Vector2:new(2,4,6)
    end)

    it('implements __len', function()
      assert.equal(#c, 3)
    end)

    it('implements __pairs',function()
      local output = {}
      for k,v in pairs(c) do
        output[k] = v
      end
      assert.are.same(output,{x=1,y=2,z=3})
    end)

    it('implements __ipairs',function()
      local output = {}
      for _,i in ipairs(c) do
        output[#output+1] = i
      end
      assert.are.same(output,{1,2,3})
    end)
  end)
end)
