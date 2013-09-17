local class = require 'middleclass'
local Object = class.Object

describe('Object.isInstanceOf', function()

  describe('nils, integers, strings, tables, and functions', function()
    local o = Object:new()
    local primitives = {nil, 1, 'hello', {}, function() end}

    for _,primitive in pairs(primitives) do
      local theType = type(primitive)
      describe('A ' .. theType, function()

        local f1 = function() return Object.isInstanceOf(primitive, Object) end
        local f2 = function() return Object.isInstanceOf(primitive, o) end
        local f3 = function() return Object.isInstanceOf(primitive, primitive) end

        describe('does not throw errors', function()
          it('instanceOf(Object, '.. theType ..')', function()
            assert.not_error(f1)
          end)
          it('instanceOf(' .. theType .. ', Object:new())', function()
            assert.not_error(f2)
          end)
          it('instanceOf(' .. theType .. ',' .. theType ..')', function()
            assert.not_error(f3)
          end)
        end)

        it('makes instanceOf return false', function()
          assert.is_false(f1())
          assert.is_false(f2())
          assert.is_false(f3())
        end)

      end)
    end

  end)

  describe('An instance', function()
    local Class1 = class('Class1')
    local Class2 = class('Class2', Class1)
    local Class3 = class('Class3', Class2)
    local UnrelatedClass = class('Unrelated')

    local o1, o2, o3 = Class1:new(), Class2:new(), Class3:new()

    it('isInstanceOf(Object)', function()
      assert.is_true(o1:isInstanceOf(Object))
      assert.is_true(o2:isInstanceOf(Object))
      assert.is_true(o3:isInstanceOf(Object))
    end)

    it('isInstanceOf its class', function()
      assert.is_true(o1:isInstanceOf(Class1))
      assert.is_true(o2:isInstanceOf(Class2))
      assert.is_true(o3:isInstanceOf(Class3))
    end)

    it('is instanceOf its class\' superclasses', function()
      assert.is_true(o2:isInstanceOf(Class1))
      assert.is_true(o3:isInstanceOf(Class1))
      assert.is_true(o3:isInstanceOf(Class2))
    end)

    it('is not instanceOf its class\' subclasses', function()
      assert.is_false(o1:isInstanceOf(Class2))
      assert.is_false(o1:isInstanceOf(Class3))
      assert.is_false(o2:isInstanceOf(Class3))
    end)

    it('is not instanceOf an unrelated class', function()
      assert.is_false(o1:isInstanceOf(UnrelatedClass))
      assert.is_false(o2:isInstanceOf(UnrelatedClass))
      assert.is_false(o3:isInstanceOf(UnrelatedClass))
    end)

  end)

end)
