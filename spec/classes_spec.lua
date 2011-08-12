require 'middleclass'

context('A Class', function()

  context('name', function()
    test('is correctly set', function()
      local TheClass = class('TheClass')
      assert_equal(TheClass.name, 'TheClass')
    end)
  end)

  context('tostring', function()
    test('returns "class *name*"', function()
      local TheClass = class('TheClass')
      assert_equal(tostring(TheClass), 'class TheClass')
    end)
  end)

  context('()', function()
    test('returns an object, like Class:new()', function()
      local TheClass = class('TheClass')
      local obj = TheClass()
      assert_true(instanceOf(TheClass, obj))
    end)
  end)

  context('attributes', function()

    local A, B

    before(function()
      A = class('A')
      A.static.foo = 'foo'

      B = class('B', A)
    end)

    test('are available after being initialized', function()
      assert_equal(A.foo, 'foo')
    end)

    test('are available for subclasses', function()
      assert_equal(B.foo, 'foo')
    end)
    
    test('are overridable by subclasses, without affecting the superclasses', function()
      B.static.foo = 'chunky bacon'
      assert_equal(B.foo, 'chunky bacon')
      assert_equal(A.foo, 'foo')
    end)

  end)

  context('methods', function()

    local A, B

    before(function()
      A = class('A')
      function A.static:foo() return 'foo' end

      B = class('B', A)
    end)

    test('are available after being initialized', function()
      assert_equal(A:foo(), 'foo')
    end)

    test('are available for subclasses', function()
      assert_equal(B:foo(), 'foo')
    end)
    
    test('are overridable by subclasses, without affecting the superclasses', function()
      function B.static:foo() return 'chunky bacon' end
      assert_equal(B:foo(), 'chunky bacon')
      assert_equal(A:foo(), 'foo')
    end)

  end)

end)
