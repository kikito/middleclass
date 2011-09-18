require 'middleclass'

context('A Mixin', function()

  local Mixin1, Mixin2, Class1, Class2

  before(function()
    Mixin1, Mixin2 = {},{}

    function Mixin1:included(theClass) theClass.includesMixin1 = true end
    function Mixin1:foo() return 'foo' end
    function Mixin1:bar() return 'bar' end
    Mixin1.static = {}
    Mixin1.static.bazzz = function() return 'bazzz' end


    function Mixin2:baz() return 'baz' end

    Class1 = class('Class1'):include(Mixin1, Mixin2)
    function Class1:foo() return 'foo1' end

    Class2 = class('Class2', Class1)
    function Class2:bar2() return 'bar2' end
  end)

  test('invokes the "included" method when included', function()
    assert_true(Class1.includesMixin1)
  end)
  
  test('has all its functions (except "included") copied to its target class', function()
    assert_equal(Class1:bar(), 'bar')
    assert_nil(Class1.included)
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

  test('makes new static methods available in classes', function()
    assert_equal(Class1:bazzz(), 'bazzz')
    assert_equal(Class2:bazzz(), 'bazzz')
  end)

end)

