require('middleclass.init')

context( 'Sender', function()

  local MyClass = class('MyClass')
  MyClass:include(Sender)
  function MyClass:foo(x,y) return 'foo ' .. tostring(x) .. ', ' .. tostring(y) end
  function MyClass:testSelf() return instanceOf(MyClass, self) end
  
  local obj = MyClass:new()
  
  test('It should work with method names', function()
    assert_equal(obj:send('foo', 1, 2), 'foo 1, 2')
  end)
  
  test('It should work with implicit functions', function()
    assert_equal(
      obj:send(
        function(self, x, y) return 'bar '.. tostring(x) .. ', ' .. tostring(y) end,
        3,
        4
      ),
      'bar 3, 4'
    )
  end)
  
  test('It should use self as implicit parameter in all cases', function()
    assert_true(obj:send('testSelf'))
    assert_true(obj:send(MyClass.testSelf))
  end)

end)
