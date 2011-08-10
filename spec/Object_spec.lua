require 'middleclass'

context('Object', function()

  context('name', function()
    test('is correctly set', function()
      assert_equal(Object.name, 'Object')
    end)
  end)

  context('tostring', function()
    test('returns "class Object"', function()
      assert_equal(tostring(Object), 'class Object')
    end)
  end)
  
  context('Object()', function()
    test('returns an object, like Object:new()', function()
      local obj = Object()
      assert_true(instanceOf(Object))
    end)
  end)
  

  context('instance creation', function()

    local MyClass

    before(function()
      MyClass = Object:subclass('MyClass')
      function MyClass:initialize() self.mark=true end
    end)

    context('allocate', function()

      test('allocates instances properly', function()
        local instance = MyClass:allocate()
        assert_equal(instance.class, MyClass)
      end)

      test('throws an error when used without the :', function()
        assert_error(Object.allocate)
      end)

      test('does not call the initializer', function()
        local allocated = MyClass:allocate()
        assert_nil(allocated.mark)
      end)

      test('can be overriden', function()
        function MyClass.static:allocate()
          local instance = Object:allocate()
          instance.mark = true
          return instance
        end

        local allocated = MyClass:allocate()
        assert_true(allocated.mark)
      end)

    end)

    context('new', function()

      test('initializes instances properly', function()
        local instance = MyClass:new()
        assert_equal(instance.class, MyClass)
      end)

      test('throws an error when used without the :', function()
        assert_error(MyClass.new)
      end)

      test('calls the initializer', function()
        local allocated = MyClass:new()
        assert_true(allocated.mark)
      end)

    end)

  end)

  context('subclass', function()

    test('throws an error when used without the :', function()
      assert_error(function() Object.subclass() end)
    end)

    context('when given a class name', function()

      local MyClass = Object:subclass('MyClass')

      test('it returns a class with the correct name', function()
        assert_equal(MyClass.name, 'MyClass')
      end)

      test('it returns a class with the correct superclass', function()
        assert_equal(MyClass.superclass, Object)
      end)
    end)

    context('when no name is given', function()
      test('it throws an error', function()
        assert_error( function() Object:subclass() end)
      end)
    end)

  end)

end)





--[[
 
  context('Metamethods', function()
    
    test('__index should throw an error', function()
      local NonIndexable = class('NonIndexable')
      
      assert_error(function() function NonIndexable:__index(name) end end)
    end)

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
        test(metamethod .. ' should work', function()
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
          test(metamethod .. ' should work', function()
            assert_equal(values[1], values[2])
          end)
        end
      end)
      
    end)

    context('Default Metamethods', function() 
      local Peter = class('Peter')
      local peter = Peter()
      
      context('A Class', function()
        test('should have a tostring metamethod', function()
          assert_equal(tostring(Peter), 'class Peter')
        end)
        test('should have a call metamethod', function()
          assert_true(instanceOf(Peter, peter))
        end)
      end)

      context('An instance', function()
        test('should have a tostring metamethod, different from Object.__tostring', function()
          assert_not_equal(Peter.__tostring, Object.__tostring)
          assert_equal(tostring(peter), 'instance of Peter')
        end)
      end)
    end)
 
  end)

end)




context('includes', function()

  context('Primitives', function()
    local o = Object:new()
    local primitives = {nil, 1, 'hello', {}, function() end}
    
    for _,primitive in pairs(primitives) do
      local theType = type(primitive)
      context('A ' .. theType, function()
        
        local f1 = function() return includes(Object, primitive) end
        local f2 = function() return includes(primitive, o) end
        local f3 = function() return includes(primitive, primitive) end
        
        context('should not throw errors', function()
          test('includes(Object, '.. theType ..')', function()
            assert_not_error(f1)
          end)
          test('includes(' .. theType .. ', Object:new())', function()
            assert_not_error(f2)
          end)
          test('includes(' .. theType .. ',' .. theType ..')', function()
            assert_not_error(f3)
          end)
        end)
        
        test('should make includes return false', function()
          assert_false(f1())
          assert_false(f2())
          assert_false(f3())
        end)

      end)
    end -- for

  end)

  context('A class', function()

    local Class1 = class('Class1')
    local Class2 = class('Class2', Class1)
    local Class3 = class('Class3', Class2)
    local UnrelatedClass = class('Unrelated')
    
    local hasFoo = { foo=function() return 'foo' end }
    Class1:include(hasFoo)
    
    test('should return true if it includes a mixin', function()
      assert_true(includes(hasFoo, Class1))
    end)
    
    test('should return true if its superclass includes a mixin', function()
      assert_true(includes(hasFoo, Class2))
      assert_true(includes(hasFoo, Class3))
    end)
    
    test('should return false otherwise', function()
      assert_false(includes(hasFoo, UnrelatedClass))
    end)

  end)

end)

]]


