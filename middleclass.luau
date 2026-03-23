--!strict
-- src/shared/util/middleclass.luau
--
-- middleclass v4.1.1 — Object Orientation for Lua, fully typed for Luau.
-- Original: https://github.com/kikito/middleclass  (MIT License, Enrique García Cota)
--
-- ── Usage ─────────────────────────────────────────────────────────────────
--
--   Step 1 — declare the shape of your instances BEFORE creating the class:
--
--     type AnimalProps = { name: string, sound: string }
--     type AnimalMethods = {
--       initialize: (self: Animal, name: string, sound: string) -> (),
--       speak:      (self: Animal) -> string,
--     }
--     type Animal = middleclass.Instance<AnimalProps, AnimalMethods>
--
--   Step 2 — create and cast the class.
--     TNew is the constructor signature (self = the class, then your args):
--
--     local Animal = middleclass.class('Animal')
--       :: middleclass.Class<
--           AnimalProps,
--           AnimalMethods,
--           (self: any, name: string, sound: string) -> Animal
--         >
--
--   Step 3 — implement methods.
--     Use DOT syntax + explicit `self` for autocomplete in --!strict:
--
--     function Animal.initialize(self: Animal, name: string, sound: string)
--       self.name  = name
--       self.sound = sound
--     end
--
--     function Animal.speak(self: Animal): string
--       return self.name .. ' says ' .. self.sound
--     end
--
--   Step 4 — instantiate:
--
--     local cat = Animal:new('Cat', 'meow')  -- typed as Animal ✓
--     cat:speak()                             -- autocompletes   ✓
--
-- ── Inheritance ────────────────────────────────────────────────────────────
--
--     type CatProps   = AnimalProps & { indoor: boolean }
--     type CatMethods = AnimalMethods & { isIndoor: (self: Cat) -> boolean }
--     type Cat = middleclass.Instance<CatProps, CatMethods>
--
--     local Cat = Animal:subclass('Cat')
--       :: middleclass.Class<CatProps, CatMethods,
--                            (self: any, name: string, indoor: boolean) -> Cat>
--
--     function Cat.initialize(self: Cat, name: string, indoor: boolean)
--       Animal.initialize(self :: any, name, 'purr')  -- super call via dot
--       self.indoor = indoor
--     end
--
--     function Cat.isIndoor(self: Cat): boolean
--       return self.indoor
--     end
--
-- ── Mixins ─────────────────────────────────────────────────────────────────
--
--     local Greetable: middleclass.Mixin = {
--       greet = function(self: any): string
--         return 'Hello, I am ' .. self.name
--       end,
--     }
--     Animal:include(Greetable)
--
-- ─────────────────────────────────────────────────────────────────────────

-- ── Exported types ────────────────────────────────────────────────────────

-- An instance of a Class<TProps, TMethods>.
-- Combines public fields (TProps), methods (TMethods), and the built-in
-- members every middleclass instance carries.
export type Instance<TProps, TMethods> = TProps & TMethods & {
  class: ClassBase,
  isInstanceOf: (self: Instance<TProps, TMethods>, aClass: any) -> boolean,
}

-- A middleclass class object.
--
-- TProps   — public fields every instance will carry.
-- TMethods — method signatures; each method's self should be Instance<TProps, TMethods>.
-- TNew     — exact constructor signature shown at call-sites.
--            MUST include `self: any` as first parameter because :new() is
--            called with colon syntax (the class is bound as self).
--            Defaults to (self: any, ...any) -> Instance<TProps, TMethods>.
--
-- Tip: define a type alias for the class to avoid repetition:
--
--   type AnimalClass = middleclass.Class<
--     AnimalProps, AnimalMethods,
--     (self: any, name: string, sound: string) -> Animal
--   >
export type ClassBase = {
  name: string,
  super: ClassBase?,
  new: (self: any, ...any) -> any,
  allocate: (self: ClassBase) -> any,
  subclass: (self: ClassBase, name: string) -> ClassBase,
  subclassed: (self: ClassBase, other: ClassBase) -> (),
  isSubclassOf: (self: ClassBase, other: any) -> boolean,
  include: (self: ClassBase, ...Mixin) -> ClassBase,
  initialize: (self: any, ...any) -> (),
}

