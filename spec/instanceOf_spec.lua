require 'middleclass'

context('instanceOf', function()

  context('nils, integers, strings, tables, and functions', function()
    local o = Object:new()
    local primitives = {nil, 1, 'hello', {}, function() end}
    
    for _,primitive in pairs(primitives) do
      local theType = type(primitive)
      context('A ' .. theType, function()
        
        local f1 = function() return instanceOf(Object, primitive) end
        local f2 = function() return instanceOf(primitive, o) end
        local f3 = function() return instanceOf(primitive, primitive) end
        
        context('does not throw errors', function()
          test('instanceOf(Object, '.. theType ..')', function()
            assert_not_error(f1)
          end)
          test('instanceOf(' .. theType .. ', Object:new())', function()
            assert_not_error(f2)
          end)
          test('instanceOf(' .. theType .. ',' .. theType ..')', function()
            assert_not_error(f3)
          end)
        end)
        
        test('makes instanceOf return false', function()
          assert_false(f1())
          assert_false(f2())
          assert_false(f3())
        end)

      end)
    end
    
  end)

  context('An instance', function()
    local Class1 = class('Class1')
    local Class2 = class('Class2', Class1)
    local Class3 = class('Class3', Class2)
    local UnrelatedClass = class('Unrelated')
    
    local o1, o2, o3 = Class1:new(), Class2:new(), Class3:new()
    
    test('is instanceOf(Object)', function()
      assert_true(instanceOf(Object, o1))
      assert_true(instanceOf(Object, o2))
      assert_true(instanceOf(Object, o3))
    end)
    
    test('is instanceOf its class', function()
      assert_true(instanceOf(Class1, o1))
      assert_true(instanceOf(Class2, o2))
      assert_true(instanceOf(Class3, o3))
    end)
    
    test('is instanceOf its class\' superclasses', function()
      assert_true(instanceOf(Class1, o2))
      assert_true(instanceOf(Class1, o3))
      assert_true(instanceOf(Class2, o3))
    end)
    
    test('is not instanceOf its class\' subclasses', function()
      assert_false(instanceOf(Class2, o1))
      assert_false(instanceOf(Class3, o1))
      assert_false(instanceOf(Class3, o2))
    end)
    
    test('is not instanceOf an unrelated class', function()
      assert_false(instanceOf(UnrelatedClass, o1))
      assert_false(instanceOf(UnrelatedClass, o2))
      assert_false(instanceOf(UnrelatedClass, o3))
    end)

  end)

end)
