-- Test base classes (classes that depend directly from Object)
context( 'Object', function()

  context( 'When creating a subclass of Object', function()

    context( 'using Object:subclass("name")', function()
      local MyClass = Object:subclass('MyClass')

      test( 'it should have its name correctly set up', function()
        assert_equal(MyClass.name, 'MyClass')
      end)

      test( 'it should have Object as its superclass', function()
        assert_equal(MyClass.superclass, Object)
      end)
    end)

    context( 'When no name is given', function()
      test( 'It should throw an error', function()
        assert_false( pcall(Object.subclass, Object) )
      end)
    end)
  
  end)

end)
