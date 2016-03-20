Updating from 3.x to 4.x
========================

In middleclass 4.0 there is no global `Object` class any more. Classes created with `class(<name>)` don't have a superclass any more.
If you need a global `Object` class, you must create it explicitly and then use it when creating new classes:

```lua
local Object = class('Object')

...

local MyClass = class('MyClass', Object)
```

If you are using a library which depends on the internal implementation of middleclass they might not work with middleclass 4.0. You might need to update those other libraries.

Middleclass 4.0 comes with support for `__index` metamethod support. If your library manipulated the classes' `__instanceDict` internal attribute, you might do the same thing now using `__index` instead.

Also note that the class method `:implements` has been removed.

Updating from 2.x to 3.x
========================

Middleclass used to expose several global variables on the main scope. It does not do that anymore.

`class` is now returned by `require 'middleclass'`, and it is not set globally. So you can do this:

```lua
local class = require 'middleclass'
local MyClass = class('MyClass') -- works as before
```

`Object` is not a global variable any more. But you can get it from `class.Object`

```lua
local class = require 'middleclass'
local Object = class.Object

print(Object) -- prints 'class Object'
```

The public functions `instanceOf`, `subclassOf` and `includes` have been replaced by `Object.isInstanceOf`, `Object.static.isSubclassOf` and `Object.static.includes`.

Prior to 3.x:

```lua
instanceOf(MyClass, obj)
subclassOf(Object, aClass)
includes(aMixin, aClass)
```

Since 3.x:

```lua
obj:isInstanceOf(MyClass)
aClass:isSubclassOf(Object)
aClass:includes(aMixin)
```

The 3.x code snippet will throw an error if `obj` is not an object, or if `aClass` is not a class (since they will not implement `isInstanceOf`, `isSubclassOf` or `includes`).
If you are unsure of whether `obj` and `aClass` are an object or a class, you can use the methods in `Object`. They are prepared to work with random types, not just classes and instances:

```lua
Object.isInstanceOf(obj, MyClass)
Object.isSubclassOf(aClass, Object)
Object.includes(aClass, aMixin)
```

Notice that the parameter order is not the same now as it was in 2.x. Also note the change in naming: `isInstanceOf` instead of `instanceOf`, and `isSubclassOf` instead of `subclassOf`.
