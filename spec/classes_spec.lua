require 'middleclass'

context('A Class', function()

  context('Default stuff', function()

    local AClass

    before(function()
      AClass = class('AClass')
    end)

    context('name', function()
      test('is correctly set', function()
        assert_equal(AClass.name, 'AClass')
      end)
    end)

    context('tostring', function()
      test('returns "class *name*"', function()
        assert_equal(tostring(AClass), 'class AClass')
      end)
    end)

    context('()', function()
      test('returns an object, like Class:new()', function()       
        local obj = AClass()
        assert_equal(obj.class, AClass)
      end)
    end)

    context('include', function()
      test('throws an error when used without the :', function()
        assert_error(function() AClass.include() end)
      end)
      test('throws an error when passed a non-table:', function()
        assert_error(function() AClass:include(1) end)
      end)
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
