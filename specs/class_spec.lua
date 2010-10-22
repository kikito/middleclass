require('MiddleClass')

context( 'class', function()

  context( 'When creating a class', function()

    context( 'using class("name")', function()
      local TheClass = class('TheClass')

      test( 'should have the correct name', function()
        assert_equal(TheClass.name, 'TheClass')
      end)

      test( 'should have Object as their superclass', function()
        assert_equal(TheClass.superclass, Object)
      end)
    end)

    context( 'using class("name", AClass)', function()
      local TheSuperClass = class('TheSuperClass')
      local TheSubClass = class('TheSubClass', TheSuperClass)

      test( 'should have the correct superclass', function()
       assert_equal(TheSubClass.superclass, TheSuperClass)
      end)
    end)

    context( 'using no name', function()
      test( 'class() should throw an error', function()
        assert_error(class)
      end)
    end)
  
  end)
    

end)
