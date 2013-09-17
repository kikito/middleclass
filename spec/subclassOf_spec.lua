local class = require 'middleclass'
local Object = class.Object

describe('isSubclassOf', function()

  describe('nils, integers, etc', function()
    local primitives = {nil, 1, 'hello', {}, function() end}

    for _,primitive in pairs(primitives) do
      local theType = type(primitive)
      describe('A ' .. theType, function()

        local f1 = function() return Object.isSubclassOf(Object, primitive) end
        local f2 = function() return Object.isSubclassOf(primitive, o) end
        local f3 = function() return Object.isSubclassOf(primitive, primitive) end

        describe('does not throw errors', function()
          it('isSubclassOf(Object, '.. theType ..')', function()
            assert.not_error(f1)
          end)
          it('isSubclassOf(' .. theType .. ', Object:new())', function()
            assert.not_error(f2)
          end)
          it('isSubclassOf(' .. theType .. ',' .. theType ..')', function()
            assert.not_error(f3)
          end)
        end)

        it('makes isSubclassOf return false', function()
          assert.is_false(f1())
          assert.is_false(f2())
          assert.is_false(f3())
        end)

      end)
    end

  end)

  describe('Any class (except Object)', function()
    local Class1 = class('Class1')
    local Class2 = class('Class2', Class1)
    local Class3 = class('Class3', Class2)
    local UnrelatedClass = class('Unrelated')

    it('isSubclassOf(Object)', function()
      assert.is_true(Class1:isSubclassOf(Object))
      assert.is_true(Class2:isSubclassOf(Object))
      assert.is_true(Class3:isSubclassOf(Object))
    end)

    it('is subclassOf its direct superclass', function()
      assert.is_true(Class2:isSubclassOf(Class1))
      assert.is_true(Class3:isSubclassOf(Class2))
    end)

    it('is subclassOf its ancestors', function()
      assert.is_true(Class3:isSubclassOf(Class1))
    end)

    it('is a subclassOf its class\' subclasses', function()
      assert.is_true(Class2:isSubclassOf(Class1))
      assert.is_true(Class3:isSubclassOf(Class1))
      assert.is_true(Class3:isSubclassOf(Class2))
    end)

    it('is not a subclassOf an unrelated class', function()
      assert.is_false(Class1:isSubclassOf(UnrelatedClass))
      assert.is_false(Class2:isSubclassOf(UnrelatedClass))
      assert.is_false(Class3:isSubclassOf(UnrelatedClass))
    end)

  end)

end)
