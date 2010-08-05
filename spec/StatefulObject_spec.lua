require('MiddleClass')
require('MindState')

context( 'StatefulObject', function()

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
  
  local GoblinAttacking = Goblin:addState('Attacking')
  function GoblinAttacking:pushedState() self.pushedAttacking = true end
  function GoblinAttacking:enterState() self.enteredAttacking = true end
  function GoblinAttacking:shout() return 'gnaaa!' end

  context('An instance', function()

    context('When it goes from one state to another', function()
      local albert = Enemy:new()
      albert:gotoState('Iddle')

      local chester = Goblin:new()
      chester:gotoState('Iddle')
    
      test('it should not throw an error for a valid state name', function()
        assert_not_error(function() chester:gotoState('Attacking') end)
        assert_equal(chester:shout(), 'gnaaa!')
      end)
      test('it should throw an error for an invalid state name', function()
        assert_error(function() albert:gotoState('Sleeping') end)
      end)
      test('it should be able to go to the nil-state', function()
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
    
    context('When pushing one state on the stack', function()
      local andrew = Enemy:new()
      local ian = Goblin:new()

      test('it should error if the statename is invalid', function()
        assert_error(function() andrew:pushState(nil) end)
        assert_error(function() andrew:pushState('Sleeping') end)
      end)
      test('it should correctly push valid states, without errors', function()
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
  end)


end)

