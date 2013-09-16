local class = require 'middleclass'
local Object = class.Object

context('Object.isInstanceOf', function()

  context('nils, integers, strings, tables, and functions', function()
    local o = Object:new()
    local primitives = {nil, 1, 'hello', {}, function() end}

    for _,primitive in pairs(primitives) do
      local theType = type(primitive)
      context('A ' .. theType, function()

        local f1 = function() return Object.isInstanceOf(primitive, Object) end
        local f2 = function() return Object.isInstanceOf(primitive, o) end
        local f3 = function() return Object.isInstanceOf(primitive, primitive) end

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

    test('isInstanceOf(Object)', function()
      assert_true(o1:isInstanceOf(Object))
      assert_true(o2:isInstanceOf(Object))
      assert_true(o3:isInstanceOf(Object))
    end)

    test('isInstanceOf its class', function()
      assert_true(o1:isInstanceOf(Class1))
      assert_true(o2:isInstanceOf(Class2))
      assert_true(o3:isInstanceOf(Class3))
    end)

    test('is instanceOf its class\' superclasses', function()
      assert_true(o2:isInstanceOf(Class1))
      assert_true(o3:isInstanceOf(Class1))
      assert_true(o3:isInstanceOf(Class2))
    end)

    test('is not instanceOf its class\' subclasses', function()
      assert_false(o1:isInstanceOf(Class2))
      assert_false(o1:isInstanceOf(Class3))
      assert_false(o2:isInstanceOf(Class3))
    end)

    test('is not instanceOf an unrelated class', function()
      assert_false(o1:isInstanceOf(UnrelatedClass))
      assert_false(o2:isInstanceOf(UnrelatedClass))
      assert_false(o3:isInstanceOf(UnrelatedClass))
    end)

  end)

end)
