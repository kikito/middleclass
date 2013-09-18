local class = require 'middleclass'

describe('An instance', function()

  describe('attributes', function()

    local Person

    before_each(function()
      Person = class('Person')
      function Person:initialize(name)
        self.name = name
      end
    end)

    it('are available in the instance after being initialized', function()
      local bob = Person:new('bob')
      assert.equal(bob.name, 'bob')
    end)

    it('are available in the instance after being initialized by a superclass', function()
      local AgedPerson = class('AgedPerson', Person)
      function AgedPerson:initialize(name, age)
        Person.initialize(self, name)
        self.age = age
      end

      local pete = AgedPerson:new('pete', 31)
      assert.equal(pete.name, 'pete')
      assert.equal(pete.age, 31)
    end)

  end)

  describe('methods', function()

    local A, B, a, b

    before_each(function()
      A = class('A')
      function A:overridden() return 'foo' end
      function A:regular() return 'regular' end

      B = class('B', A)
      function B:overridden() return 'bar' end

      a = A:new()
      b = B:new()
    end)

    it('are available for any instance', function()
      assert.equal(a:overridden(), 'foo')
    end)

    it('are inheritable', function()
      assert.equal(b:regular(), 'regular')
    end)

    it('are overridable', function()
      assert.equal(b:overridden(), 'bar')
    end)

  end)

end)
