local class = require 'middleclass'
local Object = class.Object

describe('includes', function()

  describe('nils, numbers, etc', function()
    local o = Object:new()
    local primitives = {nil, 1, 'hello', {}, function() end}

    for _,primitive in pairs(primitives) do
      local theType = type(primitive)
      describe('A ' .. theType, function()

        local f1 = function() return Object.includes(Object, primitive) end
        local f2 = function() return Object.includes(primitive, o) end
        local f3 = function() return Object.includes(primitive, primitive) end


        describe('don\'t throw errors', function()
          it('includes(Object, '.. theType ..')', function()
            assert.not_error(f1)
          end)
          it('includes(' .. theType .. ', Object:new())', function()
            assert.not_error(f2)
          end)
          it('includes(' .. theType .. ',' .. theType ..')', function()
            assert.not_error(f3)
          end)
        end)

        it('make includes return false', function()
          assert.is_false(f1())
          assert.is_false(f2())
          assert.is_false(f3())
        end)

      end)
    end -- for

  end)

  describe('A class', function()

    local Class1 = class('Class1')
    local Class2 = class('Class2', Class1)
    local Class3 = class('Class3', Class2)
    local UnrelatedClass = class('Unrelated')

    local hasFoo = { foo=function() return 'foo' end }
    Class1:include(hasFoo)

    it('returns true if it includes a mixin', function()
      assert.is_true(Class1:includes(hasFoo))
    end)

    it('returns true if its superclass includes a mixin', function()
      assert.is_true(Class2:includes(hasFoo))
      assert.is_true(Class3:includes(hasFoo))
    end)

    it('returns false otherwise', function()
      assert.is_false(UnrelatedClass:includes(hasFoo))
    end)

  end)

end)

