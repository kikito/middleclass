local class = require 'middleclass'
local Object = class.Object

local function is_lua_5_2_compatible()
  return type(rawlen) == 'function'
end

local function is_lua_5_3_compatible()
  return type(string.unpack) == 'function'
end

describe('Metamethods', function()

  describe('Custom Metamethods', function()
    local Vector, a, b
    before_each(function()
      Vector= class('Vector')
      function Vector.initialize(a,x,y,z) a.x, a.y, a.z = x,y,z end
      function Vector.__tostring(a) return a.class.name .. '[' .. a.x .. ',' .. a.y .. ',' .. a.z .. ']' end
      function Vector.__eq(a,b)     return a.x==b.x and a.y==b.y and a.z==b.z end
      function Vector.__lt(a,b)     return a() < b() end
      function Vector.__le(a,b)     return a() <= b() end
      function Vector.__add(a,b)    return a.class:new(a.x+b.x, a.y+b.y ,a.z+b.z) end
      function Vector.__sub(a,b)    return a.class:new(a.x-b.x, a.y-b.y, a.z-b.z) end
      function Vector.__div(a,s)    return a.class:new(a.x/s, a.y/s, a.z/s) end
      function Vector.__unm(a)      return a.class:new(-a.x, -a.y, -a.z) end
      function Vector.__concat(a,b) return a.x*b.x+a.y*b.y+a.z*b.z end
      function Vector.__call(a)     return math.sqrt(a.x*a.x+a.y*a.y+a.z*a.z) end
      function Vector.__pow(a,b)
        return Vector:new(a.y*b.z-a.z*b.y,a.z*b.x-a.x*b.z,a.x*b.y-a.y*b.x)
      end
      function Vector.__mul(a,b)
        if type(b)=="number" then return a.class:new(a.x*b, a.y*b, a.z*b) end
        if type(a)=="number" then return b.class:new(a*b.x, a*b.y, a*b.z) end
      end

      if is_lua_5_2_compatible then
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
      end

      if is_lua_5_3_compatible then
        function Vector.__gc(a)
          b.x, b.y, b.z = a.x, a.y, a.z
        end
        function Vector.__band(a,n) return a.class:new(a.x & n, a.y & n, a.z & n) end
        function Vector.__bor(a,n)  return a.class:new(a.x | n, a.y | n, a.z | n) end
        function Vector.__bxor(a,n) return a.class:new(a.x ~ n, a.y ~ n, a.z ~ n) end
        function Vector.__shl(a,n)  return a.class:new(a.x << n, a.y << n, a.z << n) end
        function Vector.__shr(a,n)  return a.class:new(a.x >> n, a.y >> n, a.z >> n) end
        function Vector.__bnot(a)   return a.class:new(~a.x, ~a.y, ~a.z) end
      end

      a = Vector:new(1,2,3)
      b = Vector:new(2,4,6)
    end)

    it('implements __tostring', function()
      assert.equal(tostring(a), "Vector[1,2,3]")
    end)

    it('implements __eq', function()
      assert.equal(a, a)
    end)

    it('implements __lt', function()
      assert.is_true(a < b)
    end)

    it('implements __le', function()
      assert.is_true(a <= b)
    end)

    it('implements __add', function()
      assert.equal(a+b, Vector(3,6,9))
    end)

    it('implements __sub', function()
      assert.equal(b-a, Vector(1,2,3))
    end)

    it('implements __div', function()
      assert.equal(b/2, Vector(1,2,3))
    end)

    it('implements __concat', function()
      assert.equal(a..b, 28)
    end)

    it('implements __call', function()
      assert.equal(a(), math.sqrt(14))
    end)

    it('implements __pow', function()
      assert.equal(a^b, Vector(0,0,0))
    end)

    it('implements __mul', function()
      assert.equal(4*a, Vector(4,8,12))
    end)

    --[[
    it('implements __index', function()
      assert.equal(b[1], 3)
    end)
    --]]

    if is_lua_5_2_compatible() then
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
    end

    if is_lua_5_3_compatible() then

      it('implements __gc', function()
        a = nil
        collectgarbage()
        assert.are.same({b.x, b.y, b.z}, {1,2,3})
      end)

      it('implements __band', function()
        assert.equal(a & 1, Vector(1,1,1))
      end)

      it('implements __bor', function()
        assert.equal(a | 0, Vector(1,2,3))
      end)

      it('implements __bxor', function()
        assert.equal(a | 0, Vector(0,0,0))
      end)

      it('implements __shl', function()
        assert.equal(a << 1, Vector(0,0,0))
      end)

      it('implements __shr', function()
        assert.equal(a >> 1, Vector(0,0,0))
      end)

      it('implements __bnot', function()
        assert.equal(~a, Vector(0,0,0))
      end)

    end

    describe('Inherited Metamethods', function()
      local Vector2, c, d

      before_each(function()
        Vector2= class('Vector2', Vector)
        function Vector2:initialize(x,y,z) Vector.initialize(self,x,y,z) end

        c = Vector2:new(1,2,3)
        d = Vector2:new(2,4,6)
      end)

      it('implements __tostring', function()
        assert.equal(tostring(c), "Vector2[1,2,3]")
      end)

      it('implements __eq', function()
        assert.equal(c, c)
      end)

      it('implements __lt', function()
        assert.is_true(c < d)
      end)

      it('implements __le', function()
        assert.is_true(c <= d)
      end)

      it('implements __add', function()
        assert.equal(c+d, Vector(3,6,9))
      end)

      it('implements __sub', function()
        assert.equal(d-c, Vector(1,2,3))
      end)

      it('implements __div', function()
        assert.equal(d/2, Vector(1,2,3))
      end)

      it('implements __concat', function()
        assert.equal(c..d, 28)
      end)

      it('implements __call', function()
        assert.equal(c(), math.sqrt(14))
      end)

      it('implements __pow', function()
        assert.equal(c^d, Vector(0,0,0))
      end)

      it('implements __mul', function()
        assert.equal(4*c, Vector(4,8,12))
      end)

      if is_lua_5_2_compatible() then

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
      end

      if is_lua_5_3_compatible() then
        it('implements __gc', function()
          c = nil
          collectgarbage()
          assert.are.same({b.x, b.y, b.z}, {1,2,3})
        end)
      end
    end)
  end)

  describe('Default Metamethods', function()

    local Peter, peter

    before_each(function()
      Peter = class('Peter')
      peter = Peter()
    end)

    describe('A Class', function()
      it('has a call metamethod properly set', function()
        assert.is_true(peter:isInstanceOf(Peter))
      end)
      it('has a tostring metamethod properly set', function()
        assert.equal(tostring(Peter), 'class Peter')
      end)
    end)

    describe('An instance', function()
      it('has a tostring metamethod, returning a different result from Object.__tostring', function()
        assert.not_equal(Peter.__tostring, Object.__tostring)
        assert.equal(tostring(peter), 'instance of class Peter')
      end)
    end)
  end)

end)
