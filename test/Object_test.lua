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

end)
