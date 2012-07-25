require 'middleclass'

context('class()', function()

  context('when given no params', function()
    test('it throws an error', function()
      assert_error(class)
    end)
  end)

  context('when given a name', function()
    local TheClass

    before(function()
      TheClass = class('TheClass')
    end)

    test('the resulting class has the correct name', function()
      assert_equal(TheClass.name, 'TheClass')
    end)

    test('the resulting class has Object as its superclass', function()
      assert_equal(TheClass.super, Object)
    end)
  end)

  context('when given a name and a superclass', function()
    local TheSuperClass = class('TheSuperClass')
    local TheSubClass = class('TheSubClass', TheSuperClass)

    test('the resulting class has the correct name', function()
      assert_equal(TheSubClass.name, 'TheSubClass')
    end)

    test('the resulting class has the correct superclass', function()
     assert_equal(TheSubClass.super, TheSuperClass)
    end)
  end)

  context('when given a name and a spec', function()
    test('the resulting class has member', function()
      local TheClass = class('TheClass', {
        getName = function(self)
          return 'the_class'
        end
      })

      the_class = TheClass:new()
      assert_equal(the_class:getName(), 'the_class')
    end)
  end)

  context('when given a name, a superclass, and a spec', function()
    test('the resulting class has member', function()
      local TheSuperClass = class('TheSuperClass')
      local TheClass = class('TheClass', TheSuperClass, {
        getName = function(self)
          return 'the_class'
        end
      })

      the_class = TheClass:new()
      assert_equal(the_class:getName(), 'the_class')
      assert_equal(TheClass.super, TheSuperClass)
    end)
  end)

end)
