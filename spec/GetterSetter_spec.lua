require('middleclass.init')

context( 'GetterSetter', function()

  context('When included by a class', function()

    local MyClass = class('MyClass')

    test('Should not throw errors', function()
      assert_not_error(function() MyClass:include(GetterSetter) end)
    end)
    
    test('It should include the 3 main methods on the class', function()
      MyClass:getter('name', 'pete')
      MyClass:setter('age')
      MyClass:getterSetter('color', 'blue')
      
      local obj = MyClass:new()
      assert_equal(obj:getName(), 'pete')
      obj.name = 'john'
      assert_equal(obj:getName(), 'john')
      
      obj:setAge(14)
      assert_equal(obj.age, 14)
      
      assert_equal(obj:getColor(), 'blue')
      obj:setColor('fucsia')
      assert_equal(obj:getColor(), 'fucsia')
    end)
    
    test('It should include the 2 secondary methods on the class', function()
      assert_equal(MyClass:getterFor('language'), 'getLanguage')
      assert_equal(MyClass:setterFor('language'), 'setLanguage')
    end)
    
  end)

end)
