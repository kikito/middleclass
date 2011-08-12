require 'middleclass'

context('Metamethods', function()

  context('Custom Metamethods', function()
    -- Tests all metamethods. Note that __len is missing (lua makes table length unoverridable)
    -- I'll use a() to note the length of vector "a" (I would have preferred to use #a, but it's not possible)
    -- I'll be using 'a' instead of 'self' on this example since it is shorter
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
      __mul =      { 4*a,  Vector(4,8,12) }--,
      --__index =    { b[1], 3 }
    }) do
      test(metamethod .. ' works as expected', function()
        assert_equal(values[1], values[2])
      end)
    end
    
    context('Inherited Metamethods', function()
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
        __mul =      { 4*c,  Vector(4,8,12) }
      }) do
        test(metamethod .. ' works as expected', function()
          assert_equal(values[1], values[2])
        end)
      end
    end)
    
  end)

  context('Default Metamethods', function()

    local Peter, peter

    before(function()
      Peter = class('Peter')
      peter = Peter()
    end)

    context('A Class', function()
      test('has a call metamethod properly set', function()
        assert_true(instanceOf(Peter, peter))
      end)
      test('has a tostring metamethod properly set', function()
        assert_equal(tostring(Peter), 'class Peter')
      end)
    end)

    context('An instance', function()
      test('has a tostring metamethod, returning a different result from Object.__tostring', function()
        assert_not_equal(Peter.__tostring, Object.__tostring)
        assert_equal(tostring(peter), 'instance of class Peter')
      end)
    end)
  end)

end)
