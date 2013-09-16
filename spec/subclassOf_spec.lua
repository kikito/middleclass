local class = require 'middleclass'
local Object = class.Object

context('isSubclassOf', function()

  context('nils, integers, etc', function()
    local primitives = {nil, 1, 'hello', {}, function() end}

    for _,primitive in pairs(primitives) do
      local theType = type(primitive)
      context('A ' .. theType, function()

        local f1 = function() return Object.isSubclassOf(Object, primitive) end
        local f2 = function() return Object.isSubclassOf(primitive, o) end
        local f3 = function() return Object.isSubclassOf(primitive, primitive) end

        context('does not throw errors', function()
          test('isSubclassOf(Object, '.. theType ..')', function()
            assert_not_error(f1)
          end)
          test('isSubclassOf(' .. theType .. ', Object:new())', function()
            assert_not_error(f2)
          end)
          test('isSubclassOf(' .. theType .. ',' .. theType ..')', function()
            assert_not_error(f3)
          end)
        end)

        test('makes isSubclassOf return false', function()
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

    test('isSubclassOf(Object)', function()
      assert_true(Class1:isSubclassOf(Object))
      assert_true(Class2:isSubclassOf(Object))
      assert_true(Class3:isSubclassOf(Object))
    end)

    test('is subclassOf its direct superclass', function()
      assert_true(Class2:isSubclassOf(Class1))
      assert_true(Class3:isSubclassOf(Class2))
    end)

    test('is subclassOf its ancestors', function()
      assert_true(Class3:isSubclassOf(Class1))
    end)

    test('is a subclassOf its class\' subclasses', function()
      assert_true(Class2:isSubclassOf(Class1))
      assert_true(Class3:isSubclassOf(Class1))
      assert_true(Class3:isSubclassOf(Class2))
    end)

    test('is not a subclassOf an unrelated class', function()
      assert_false(Class1:isSubclassOf(UnrelatedClass))
      assert_false(Class2:isSubclassOf(UnrelatedClass))
      assert_false(Class3:isSubclassOf(UnrelatedClass))
    end)

  end)

end)