export type Class<TProps, TMethods, TNew> = ClassBase & {
  -- Constructor — always call with colon: MyClass:new(...)
  new: TNew,

  -- Allocates a raw instance without calling initialize.
  allocate: (self: Class<TProps, TMethods, TNew>) -> Instance<TProps, TMethods>,

  -- Creates a named subclass that inherits all methods from this class.
  subclass: (self: Class<TProps, TMethods, TNew>, name: string) -> Class<TProps, TMethods, TNew>,

  -- Hook called whenever a subclass is created. Override to react.
  subclassed: (self: Class<TProps, TMethods, TNew>, other: ClassBase) -> (),

  -- Mixes in one or more Mixin tables into this class.
  include: (self: Class<TProps, TMethods, TNew>, ...Mixin) -> Class<TProps, TMethods, TNew>,

  -- Default no-op initializer; override in your class.
  initialize: (self: Instance<TProps, TMethods>, ...any) -> (),
} & TMethods

-- A mixin table that can be passed to Class:include(...)
-- Declare instance methods at the top level and static methods under .static.
-- Optionally provide an `included` hook called when the mixin is mixed in.
export type Mixin = {
  included: ((self: Mixin, aClass: ClassBase) -> ())?,
  static: { [string]: any }?,
  [string]: any,
}

-- ── Internal types ────────────────────────────────────────────────────────

-- Untyped internal representation used by the runtime machinery.
type RawClass = {
  name: string,
  super: RawClass?,
  static: { [string]: any },
  __instanceDict: { [string]: any },
  __declaredMethods: { [string]: any },
  initialize: ((self: any, ...any) -> ())?,
  subclasses: { [RawClass]: boolean },
}

-- ── Implementation ────────────────────────────────────────────────────────

local middleclass = {
  _VERSION     = 'middleclass v5.1.1',
  _DESCRIPTION = 'Object Orientation for Lua',
  _URL         = 'https://github.com/kikito/middleclass',
  _LICENSE     = [[
    MIT LICENSE

    Copyright (c) 2011 Enrique García Cota

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]],
}

local function _createIndexWrapper(aClass: RawClass, f: any): any
  if f == nil then
    return aClass.__instanceDict
  elseif type(f) == 'function' then
    return function(self: any, name: string): any
      local value = aClass.__instanceDict[name]
      if value ~= nil then
        return value
      else
        return (f :: (self: any, name: string) -> any)(self, name)
      end
    end
  else
    return function(_self: any, name: string): any
      local value = aClass.__instanceDict[name]
      if value ~= nil then
        return value
      else
        return (f :: { [string]: any })[name]
      end
    end
  end
end

local function _propagateInstanceMethod(aClass: RawClass, name: string, f: any)
  f = name == '__index' and _createIndexWrapper(aClass, f) or f
  aClass.__instanceDict[name] = f

  for subclass in pairs(aClass.subclasses) do
    if rawget(subclass.__declaredMethods, name) == nil then
      _propagateInstanceMethod(subclass, name, f)
    end
  end
end

local function _declareInstanceMethod(aClass: any, name: string, f: any)
  local raw = aClass :: RawClass
  raw.__declaredMethods[name] = f

  if f == nil and raw.super then
    f = raw.super.__instanceDict[name]
  end

  _propagateInstanceMethod(raw, name, f)
end

local function _tostring(self: RawClass): string
  return 'class ' .. self.name
end

local function _call(self: any, ...: any): any
  return self:new(...)
end

