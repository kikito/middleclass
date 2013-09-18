local class = require 'middleclass'

describe('A Mixin', function()

  local Mixin1, Mixin2, Class1, Class2

  before_each(function()
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

  it('invokes the "included" method when included', function()
    assert.is_true(Class1.includesMixin1)
  end)

  it('has all its functions (except "included") copied to its target class', function()
    assert.equal(Class1:bar(), 'bar')
    assert.is_nil(Class1.included)
  end)

  it('makes its functions available to subclasses', function()
    assert.equal(Class2:baz(), 'baz')
  end)

  it('allows overriding of methods in the same class', function()
    assert.equal(Class2:foo(), 'foo1')
  end)

  it('allows overriding of methods on subclasses', function()
    assert.equal(Class2:bar2(), 'bar2')
  end)

  it('makes new static methods available in classes', function()
    assert.equal(Class1:bazzz(), 'bazzz')
    assert.equal(Class2:bazzz(), 'bazzz')
  end)

end)

