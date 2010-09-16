require('middleclass.init')

context( 'Callbacks', function()
  local A
  
  before(function()
    A = class('A')
    function A:initialize()
      super.initialize(self)
      self.calls = {}
    end
  end)
  
  local function defineRegularMethods(theClass)
    function theClass:foo() table.insert(self.calls, 'foo') end
    function theClass:bar() table.insert(self.calls, 'bar') end
    function theClass:baz() table.insert(self.calls, 'baz') end
  end
  
  local function addCallbacks(theClass)
    theClass:include(Callbacks)
    theClass:addCallbacksAround('bar')
    theClass:beforeBar('foo')
    theClass:afterBar( function(myself) myself:baz() end )
  end
  
  local function testInstance(theClass)
    local obj = theClass:new()
    obj:bar()

    assert_equal(obj.calls[1], 'foo')
    assert_equal(obj.calls[2], 'bar')
    assert_equal(obj.calls[3], 'baz')
  end

  test('Should work when declared before the methods', function()
    addCallbacks(A)
    defineRegularMethods(A)
    testInstance(A)
  end)
  
  test('Should work when declared after the methods', function()
    defineRegularMethods(A)
    addCallbacks(A)
    testInstance(A)
  end)
  
  context('When subclassing', function()
    local B
    before(function()
      B = class('B', A)
    end)

    test('The subclass should include Callbacks', function()
      A:include(Callbacks)
      assert_true(includes(Callbacks, B))
    end)
    
    context('When subclass has the callbacks', function()
      before(function()
        addCallbacks(B)
      end)
      
      test('Inherited methods should work with callbacks', function()
        defineRegularMethods(A)
        testInstance(B)
      end)
    end)
  
  end)


end)
