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


  end)

end)


