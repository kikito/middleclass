middleclass
===========

[![Build Status](https://travis-ci.org/kikito/middleclass.png?branch=master)](https://travis-ci.org/kikito/middleclass)

A simple OOP library for Lua. It has inheritance, metamethods (operators), class variables and weak mixin support.

h1. Quick Look

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

h1. Documentation

See the "github wiki page":https://github.com/kikito/middleclass/wiki for examples & documentation.

h1. Installation

Just copy the middleclass.lua file wherever you want it (for example on a lib/ folder). Then write this in any Lua file where you want to use it:

    local class = require 'middleclass'

h1. Specs

This project uses [busted](http://olivinelabs.com/busted/) for its specs. If you want to run the specs, you will have to install it first. Then just execute the following:

    cd /folder/where/the/spec/folder/is
    busted

h1. Performance tests

Middleclass also comes with a small performance test suite. Just run the following command:

    lua performance/run.lua


