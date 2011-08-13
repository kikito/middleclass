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

end)
