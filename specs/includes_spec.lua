require('MiddleClass')

context( 'includes', function()

  context( 'Primitives', function()
    local o = Object:new()
    local primitives = {nil, 1, 'hello', {}, function() end}
    
    for _,primitive in pairs(primitives) do
      local theType = type(primitive)
      context('A ' .. theType, function()
        
        local f1 = function() return includes(Object, primitive) end
        local f2 = function() return includes(primitive, o) end
        local f3 = function() return includes(primitive, primitive) end
        
        context('should not throw errors', function()
          test('includes(Object, '.. theType ..')', function()
            assert_not_error(f1)
          end)
          test('includes(' .. theType .. ', Object:new())', function()
            assert_not_error(f2)
          end)
          test('includes(' .. theType .. ',' .. theType ..')', function()
            assert_not_error(f3)
          end)
        end)
        
        test('should make includes return false', function()
          assert_false(f1())
          assert_false(f2())
          assert_false(f3())
        end)

      end)
    end -- for

  end)

  context( 'A class', function()

    local Class1 = class('Class1')
    local Class2 = class('Class2', Class1)
    local Class3 = class('Class3', Class2)
    local UnrelatedClass = class('Unrelated')
    
    local hasFoo = { foo=function() return 'foo' end }
    Class1:include(hasFoo)
    
    test('should return true if it includes a mixin', function()
      assert_true(includes(hasFoo, Class1))
    end)
    
    test('should return true if its superclass includes a mixin', function()
      assert_true(includes(hasFoo, Class2))
      assert_true(includes(hasFoo, Class3))
    end)
    
    test('should return false otherwise', function()
      assert_false(includes(hasFoo, UnrelatedClass))
    end)

  end)


end)
