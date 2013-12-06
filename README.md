middleclass
===========

[![Build Status](https://travis-ci.org/kikito/middleclass.png?branch=master)](https://travis-ci.org/kikito/middleclass)

A simple OOP library for Lua. It has inheritance, metamethods (operators), class variables and weak mixin support.

Quick Look
==========

    local class = require 'middleclass'

    local Fruit = class('Fruit') -- 'Fruit' is the class' name

    function Fruit:initialize(sweetness)
      self.sweetness = sweetness
    end

    Fruit.static.sweetness_threshold = 5 -- class variable (also admits methods)

    function Fruit:isSweet()
      return self.sweetness > Fruit.sweetness_threshold
    end

    local Lemon = class('Lemon', Fruit) -- subclassing

    function Lemon:initialize()
      Fruit.initialize(self, 1) -- invoking the superclass' initializer
    end

    local lemon = Lemon:new()

    print(lemon:isSweet()) -- false

Documentation
=============

See the [github wiki page](https://github.com/kikito/middleclass/wiki) for examples & documentation.

Installation
============

Just copy the middleclass.lua file wherever you want it (for example on a lib/ folder). Then write this in any Lua file where you want to use it:

    local class = require 'middleclass'

Specs
=====

This project uses [busted](http://olivinelabs.com/busted/) for its specs. If you want to run the specs, you will have to install it first. Then just execute the following:

    cd /folder/where/the/spec/folder/is
    busted

Performance tests
=================

Middleclass also comes with a small performance test suite. Just run the following command:

    lua performance/run.lua

License
=======

Middleclass is distributed under the MIT license.

Updating from 2.x
=================

Middleclass used to expose several global variables on the main scope. It does not do that any more.

`class` is now returned by `require 'middleclass'`, and it is not set globally. So you can do this:

    local class = require 'middleclass'
    local MyClass = class('MyClass') -- works as before

`Object` is not a global variable any more. But you can get it from `class.Object`

    local class = require 'middleclass'
    local Object = class.Object

    print(Object) -- prints 'class Object'

The public functions `instanceOf`, `subclassOf` and `includes` have been replaced by `Object.isInstanceOf`, `Object.static.isSubclassOf` and `Object.static.includes`.

Before:

    instanceOf(MyClass, obj)
    subclassOf(Object, aClass)
    includes(aMixin, aClass)

After:

    obj:isInstanceOf(MyClass)
    aClass:isSubclassOf(Object)
    aClass:includes(aMixin)

The previous code will throw an error if `obj` is not an object, or if `aClass` is not a class (since they will not implement `isInstanceOf`, `isSubclassOf` or `includes`).
If you are unsure of wether `obj` and `aClass` are an object or a class, you can use the methods in `Object`. They are prepared to work with random types, not just classes and instances:

    Object.isInstanceOf(obj, MyClass)
    Object.isSubclassOf(aClass, Object)
    Object.includes(aClass, aMixin)

Notice that the parameter order is not the same now as it was in 2.x. Also note the change in naming: `isInstanceOf` instead of `istanceOf`, and `isSubclassOf` instead of `subclassOf`.



