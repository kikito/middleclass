local class = require 'middleclass'
local Object = class.Object

describe('Object', function()


  describe('name', function()
    it('is correctly set', function()
      assert.equal(Object.name, 'Object')
    end)
  end)

  describe('tostring', function()
    it('returns "class Object"', function()
      assert.equal(tostring(Object), 'class Object')
    end)
  end)

  describe('()', function()
    it('returns an object, like Object:new()', function()
      local obj = Object()
      assert.is_true(obj:isInstanceOf(Object))
    end)
  end)

  describe('subclass', function()

    it('throws an error when used without the :', function()
      assert.error(function() Object.subclass() end)
    end)

    it('throws an error when no name is given', function()
      assert.error( function() Object:subclass() end)
    end)

    describe('when given a class name', function()

      local SubClass

      before_each(function()
        SubClass = Object:subclass('SubClass')
      end)

      it('it returns a class with the correct name', function()
        assert.equal(SubClass.name, 'SubClass')
      end)

      it('it returns a class with the correct superclass', function()
        assert.equal(SubClass.super, Object)
      end)

      it('it includes the subclass in the list of subclasses', function()
        assert.is_true(Object.subclasses[SubClass])
      end)

    end)

  end)

  describe('instance creation', function()

    local SubClass

    before_each(function()
      SubClass = class('SubClass')
      function SubClass:initialize() self.mark=true end
    end)

    describe('allocate', function()

      it('allocates instances properly', function()
        local instance = SubClass:allocate()
        assert.equal(instance.class, SubClass)
        assert.equal(tostring(instance), "instance of " .. tostring(SubClass))
      end)

      it('throws an error when used without the :', function()
        assert.error(Object.allocate)
      end)

      it('does not call the initializer', function()
        local allocated = SubClass:allocate()
        assert.is_nil(allocated.mark)
      end)

      it('can be overriden', function()

        local previousAllocate = SubClass.static.allocate

        function SubClass.static:allocate()
          local instance = previousAllocate(SubClass)
          instance.mark = true
          return instance
        end

        local allocated = SubClass:allocate()
        assert.is_true(allocated.mark)

      end)

    end)

    describe('new', function()

      it('initializes instances properly', function()
        local instance = SubClass:new()
        assert.equal(instance.class, SubClass)
      end)

      it('throws an error when used without the :', function()
        assert.error(SubClass.new)
      end)

      it('calls the initializer', function()
        local initialized = SubClass:new()
        assert.is_true(initialized.mark)
      end)

    end)

    describe('isInstanceOf', function()

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

  end)

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


end)


