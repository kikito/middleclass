require 'middleclass'

context('subclassOf', function()

  context('nils, integers, etc', function()
    local primitives = {nil, 1, 'hello', {}, function() end}
    
    for _,primitive in pairs(primitives) do
      local theType = type(primitive)
      context('A ' .. theType, function()
        
        local f1 = function() return subclassOf(Object, primitive) end
        local f2 = function() return subclassOf(primitive, o) end
        local f3 = function() return subclassOf(primitive, primitive) end
        
        context('does not throw errors', function()
          test('subclassOf(Object, '.. theType ..')', function()
            assert_not_error(f1)
          end)
          test('subclassOf(' .. theType .. ', Object:new())', function()
            assert_not_error(f2)
          end)
          test('subclassOf(' .. theType .. ',' .. theType ..')', function()
            assert_not_error(f3)
          end)
        end)
        
        test('makes subclassOf return false', function()
          assert_false(f1())
          assert_false(f2())
          assert_false(f3())
        end)

      end)
    end

  end)
  
  context('Any class (except Object)', function()
    local Class1 = class('Class1')
    local Class2 = class('Class2', Class1)
    local Class3 = class('Class3', Class2)
    local UnrelatedClass = class('Unrelated')
    
    test('is subclassOf(Object)', function()
      assert_true(subclassOf(Object, Class1))
      assert_true(subclassOf(Object, Class2))
      assert_true(subclassOf(Object, Class3))
    end)
    
    test('is subclassOf its direct superclass', function()
      assert_true(subclassOf(Class1, Class2))
      assert_true(subclassOf(Class2, Class3))
    end)
    
    test('is subclassOf its ancestors', function()
      assert_true(subclassOf(Class1, Class3))
    end)
    
    test('is a subclassOf its class\' subclasses', function()
      assert_false(subclassOf(Class2, Class1))
      assert_false(subclassOf(Class3, Class1))
      assert_false(subclassOf(Class3, Class2))
    end)
    
    test('is not a subclassOf an unrelated class', function()
      assert_false(subclassOf(UnrelatedClass, Class1))
      assert_false(subclassOf(UnrelatedClass, Class2))
      assert_false(subclassOf(UnrelatedClass, Class3))
    end)

  end)

end)
