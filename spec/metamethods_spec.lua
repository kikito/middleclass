local class = require 'middleclass'
local Object = class.Object

local function is_lua_5_2_compatible()
  return type(rawlen) == 'function'
end

describe('Metamethods', function()

  describe('Custom Metamethods', function()
    local Vector= class('Vector')
    function Vector.initialize(a,x,y,z) a.x, a.y, a.z = x,y,z end
    function Vector.__tostring(a) return a.class.name .. '[' .. a.x .. ',' .. a.y .. ',' .. a.z .. ']' end
    function Vector.__eq(a,b)     return a.x==b.x and a.y==b.y and a.z==b.z end
    function Vector.__lt(a,b)     return a() < b() end
    function Vector.__le(a,b)     return a() <= b() end
    function Vector.__add(a,b)    return Vector:new(a.x+b.x, a.y+b.y ,a.z+b.z) end
    function Vector.__sub(a,b)    return Vector:new(a.x-b.x, a.y-b.y, a.z-b.z) end
    function Vector.__div(a,s)    return Vector:new(a.x/s, a.y/s, a.z/s) end
    function Vector.__unm(a)      return Vector:new(-a.x, -a.y, -a.z) end
    function Vector.__concat(a,b) return a.x*b.x+a.y*b.y+a.z*b.z end
    function Vector.__call(a)     return math.sqrt(a.x*a.x+a.y*a.y+a.z*a.z) end
    function Vector.__pow(a,b)
      return Vector:new(a.y*b.z-a.z*b.y,a.z*b.x-a.x*b.z,a.x*b.y-a.y*b.x)
    end
    function Vector.__mul(a,b)
      if type(b)=="number" then return Vector:new(a.x*b, a.y*b, a.z*b) end
      if type(a)=="number" then return Vector:new(a*b.x, a*b.y, a*b.z) end
    end
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

    local a = Vector:new(1,2,3)
    local b = Vector:new(2,4,6)

    for metamethod,values in pairs({
      __tostring = { tostring(a), "Vector[1,2,3]" },
      __eq =       { a,    a},
      __lt =       { a<b,  true },
      __le =       { a<=b, true },
      __add =      { a+b,  Vector(3,6,9) },
      __sub =      { b-a,  Vector(1,2,3) },
      __div =      { b/2,  Vector(1,2,3) },
      __unm =      { -a,   Vector(-1,-2,-3) },
      __concat =   { a..b, 28 },
      __call =     { a(), math.sqrt(14) },
      __pow =      { a^b,  Vector(0,0,0) },
      __mul =      { 4*a,  Vector(4,8,12) }
      --__index =    { b[1], 3 }
    }) do
      describe(metamethod, function()
        it('works as expected', function()
          assert.equal(values[1], values[2])
        end)
      end)
    end

    if is_lua_5_2_compatible() then

      describe('__len', function()
        it('works as expected', function()
          assert.equal(#a, 3)
        end)
      end)

      describe('__pairs', function()
        it('works as expected',function()
          local output = {}
          for k,v in pairs(a) do
            output[k] = v
          end
          assert.are.same(output,{x=1,y=2,z=3})
        end)
      end)

      describe('__ipairs', function()
        it('works as expected',function()
          local output = {}
          for _,i in ipairs(a) do
            output[#output+1] = i
          end
          assert.are.same(output,{1,2,3})
        end)
      end)

    end

    describe('Inherited Metamethods', function()
      local Vector2= class('Vector2', Vector)
      function Vector2:initialize(x,y,z) Vector.initialize(self,x,y,z) end

      local c = Vector2:new(1,2,3)
      local d = Vector2:new(2,4,6)
      for metamethod,values in pairs({
        __tostring = { tostring(c), "Vector2[1,2,3]" },
        __eq =       { c, c },
        __lt =       { c<d,  true },
        __le =       { c<=d, true },
        __add =      { c+d,  Vector(3,6,9) },
        __sub =      { d-c,  Vector(1,2,3) },
        __div =      { d/2,  Vector(1,2,3) },
        __unm =      { -c,   Vector(-1,-2,-3) },
        __concat =   { c..d, 28 },
        __call =     { c(), math.sqrt(14) },
        __pow =      { c^d,  Vector(0,0,0) },
        __mul =      { 4*c,  Vector(4,8,12) },
      }) do
        describe(metamethod, function()
          it('works as expected', function()
            assert.equal(values[1], values[2])
          end)
        end)
      end

      if is_lua_5_2_compatible() then

        describe('__len', function()
          it('works as expected', function()
            assert.equal(#c, 3)
          end)
        end)

        describe('__pairs', function()
          it('works as expected',function()
            local output = {}
            for k,v in pairs(c) do
              output[k] = v
            end
            assert.are.same(output,{x=1,y=2,z=3})
          end)
        end)

        describe('__ipairs', function()
          it('works as expected', function()
            local output = {}
            for _,i in ipairs(c) do
              output[#output+1] = i
            end
            assert.are.same(output,{1,2,3})
          end)
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
