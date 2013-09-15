local class = require 'middleclass'
local Object = class.Object

context('class()', function()

  context('when given no params', function()
    test('it throws an error', function()
      assert_error(class)
    end)
  end)

  context('when given a name', function()
    test('the resulting class has the correct name and Object as its superclass', function()
      local TheClass = class('TheClass')
      assert_equal(TheClass.name, 'TheClass')
      assert_equal(TheClass.super, Object)
    end)
  end)

  context('when given a name and a superclass', function()
    test('the resulting class has the correct name and superclass', function()
      local TheSuperClass = class('TheSuperClass')
      local TheSubClass = class('TheSubClass', TheSuperClass)
      assert_equal(TheSubClass.name, 'TheSubClass')
      assert_equal(TheSubClass.super, TheSuperClass)
    end)
  end)

end)
