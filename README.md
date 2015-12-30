middleclass
===========

[![Build Status](https://travis-ci.org/kikito/middleclass.png?branch=master)](https://travis-ci.org/kikito/middleclass)
[![Coverage Status](https://coveralls.io/repos/kikito/middleclass/badge.svg?branch=master&service=github)](https://coveralls.io/github/kikito/middleclass?branch=master)

A simple OOP library for Lua. It has inheritance, metamethods (operators), class variables and weak mixin support.

Quick Look
==========

```lua
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
```

Documentation
=============

See the [github wiki page](https://github.com/kikito/middleclass/wiki) for examples & documentation.

You can read the `CHANGELOG.md` file to see what has changed on each version of this library.

If you need help updating to a new middleclass version, read `UPDATING.md`.

Installation
============

Just copy the middleclass.lua file wherever you want it (for example on a lib/ folder). Then write this in any Lua file where you want to use it:

```lua
local class = require 'middleclass'
```

Specs
=====

This project uses [busted](http://olivinelabs.com/busted/) for its specs. If you want to run the specs, you will have to install it first. Then just execute the following:

```bash
cd /folder/where/the/spec/folder/is
busted
```

Performance tests
=================

Middleclass also comes with a small performance test suite. Just run the following command:

```bash
lua performance/run.lua
```

License
=======

Middleclass is distributed under the MIT license.


