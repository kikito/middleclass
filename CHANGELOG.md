middleclass changelog
====================

# Version 4.1.1

* Fixed a bug in which `static` values which evaluated to `false` were not available
  in subclasses (#51, thanks @qaisjp for the patch!)
* `isInstanceOf` does not throw an error any more when its first parameter is a
  primitive (#55) (This effectively undoes the change introduced in 4.1.0)


# Version 4.1.0

* Simplifies implementation of `isInstanceOf` and `isSubclassOf`. They will now raise an error if their first
  parameter (the `self`) isn't an instance or a class respectively.

# Version 4.0.0

* Unified the method and metamethod lookup into a single algorithm
* Added the capacity of setting up the `__index` metamethod in classes
* Removed global `Object` (classes created with `class(<name>)` have no superclass now)
* Removed default method `Class:implements(<mixin>)`
* Renamed several internal functions

# Version 3.2.0

* Changed the way metamethods were handled to fix certain bugs (un-stubbed metamethods could not be inherited)

# Version 3.1.0

* Added Lua 5.3 metamethod support (`__band`, `__bor`, `__bxor`, `__shl`, `__bnot`)

# Version 3.0.1

* Added `__len`, `__ipairs` and `__pairs` metamethods for Lua 5.2

# Version 3.0

* Anything that behaves reasonably like a class can be a class (no internal list of classes)
* The `class` global function is now just the return value of `require
'middleclass'`. It is a callable table, but works exactly as before.
* The global variable `Object` becomes `class.Object`
* The global function `instanceOf` becomes `class.Object.isInstanceOf`. Parameter order is reversed.
* The global function `subclassOf` becomes `class.Object.static.isSubclassOf`. Parameter order is reversed.
* The global function `implements` becomes `class.Object.static.implements`. Parameter order is reversed.
* Specs have been translated from telescope to busted

# Version 2.0

* Static methods are now separated from instance methods
* class.superclass has now become class.super
* It's now possible to do class.subclasses
* middleclass is now a single file; init.lua has dissapeared
* license is changed from BSD to MIT. License included in source FTW

