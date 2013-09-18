local class = require 'middleclass'

describe('A Class', function()

  describe('Default stuff', function()

    local AClass

    before_each(function()
      AClass = class('AClass')
    end)

    describe('name', function()
      it('is correctly set', function()
        assert.equal(AClass.name, 'AClass')
      end)
    end)

    describe('tostring', function()
      it('returns "class *name*"', function()
        assert.equal(tostring(AClass), 'class AClass')
      end)
    end)

    describe('()', function()
      it('returns an object, like Class:new()', function()
        local obj = AClass()
        assert.equal(obj.class, AClass)
      end)
    end)

    describe('include', function()
      it('throws an error when used without the :', function()
        assert.error(function() AClass.include() end)
      end)
      it('throws an error when passed a non-table:', function()
        assert.error(function() AClass:include(1) end)
      end)
    end)

    describe('subclass', function()

      it('throws an error when used without the :', function()
        assert.error(function() AClass.subclass() end)
      end)

      it('throws an error when no name is given', function()
        assert.error( function() AClass:subclass() end)
      end)

      describe('when given a subclass name', function()

        local SubClass

        before_each(function()
          function AClass.static:subclassed(other) self.static.child = other end
          SubClass = AClass:subclass('SubClass')
        end)

        it('it returns a class with the correct name', function()
          assert.equal(SubClass.name, 'SubClass')
        end)

        it('it returns a class with the correct superclass', function()
          assert.equal(SubClass.super, AClass)
        end)

        it('it invokes the subclassed hook method', function()
          assert.equal(SubClass, AClass.child)
        end)

        it('it includes the subclass in the list of subclasses', function()
          assert.is_true(AClass.subclasses[SubClass])
        end)

      end)

    end)

  end)



  describe('attributes', function()

    local A, B

    before_each(function()
      A = class('A')
      A.static.foo = 'foo'

      B = class('B', A)
    end)

    it('are available after being initialized', function()
      assert.equal(A.foo, 'foo')
    end)

    it('are available for subclasses', function()
      assert.equal(B.foo, 'foo')
    end)

    it('are overridable by subclasses, without affecting the superclasses', function()
      B.static.foo = 'chunky bacon'
      assert.equal(B.foo, 'chunky bacon')
      assert.equal(A.foo, 'foo')
    end)

  end)

  describe('methods', function()

    local A, B

    before_each(function()
      A = class('A')
      function A.static:foo() return 'foo' end

      B = class('B', A)
    end)

    it('are available after being initialized', function()
      assert.equal(A:foo(), 'foo')
    end)

    it('are available for subclasses', function()
      assert.equal(B:foo(), 'foo')
    end)

    it('are overridable by subclasses, without affecting the superclasses', function()
      function B.static:foo() return 'chunky bacon' end
      assert.equal(B:foo(), 'chunky bacon')
      assert.equal(A:foo(), 'foo')
    end)

  end)

end)
