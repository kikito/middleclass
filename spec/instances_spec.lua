require 'middleclass'

context('An instance', function()

  context('attributes', function()

    local Person

    before(function()
      Person = class('Person')
      function Person:initialize(name)
        self.name = name
      end
    end)

    test('are available in the instance after being initialized', function()
      local bob = Person:new('bob')
      assert_equal(bob.name, 'bob')
    end)
    
    test('are available in the instance after being initialized by a superclass', function()
      local AgedPerson = class('AgedPerson', Person)
      function AgedPerson:initialize(name, age)
        Person.initialize(self, name)
        self.age = age
      end

      local pete = AgedPerson:new('pete', 31)
      assert_equal(pete.name, 'pete')
      assert_equal(pete.age, 31)
    end)

  end)

  context('methods', function()

    local A, B, a, b

    before(function()
      A = class('A')
      function A:overridden() return 'foo' end
      function A:regular() return 'regular' end
      
      B = class('B', A)
      function B:overridden() return 'bar' end
      
      a = A:new()
      b = B:new()
    end)

    test('are available for any instance', function()
      assert_equal(a:overridden(), 'foo')
    end)
    
    test('are inheritable', function()
      assert_equal(b:regular(), 'regular')
    end)
    
    test('are overridable', function()
      assert_equal(b:overridden(), 'bar')
    end)

  end)

end)
