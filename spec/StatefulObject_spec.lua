require('MiddleClass')
require('MindState')

context( 'StatefulObject', function()


  context('A State', function()

    test('should require 3 parameters when subclassed', function()
      assert_error(function() State:subclass() end)
      assert_error(function() State:subclass('meh') end)
    end)
      
    test('Super calls should work correctly', function()
      local SuperClass = class('SuperClass', StatefulObject)
      function SuperClass:foo() return 'foo' end
      
      local RootClass = class('RootClass', SuperClass)

      local State1 = RootClass:addState('State1')
      function State1:foo() return(super.foo(self) .. 'state1') end

      local State2 = RootClass:addState('State2', State1)
      function State2:foo() return(super.foo(self) .. 'state2') end

      local obj = RootClass:new()
      
      obj:gotoState('State1')
      assert_equal(obj:foo(), 'foostate1')
      
      obj:gotoState('State2')
      assert_equal(obj:foo(), 'foostate1state2')
    end)

  end)

  context('A stateful class', function()
    local Warrior = class('Warrior', StatefulObject)
    local WarriorIddle, WarriorWalking

    context('When adding a new state', function()
      
      test('should not throw errors', function()
        assert_not_error(function() WarriorIddle = Warrior:addState('Iddle') end)
        function WarriorIddle:speak() return 'iddle' end
      end)
      
      test('should return the existing state if it already exists', function()
        assert_equal(Warrior:addState('Iddle'), WarriorIddle)
        assert_equal(Warrior:addState('Iddle'), Warrior.states.Iddle)
      end)
      
      test('should work with superstates', function()
        assert_not_error(function()
          WarriorWalking = Warrior:addState('Walking', WarriorIddle)
        end)
        
        function WarriorWalking:walk() return 'tap tap tap' end

        local novita = Warrior:new()
        novita:gotoState('Walking')
        
        assert_equal(novita:speak(), 'iddle') -- inherited from Warrioriddle
        assert_equal(novita:walk(), 'tap tap tap')
        assert_true(subclassOf(WarriorIddle, WarriorWalking))
      end)
    end)
    
    context('When subclassing', function()

      local Vehicle = class('Vehicle', StatefulObject)
      Vehicle:addState('Parked')
      function Vehicle.states.Parked:getStatus() return 'stopped' end

      local Tank = class('Tank', Vehicle)
      
      test('The subclass should inherit the superclass states', function()
        
        assert_true(subclassOf(Vehicle.states.Parked, Tank.states.Parked))

        panzer = Tank:new()
        panzer:gotoState('Parked')
        
        assert_equal(panzer:getStatus(), 'stopped')
      end)
    end)
    
    context('When including a mixin', function()
      local Class1 = class('Class1', StatefulObject)

      local State1 = Class1:addState('State1')
      function State1:foo() return 'state1' end
      
      local Mixin = {
        included = function(mixin, theClass) theClass.includesMixin = true end,
        foo = function() return 'mixin' end,
        states = {
          State1 = {
            bar = function() return 'bar' end
          },
          State2 = {
            foo = function() return 'state2' end
          }
        }
      }
      
      Class1:include(Mixin)
      
      local obj = Class1:new()
      
      test('should invoke the "included" method when included', function()
        assert_true(Class1.includesMixin)
      end)
      
      test('should have all its functions (except "included") copied to its target class', function()
        assert_equal(Class1:foo(), 'mixin')
        assert_equal(Class1.included, nil)
      end)
      
      test('should have new states', function()
        assert_true(subclassOf(State, Class1.states.State2))
        obj:gotoState('State2')
        assert_equal(obj:foo(), 'state2')
      end)
      
      test('existing states should be modified', function()
        assert_true(includes(Mixin.states.State1, Class1.states.State1))
        obj:gotoState('State1')
        assert_equal(obj:foo(), 'state1')
        assert_equal(obj:bar(), 'bar')
      end)

    end)

  end)

  context('A stateful instance', function()

    local Enemy = class('Enemy', StatefulObject)
    function Enemy:getStatus() return 'none' end

    local EnemyIddle = Enemy:addState('Iddle')
    function EnemyIddle:enterState() self.enteredIddle = true end
    function EnemyIddle:getStatus() return 'iddling' end

    local Goblin = class('Goblin', Enemy)

    local GoblinIddle = Goblin:addState('Iddle')
    function GoblinIddle:getStatus() return 'me bored boss' end
    function GoblinIddle:exitState() self.exitedIddle = true end
    function GoblinIddle:pausedState() self.pausedIddle = true end
    function GoblinIddle:poppedState() self.poppedIddle = true end
    function GoblinIddle:continuedState() self.continuedIddle = true end
    
    local GoblinAttacking = Goblin:addState('Attacking')
    function GoblinAttacking:pushedState() self.pushedAttacking = true end
    function GoblinAttacking:enterState() self.enteredAttacking = true end
    function GoblinAttacking:shout() return 'gnaaa!' end
    function GoblinAttacking:poppedState() self.poppedAttacking = true end

    context('When it goes from one state to another', function()
      local albert = Enemy:new()
      albert:gotoState('Iddle')

      local chester = Goblin:new()
      chester:gotoState('Iddle')
    
      test('should not throw an error for a valid state name', function()
        assert_not_error(function() chester:gotoState('Attacking') end)
        assert_equal(chester:shout(), 'gnaaa!')
      end)
      test('should throw an error for an invalid state name', function()
        assert_error(function() albert:gotoState('Sleeping') end)
      end)
      test('should be able to go to the nil-state', function()
        assert_not_error(function() albert:gotoState(nil) end)
        assert_equal(albert:getStatus(), 'none')
      end)
      test('enterState callbacks should be called, if existing', function()
        assert_true(albert.enteredIddle)
        assert_true(chester.enteredIddle)
      end)
      test('exitState callbacks should be called, if existing', function()
        assert_nil(albert.exitedIddle)
        assert_true(chester.exitedIddle)
      end)
    end)
    
    context('When pushing states', function()
      local andrew = Enemy:new()
      local ian = Goblin:new()

      test('should error if the statename is invalid', function()
        assert_error(function() andrew:pushState(nil) end)
        assert_error(function() andrew:pushState('Sleeping') end)
      end)
      test('should correctly push valid states, without errors', function()
        assert_not_error(function() ian:pushState('Iddle') end)
        assert_not_error(function() ian:pushState('Attacking') end)
        assert_equal(ian:shout(), 'gnaaa!')
        assert_equal(ian:getStatus(), 'me bored boss')
      end)
      test('pushing the same state several times should not throw errors', function()
        assert_not_error(function() andrew:pushState('Iddle') end)
        assert_not_error(function() andrew:pushState('Iddle') end)
      end)
      test('enterState callbacks should be called, if existing', function()
        assert_true(andrew.enteredIddle)
        assert_true(ian.enteredIddle)
      end)
      test('pushedState callbacks should be called, if existing', function()
        assert_nil(andrew.pushedAttacking)
        assert_true(ian.pushedAttacking)
      end)
      test('pausedState callbacks should be called, if existing', function()
        assert_nil(andrew.pausedIddle)
        assert_true(ian.pausedIddle)
      end)
      
    end)

    context('When popping states', function()
      local renfield = Goblin:new()
      
      -- reset vlad and renfield before each test
      before(function()
        renfield = Goblin:new()
      end)

      test('should be able to pop states by name, calling callbacks', function()
        renfield:pushState('Iddle')
        renfield:pushState('Attacking')

        assert_not_error(function() renfield:popState('Iddle') end)
        assert_equal(renfield:getStatus(), 'none')
        assert_equal(renfield:shout(), 'gnaaa!')
        assert_true(renfield.poppedIddle)
        assert_true(renfield.exitedIddle)
      end)

      test('should be able to pop the top state, with appropiate callbacks', function()
        renfield:pushState('Iddle')
        renfield:pushState('Attacking')

        assert_not_error(function() renfield:popState() end)
        assert_equal(renfield:getStatus(), 'me bored boss')
        assert_error(function() renfield:shout() end)
        assert_true(renfield.poppedAttacking)
        assert_true(renfield.continuedIddle)
      end)
      
      test('popping the same state several times should not throw errors, and call no callbacks', function()
        renfield:pushState('Iddle')
        renfield:popState('Iddle')
        renfield.poppedIddle = nil
        assert_not_error(function() renfield:popState('Iddle') end)
        assert_nil(renfield.poppedIddle)
      end)
      
      test('popping inexistant states should not throw errors', function()
        assert_not_error(function() renfield:popState('Foo') end)
      end)
     
      test('popAllStates should work correctly and invoke all required callbacks', function()
        renfield:pushState('Iddle')
        renfield:pushState('Attacking')
      
        assert_not_error(function() renfield:popAllStates() end)
        assert_true(renfield.poppedAttacking)
        assert_true(renfield.continuedIddle)
        assert_true(renfield.poppedIddle)
        assert_true(renfield.exitedIddle)
      end)

    end)
    
    context('When testing whether it is on one state', function()
      local igor = Goblin:new()
      
      test('should return true if the state is on the top of the stack', function() 
        igor:gotoState('Iddle')
        assert_true(igor:isInState('Iddle'))
      end)
      
      test('should return true if the state is on the stack and "testStateStack" is true', function()
        igor:pushState('Attacking')
        assert_true(igor:isInState('Attacking'))
        assert_true(igor:isInState('Iddle', true))
      end)
      
      test('should return false otherwise', function()
        assert_false(igor:isInState(nil))
        assert_false(igor:isInState('Foo', true))
      end)
    end)
    
    context('When getting the current state name', function()
      local peppy = Goblin:new()
      
      test('should return nil when on nil-state', function()
        assert_nil(peppy:getCurrentStateName())
      end)
      
      test('should return the top-of-the-stack statename otherwise', function()
        peppy:pushState('Iddle')
        assert_equal(peppy:getCurrentStateName(), 'Iddle')
        peppy:pushState('Attacking')
        assert_equal(peppy:getCurrentStateName(), 'Attacking')
      end)
    end)

  end) -- context 'An Instance'

end)

