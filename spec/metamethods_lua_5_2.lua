local class = require 'middleclass'

local it = require('busted').it
local describe = require('busted').describe
local before_each = require('busted').before_each
local assert = require('busted').assert

describe('Lua 5.2 Metamethods', function()
  local Vector, v
  before_each(function()
    Vector= class('Vector')
    function Vector.initialize(a,x,y,z) a.x, a.y, a.z = x,y,z end
    function Vector.__eq(a,b)     return a.x==b.x and a.y==b.y and a.z==b.z end

    function Vector.__len(a)    return 3 end
    function Vector.__pairs(a)
      local t = {x=a.x,y=a.y,z=a.z}
      return coroutine.wrap(function()
        for k,val in pairs(t) do
          coroutine.yield(k,val)
        end
      end)
    end
    function Vector.__ipairs(a)
      local t = {a.x,a.y,a.z}
      return coroutine.wrap(function()
        for k,val in ipairs(t) do
          coroutine.yield(k,val)
        end
      end)
    end

    v = Vector:new(1,2,3)
  end)

  it('implements __len', function()
    assert.equal(#v, 3)
  end)

  it('implements __pairs',function()
    local output = {}
    for k,val in pairs(v) do
      output[k] = val
    end
    assert.are.same(output,{x=1,y=2,z=3})
  end)

  it('implements __ipairs',function()
    local output = {}
    for _,i in ipairs(v) do
      output[#output+1] = i
    end
    assert.are.same(output,{1,2,3})
  end)

  describe('Inherited Metamethods', function()
    local Vector2, v2
    before_each(function()
      Vector2= class('Vector2', Vector)
      function Vector2:initialize(x,y,z) Vector.initialize(self,x,y,z) end

      v2 = Vector2:new(1,2,3)
    end)

    it('implements __len', function()
      assert.equal(#v2, 3)
    end)

    it('implements __pairs',function()
      local output = {}
      for k,val in pairs(v2) do
        output[k] = val
      end
      assert.are.same(output,{x=1,y=2,z=3})
    end)

    it('implements __ipairs',function()
      local output = {}
      for _,i in ipairs(v2) do
        output[#output+1] = i
      end
      assert.are.same(output,{1,2,3})
    end)
  end)
end)
