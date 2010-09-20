require('middleclass.init')

context( 'Invoker', function()

  local MyClass = class('MyClass')
  MyClass:include(Invoker)
  function MyClass:foo(x,y) return 'foo ' .. tostring(x) .. ', ' .. tostring(y) end
  
  local obj = MyClass:new()
  
  test('It should work with method names', function()
    assert_equal(obj:invoke('foo', 1, 2), 'foo 1, 2')
  end)
  
  test('It should work with implicit functions', function()
    assert_equal(
      obj:invoke(
        function(self, x, y) return 'bar '.. tostring(x) .. ', ' .. tostring(y) end,
        3,
        4
      ),
      'bar 3, 4'
    )
  end)

end)
