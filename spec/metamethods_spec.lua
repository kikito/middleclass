local class = require 'middleclass'

local function is_lua_5_2_compatible()
  return type(rawlen) == 'function'
end

local function is_lua_5_3_compatible()
  return type(string.unpack) == 'function'
end

if is_lua_5_2_compatible() then
  require 'spec/metamethods_lua_5_2'
end

if is_lua_5_3_compatible() then
  require 'spec.metamethods_lua_5_3'
end

describe('Metamethods', function()
  describe('Custom Metamethods', function()
    local Vector, v, w
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
        return a.class:new(a.y*b.z-a.z*b.y,a.z*b.x-a.x*b.z,a.x*b.y-a.y*b.x)
      end
      function Vector.__mul(a,b)
        if type(b)=="number" then return a.class:new(a.x*b, a.y*b, a.z*b) end
        if type(a)=="number" then return b.class:new(a*b.x, a*b.y, a*b.z) end
      end
      Vector.__metatable = "metatable of a vector"
      Vector.__mode = "k"

      v = Vector:new(1,2,3)
      w = Vector:new(2,4,6)
    end)

    it('implements __tostring', function()
      assert.equal(tostring(v), "Vector[1,2,3]")
    end)

    it('implements __eq', function()
      assert.equal(v, v)
    end)

    it('implements __lt', function()
      assert.is_true(v < w)
    end)

    it('implements __le', function()
      assert.is_true(v <= w)
    end)

    it('implements __add', function()
      assert.equal(v+w, Vector(3,6,9))
    end)

    it('implements __sub', function()
      assert.equal(w-v, Vector(1,2,3))
    end)

    it('implements __div', function()
      assert.equal(w/2, Vector(1,2,3))
    end)

    it('implements __concat', function()
      assert.equal(v..w, 28)
    end)

    it('implements __call', function()
      assert.equal(v(), math.sqrt(14))
    end)

    it('implements __pow', function()
      assert.equal(v^w, Vector(0,0,0))
    end)

    it('implements __mul', function()
      assert.equal(4*v, Vector(4,8,12))
    end)

    it('implements __metatable', function()
      assert.equal("metatable of a vector", getmetatable(v))
    end)

    it('implements __mode', function()
      v[{}] = true
      collectgarbage()
      for k in pairs(v) do assert.not_table(k) end
    end)

    --[[
    it('implements __index', function()
      assert.equal(b[1], 3)
    end)
    --]]

    describe('Inherited Metamethods', function()
      local Vector2, v2, w2
      before_each(function()
        Vector2= class('Vector2', Vector)
        function Vector2:initialize(x,y,z) Vector.initialize(self,x,y,z) end

        v2 = Vector2:new(1,2,3)
        w2 = Vector2:new(2,4,6)
      end)

      it('implements __tostring', function()
        assert.equal(tostring(v2), "Vector2[1,2,3]")
      end)

      it('implements __eq', function()
        assert.equal(v2, v2)
      end)

      it('implements __lt', function()
        assert.is_true(v2 < w2)
      end)

      it('implements __le', function()
        assert.is_true(v2 <= w2)
      end)

      it('implements __add', function()
        assert.equal(v2+w2, Vector2(3,6,9))
      end)

      it('implements __sub', function()
        assert.equal(w2-v2, Vector2(1,2,3))
      end)

      it('implements __div', function()
        assert.equal(w2/2, Vector2(1,2,3))
      end)

      it('implements __concat', function()
        assert.equal(v2..w2, 28)
      end)

      it('implements __call', function()
        assert.equal(v2(), math.sqrt(14))
      end)

      it('implements __pow', function()
        assert.equal(v2^w2, Vector2(0,0,0))
      end)

      it('implements __mul', function()
        assert.equal(4*v2, Vector2(4,8,12))
      end)

      it('implements __metatable', function()
        assert.equal("metatable of a vector", getmetatable(v2))
      end)

      it('implements __mode', function()
        v2[{}] = true
        collectgarbage()
        for k in pairs(v2) do assert.not_table(k) end
      end)

      it('allows inheriting further', function()
        local Vector3 = class('Vector3', Vector2)
        local v3 = Vector3(1,2,3)
        local w3 = Vector3(3,4,5)
        assert.equal(v3+w3, Vector3(4,6,8))
      end)

      describe('Updates', function()
        it('overrides __add', function()
          Vector2.__add = function(a, b) return Vector.__add(a, b)/2 end
          assert.equal(v2+w2, Vector2(1.5,3,4.5))
        end)

        it('updates __add', function()
          Vector.__add = Vector.__sub
          assert.equal(v2+w2, Vector2(-1,-2,-3))
        end)

        it('does not update __add after overriding', function()
          Vector2.__add = function(a, b) return Vector.__add(a, b)/2 end
          Vector.__add = Vector.__sub
          assert.equal(v2+w2, Vector2(-0.5,-1,-1.5))
        end)

        it('reverts __add override', function()
          Vector2.__add = function(a, b) return Vector.__add(a, b)/2 end
          Vector2.__add = nil
          assert.equal(v2+w2, Vector2(3,6,9))
        end)
      end)
    end)
  end)

  describe('Custom __index and __newindex', function()
    describe('Tables', function()
      local Proxy, fallback, p
      before_each(function()
        Proxy = class('Proxy')
        fallback = {foo = 'bar', common = 'fallback'}
        Proxy.__index = fallback
        Proxy.__newindex = fallback
        Proxy.common = 'class'
        p = Proxy()
      end)

      it('uses __index', function()
        assert.equal(p.foo, 'bar')
      end)

      it('does not use __index when field exists in class', function()
        assert.equal(p.common, 'class')
      end)

      it('uses __newindex', function()
        p.key = 'value'
        assert.equal(fallback.key, 'value')
      end)

      it('uses __newindex when field exists in class', function()
        p.common = 'value'
        assert.equal(p.common, 'class')
        assert.equal(Proxy.common, 'class')
        assert.equal(fallback.common, 'value')
      end)
    end)

    describe('Functions', function()
      local Namespace, Rectangle, r
      before_each(function()
        Namespace = class('Namespace')
        function Namespace:__index(name)
          local getter = self.class[name.."Getter"]
          if getter then return getter(self) end
        end
        function Namespace:__newindex(name, value)
          local setter = self.class[name.."Setter"]
          if setter then setter(self, value) else rawset(self, name, value) end
        end
        Rectangle = class('Rectangle', Namespace)
        function Rectangle:initialize(x, y, scale)
          self._scale, self.x, self.y = 1, x, y
          self.scale = scale
        end
        function Rectangle:scaleGetter() return self._scale end
        function Rectangle:scaleSetter(v)
          self.x = self.x*v/self._scale
          self.y = self.y*v/self._scale
          self._scale = v
        end
        function Rectangle:areaGetter() return self.x * self.y end
        r = Rectangle(3, 4, 2)
      end)

      it('uses setter', function()
        assert.equal(r.x, 6)
        assert.equal(r.y, 8)
        r.scale = 3
        assert.equal(r.x, 9)
        assert.equal(r.y, 12)
      end)

      it('uses getters', function()
        assert.equal(r.scale, 2)
        assert.equal(r.area, 48)
      end)

      it('updates inherited __index', function()
        function Namespace.__index() return 42 end
        assert.equal(r.area, 42)
        function Rectangle.__index() return 24 end
        assert.equal(r.area, 24)
        function Namespace.__index() return 96 end
        assert.equal(r.area, 24)
        Rectangle.__index = nil
        assert.equal(r.area, 96)
      end)
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
        assert.equal(tostring(peter), 'instance of class Peter')
      end)
    end)
  end)

end)
