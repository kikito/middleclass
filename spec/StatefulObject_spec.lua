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
  
  local GoblinAttacking = Goblin:addState('Attacking')
  function GoblinAttacking:shout() return 'gnaaa!' end

  context('An instance', function()
    local albert = Enemy:new()
    albert:gotoState('Iddle')

    local chester = Goblin:new()
    chester:gotoState('Iddle')

    test( 'should override stateful methods', function()
      assert_equal(albert:getStatus(), 'iddling')
      assert_equal(chester:getStatus(), 'me bored boss')
    end)
    
    context('When it goes from one state to another', function()
      test('it should not throw an error', function()
        assert_not_error(function() chester:gotoState('Attacking') end)
        assert_equal(chester:shout(), 'gnaaa!')
      end)
      test('it should be able to go to the nil-state', function()
        assert_not_error(function() albert:gotoState(nil) end)
        assert_equal(albert:getStatus(), 'none')
      end)
      test('enterState callbacks should be called, if existing', function()
        assert_true(albert.enteredIddle)
        assert_true(chester.enteredIddle)
      end)
      test('exitState on the previous state should be called, if existing', function()
        assert_nil(albert.exitedIddle)
        assert_true(chester.exitedIddle)
      end)
    end)
  end)


end)