local function _createClass(name: string, super: RawClass?): RawClass
  local dict: { [string]: any } = {}
  dict.__index = dict

  local aClass: RawClass = {
    name = name,
    super = super,
    static = {},
    __instanceDict = dict,
    __declaredMethods = {},
    subclasses = setmetatable({}, { __mode = 'k' }) :: any,
  }

  if super then
    setmetatable(aClass.static, {
      __index = function(_: any, k: string): any
        local result = rawget(dict, k)
        if result == nil then
          return (super :: RawClass).static[k]
        end
        return result
      end,
    })
  else
    setmetatable(aClass.static, {
      __index = function(_: any, k: string): any
        return rawget(dict, k)
      end,
    })
  end

  setmetatable(aClass :: any, {
    __index = aClass.static,
    __tostring = _tostring,
    __call = _call,
    __newindex = _declareInstanceMethod,
  })

  return aClass
end

local function _includeMixin(aClass: RawClass, mixin: Mixin): RawClass
  assert(type(mixin) == 'table', 'mixin must be a table')

  for name, method in pairs(mixin :: { [string]: any }) do
    if name ~= 'included' and name ~= 'static' then
      (aClass :: any)[name] = method
    end
  end

  for name, method in pairs(mixin.static or {}) do
    aClass.static[name] = method
  end

  if type(mixin.included) == 'function' then
    (mixin.included :: (self: Mixin, aClass: RawClass) -> ())(mixin, aClass)
  end

  return aClass
end

local DefaultMixin: Mixin = {
  __tostring = function(self: any): string
    return 'instance of ' .. tostring(self.class)
  end,

  initialize = function(_self: any, ...: any) end,

  isInstanceOf = function(self: any, aClass: any): boolean
    local selfClass = self.class :: Class<any, any, any>
    return type(aClass) == 'table'
      and type(self) == 'table'
      and (
        selfClass == aClass
        or type(selfClass) == 'table'
          and type(selfClass.isSubclassOf) == 'function'
          and selfClass:isSubclassOf(aClass)
      )
  end,

  static = {
    allocate = function(self: any): any
      assert(
        type(self) == 'table',
        "Make sure that you are using 'Class:allocate' instead of 'Class.allocate'"
      )
      return setmetatable({ class = self }, self.__instanceDict)
    end,

    new = function(self: any, ...: any): any
      assert(
        type(self) == 'table',
        "Make sure that you are using 'Class:new' instead of 'Class.new'"
      )
      local instance = self:allocate()
      instance:initialize(...)
      return instance
    end,

    subclass = function(self: any, name: string): any
      assert(
        type(self) == 'table',
        "Make sure that you are using 'Class:subclass' instead of 'Class.subclass'"
      )
      assert(type(name) == 'string', 'You must provide a name(string) for your class')

      local raw = self :: RawClass
      local subclass = _createClass(name, raw)

      for methodName, f in pairs(raw.__instanceDict) do
        if not (methodName == '__index' and type(f) == 'table') then
          _propagateInstanceMethod(subclass, methodName, f)
        end
      end

      subclass.initialize = function(instance: any, ...: any)
        if raw.initialize then
          raw.initialize(instance, ...)
        end
      end

      raw.subclasses[subclass] = true
      self:subclassed(subclass)

      return subclass
    end,

    subclassed = function(_self: any, _other: any) end,

    isSubclassOf = function(self: any, other: any): boolean
      local super = self.super :: Class<any, any, any>
      return type(other) == 'table'
        and type(super) == 'table'
        and (super == other or super:isSubclassOf(other))
    end,

    include = function(self: any, ...: any): any
      assert(
        type(self) == 'table',
        "Make sure you that you are using 'Class:include' instead of 'Class.include'"
      )
      for _, mixin in ipairs({ ... } :: { Mixin }) do
        _includeMixin(self :: RawClass, mixin)
      end
      return self
    end,
  },
}

function middleclass.class(
  name: string,
  super: Class<any, any, any>?
): Class<any, any, (self: any, ...any) -> any>
  assert(type(name) == 'string', 'A name (string) is needed for the new class')
  local raw = super and (super :: any):subclass(name)
    or _includeMixin(_createClass(name, nil), DefaultMixin)
  return raw :: any
end

setmetatable(middleclass :: any, {
  __call = function(_: any, ...: any): Class<any, any, (self: any, ...any) -> any>
    return middleclass.class(...)
  end,
})

return middleclass
