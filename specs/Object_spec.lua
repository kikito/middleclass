require('MiddleClass')

context( 'Object', function()

  context( 'When creating a direct subclass of Object', function()

    context( 'using Object:subclass("name")', function()
      local MyClass = Object:subclass('MyClass')

      test( 'should have its name correctly set up', function()
        assert_equal(MyClass.name, 'MyClass')
      end)

      test( 'should have Object as its superclass', function()
        assert_equal(MyClass.superclass, Object)
      end)
    end)

    context( 'When no name is given', function()
      test( 'should throw an error', function()
        assert_false( pcall(Object.subclass, Object) )
      end)
    end)

  end)

  context( 'An instance attribute', function()
    local Person = class('Person')
    function Person:initialize(name)
      super.initialize(self)
      self.name = name
    end
    
    local AgedPerson = class('AgedPerson', Person)
    function AgedPerson:initialize(name, age)
      super.initialize(self, name)
      self.age = age
    end

    test('should be available after being initialized', function()
      local bob = Person:new('bob')
      assert_equal(bob.name, 'bob')
    end)
    
    test('should be available after being initialized by a superclass', function()
      local pete = AgedPerson:new('pete', 31)
      assert_equal(pete.name, 'pete')
      assert_equal(pete.age, 31)
    end)
  end)
  
  context( 'An instance method', function()
    local A = class('A')
    function A:foo() return 'foo' end
    function A:bar() return 'bar' end
    
    local B = class('B', A)
    function B:foo() return 'baz' end
    
    local a = A:new()
    local b = B:new()

    test('should be available for any instance', function()
      assert_equal(a:foo(), 'foo')
    end)
    
    test('should be inheritable', function()
      assert_equal(b:bar(), 'bar')
    end)
    
    test('should be overridable', function()
      assert_equal(b:foo(), 'baz')
    end)
  end)
  
  context( 'A super call', function()
    local Level0 = Object:subclass('Level0')
    function Level0:initialize() self.type = self:getType() end
    function Level0:getType() return 'level0' end
    function Level0:getNumber() return 10 end

    local Level1 = Level0:subclass('Level1')
    function Level1:initialize() super.initialize(self) end
    function Level1:getType() return 'level1' end

    local Level2 = Level1:subclass('Level2')
    function Level2:initialize() super.initialize(self) end
    function Level2:getType() return 'level2' end
    -- Calling super.getNumber(self) on a Level2 object skips Level1
    -- (since it's not overriden here) and calls Level0:getNumber()
    function Level2:getNumber() return super.getNumber(self) + 1 end

    local level0 = Level0:new()
    local level1 = Level1:new()
    local level2 = Level2:new()

    test('should jump accross classes when not defined on the middle one', function()
      assert_equal(level2:getNumber(), 11)
    end)
    
    test('should use the appropiate versions of each method on every level', function()
      assert_equal(level0.type, 'level0')
      assert_equal(level1.type, 'level1')
      assert_equal(level2.type, 'level2')
    end)
  end)
  
  context( 'A class attribute', function()
    local A = class('A')
    A.foo = 'foo'

    local B = class('B', A)

    test('should be available after being initialized', function()
      assert_equal(A.foo, 'foo')
    end)

    test('should be available for subclasses', function()
      assert_equal(B.foo, 'foo')
    end)
    
    test('should be overridable by subclasses, without affecting the superclasses', function()
      B.foo = 'chunky bacon'
      assert_equal(B.foo, 'chunky bacon')
      assert_equal(A.foo, 'foo')
    end)
  end)
  
  context( 'A class method', function()
    local A = class('A')
    function A.foo(theClass) return 'foo' end

    local B = class('B', A)

    test('should be available after being initialized', function()
      assert_equal(A:foo(), 'foo')
    end)

    test('should be available for subclasses', function()
      assert_equal(B:foo(), 'foo')
    end)
    
    test('should be overridable by subclasses, without affecting the superclasses', function()
      function B.foo(theClass) return 'chunky bacon' end
      assert_equal(B:foo(), 'chunky bacon')
      assert_equal(A:foo(), 'foo')
    end)
  end)
  
  context( 'A Mixin', function()

    local Class1 = class('Class1')
    local Mixin = {}
    function Mixin:included(theClass) theClass.includesMixin = true end
    function Mixin:foo() return 'foo' end
    function Mixin:bar() return 'bar' end
    Class1:include(Mixin)

    Class2 = class('Class2', Class1)
    function Class2:foo() return 'baz' end

    test('should invoke the "included" method when included', function()
      assert_true(Class1.includesMixin)
    end)
    
    test('should have all its functions (except "included") copied to its target class', function()
      assert_equal(Class1:foo(), 'foo')
      assert_equal(Class1.included, nil)
    end)
    
    test('should make its functions available to subclasses', function()
      assert_equal(Class2:bar(), 'bar')
    end)
    
    test('should allow overriding of methods on subclasses', function()
      assert_equal(Class2:foo(), 'baz')
    end)

  end)
  
  context( 'Metamethods', function()

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
        __mul =      { 4*a,  Vector(4,8,12) }
      }) do
        test(metamethod .. ' should work', function()
          assert_equal(values[1], values[2])
        end)
      end
      
      context('Inherited Metamethods', function()
        local Vector2= class('Vector2', Vector)
        function Vector2:initialize(x,y,z) super.initialize(self,x,y,z) end
        
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
