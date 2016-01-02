local class = require 'middleclass'

local it = require('busted').it
local describe = require('busted').describe
local before_each = require('busted').before_each
local assert = require('busted').assert

describe('Lua 5.3 Metamethods', function()
  local Vector, v, last_gc
  before_each(function()
    Vector= class('Vector')
    function Vector.initialize(a,x,y,z) a.x, a.y, a.z = x,y,z end
    function Vector.__eq(a,b)     return a.x==b.x and a.y==b.y and a.z==b.z end
    function Vector.__pairs(a)
      local t = {x=a.x,y=a.y,z=a.z}
      return coroutine.wrap(function()
        for k,val in pairs(t) do
          coroutine.yield(k,val)
        end
      end)
    end
    function Vector.__len(a)    return 3 end

    function Vector.__gc(a) last_gc = {a.class.name, a.x, a.y, a.z} end
    function Vector.__band(a,n) return a.class:new(a.x & n, a.y & n, a.z & n) end
    function Vector.__bor(a,n)  return a.class:new(a.x | n, a.y | n, a.z | n) end
    function Vector.__bxor(a,n) return a.class:new(a.x ~ n, a.y ~ n, a.z ~ n) end
    function Vector.__shl(a,n)  return a.class:new(a.x << n, a.y << n, a.z << n) end
    function Vector.__shr(a,n)  return a.class:new(a.x >> n, a.y >> n, a.z >> n) end
    function Vector.__bnot(a)   return a.class:new(~a.x, ~a.y, ~a.z) end

    v = Vector:new(1,2,3)
  end)

  it('implements __gc', function()
    collectgarbage()
    v = nil
    collectgarbage()
    assert.are.same(last_gc, {"Vector",1,2,3})
  end)

  it('implements __band', function()
    assert.equal(v & 1, Vector(1,0,1))
  end)

  it('implements __bor', function()
    assert.equal(v | 0, Vector(1,2,3))
  end)

  it('implements __bxor', function()
    assert.equal(v | 1, Vector(1,3,3))
  end)

  it('implements __shl', function()
    assert.equal(v << 1, Vector(2,4,6))
  end)

  it('implements __shr', function()
    assert.equal(v >> 1, Vector(0,1,1))
  end)

  it('implements __bnot', function()
    assert.equal(~v, Vector(-2,-3,-4))
  end)

  describe('Inherited Metamethods', function()
    local Vector2, v2
    before_each(function()
      Vector2= class('Vector2', Vector)
      function Vector2:initialize(x,y,z) Vector.initialize(self,x,y,z) end

      v2 = Vector2:new(1,2,3)
    end)

    it('implements __gc', function()
      collectgarbage()
      v2 = nil
      collectgarbage()
      assert.are.same(last_gc, {"Vector2",1,2,3})
    end)

    it('implements __band', function()
      assert.equal(v2 & 1, Vector2(1,0,1))
    end)

    it('implements __bor', function()
      assert.equal(v2 | 0, Vector2(1,2,3))
    end)

    it('implements __bxor', function()
      assert.equal(v2 | 1, Vector2(1,3,3))
    end)

    it('implements __shl', function()
      assert.equal(v2 << 1, Vector2(2,4,6))
    end)

    it('implements __shr', function()
      assert.equal(v2 >> 1, Vector2(0,1,1))
    end)

    it('implements __bnot', function()
      assert.equal(~v2, Vector2(-2,-3,-4))
    end)
  end)
end)
