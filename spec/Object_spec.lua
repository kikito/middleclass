require 'middleclass'

context('Object', function()

  context('name', function()
    test('is correctly set', function()
      assert_equal(Object.name, 'Object')
    end)
  end)

  context('tostring', function()
    test('returns "class Object"', function()
      assert_equal(tostring(Object), 'class Object')
    end)
  end)

  context('()', function()
    test('returns an object, like Object:new()', function()
      local obj = Object()
      assert_true(instanceOf(Object, obj))
    end)
  end)

  context('subclass', function()

    test('throws an error when used without the :', function()
      assert_error(function() Object.subclass() end)
    end)

    context('when given a class name', function()

      local SubClass = Object:subclass('SubClass')

      test('it returns a class with the correct name', function()
        assert_equal(SubClass.name, 'SubClass')
      end)

      test('it returns a class with the correct superclass', function()
        assert_equal(SubClass.superclass, Object)
      end)
    end)

    context('when no name is given', function()
      test('it throws an error', function()
        assert_error( function() Object:subclass() end)
      end)
    end)

  end)

  context('instance creation', function()

    local SubClass
    local classes = { Object, SubClass }

    before(function()
      SubClass = Object:subclass('SubClass')
      function SubClass:initialize() self.mark=true end
    end)

    for _,theClass in ipairs(classes) do
      context(theClass.name, function()

        context('allocate', function()

          test('allocates instances properly', function()
            local instance = theClass:allocate()
            assert_equal(instance.class, theClass)
            assert_equal(tostring(instance), "instance of " .. tostring(theClass))
          end)

          test('throws an error when used without the :', function()
            assert_error(Object.allocate)
          end)

          test('does not call the initializer', function()
            local allocated = theClass:allocate()
            assert_nil(allocated.mark)
          end)

          test('can be overriden', function()

            local previousAllocate = theClass.allocate

            function theClass.static:allocate()
              local instance = previousAllocate(theClass)
              instance.mark = true
              return instance
            end

            local allocated = theClass:allocate()
            assert_true(allocated.mark)
          end)

        end)

        context('new', function()

          test('initializes instances properly', function()
            local instance = theClass:new()
            assert_equal(instance.class, theClass)
          end)

          test('throws an error when used without the :', function()
            assert_error(theClass.new)
          end)

          test('calls the initializer', function()
            local allocated = theClass:new()
            assert_true(allocated.mark)
          end)

        end)

      end)

    end

  end)

end)


