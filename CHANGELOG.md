middleclass changelog
====================

Version 3.0.1

* Added `__len`, `__ipairs` and `__pairs` metamethods for Lua 5.2

Version 3.0

* Anything that behaves reasonably like a class can be a class (no internal list of classes)
* The `class` global function is now just the return value of `require
'middleclass'`. It is a callable table, but works exactly as before.
* The global variable `Object` becomes `class.Object`
* The global function `instanceOf` becomes `class.Object.isInstanceOf`. Parameter order is reversed.
* The global function `subclassOf` becomes `class.Object.static.isSubclassOf`. Parameter order is reversed.
* The global function `implements` becomes `class.Object.static.implements`. Parameter order is reversed.
* Specs have been translated from telescope to busted


Version 2.0

* Static methods are now separated from instance methods
* class.superclass has now become class.super
* It's now possible to do class.subclasses
* middleclass is now a single file; init.lua has dissapeared
* license is changed from BSD to MIT. License included in source FTW

