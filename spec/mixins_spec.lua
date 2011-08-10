--[[
context('A Mixin', function()

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
]]
