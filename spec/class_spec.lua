local class = require 'middleclass'

describe('class()', function()

  describe('when given no params', function()
    it('it throws an error', function()
      assert.error(class)
    end)
  end)

  describe('when given a name', function()
    it('the resulting class has the correct name and Object as its superclass', function()
      local TheClass = class('TheClass')
      assert.equal(TheClass.name, 'TheClass')
      assert.is_nil(TheClass.super)
    end)
  end)

  describe('when given a name and a superclass', function()
    it('the resulting class has the correct name and superclass', function()
      local TheSuperClass = class('TheSuperClass')
      local TheSubClass = class('TheSubClass', TheSuperClass)
      assert.equal(TheSubClass.name, 'TheSubClass')
      assert.equal(TheSubClass.super, TheSuperClass)
    end)
  end)

end)
