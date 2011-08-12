--[[
require 'middleclass'

context('A Mixin', function()

  local Mixin = {}
  function Mixin:included(theClass) theClass.includesMixin = true end
  function Mixin:foo() return 'foo' end
  function Mixin:bar() return 'bar' end
  function Mixin:baz() return 'baz' end

  local Class1 = class('Class1'):include(Mixin)
  function Class1:foo() return 'foo1' end

  local Class2 = class('Class2', Class1)
  function Class2:bar() return 'bar2' end

  test('invokes the "included" method when included', function()
    assert_true(Class1.includesMixin)
  end)
  
  test('has all its functions (except "included") copied to its target class', function()
    assert_equal(Class1:baz(), 'baz')
    assert_equal(Class1.included, nil)
  end)
  
  test('makes its functions available to subclasses', function()
    assert_equal(Class2:baz(), 'baz')
  end)

  test('allows overriding of methods in the same class', function()
    assert_equal(Class2:foo(), 'foo1')
  end)
  
  test('allows overriding of methods on subclasses', function()
    assert_equal(Class2:bar2(), 'bar2')
  end)

end)
]]
