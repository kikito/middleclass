-- middleclass.lua - v2.0 (2011-09)
-- Copyright (c) 2011 Enrique García Cota
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
-- Based on YaciCode, from Julien Patte and LuaObject, from Sebastien Rocca-Serra

local _classes = setmetatable({}, {__mode = "k"})

local function _setClassDictionariesMetatables(klass)
  local dict = klass.__instanceDict
  dict.__index = dict

  local super = klass.super
  if super then
    local superStatic = super.static
    setmetatable(dict, super.__instanceDict)
    setmetatable(klass.static, { __index = function(_,k) return dict[k] or superStatic[k] end })
  else
    setmetatable(klass.static, { __index = function(_,k) return dict[k] end })
  end
end

local function _setClassMetatable(klass)
  setmetatable(klass, {
    __tostring = function() return "class " .. klass.name end,
    __index    = klass.static,
    __newindex = klass.__instanceDict,
    __call     = function(self, ...) return self:new(...) end
  })
end

local function _createClass(name, super)
  local klass = { name = name, super = super, static = {}, __mixins = {}, __instanceDict={} }
  klass.subclasses = setmetatable({}, {__mode = "k"})

  _setClassDictionariesMetatables(klass)
  _setClassMetatable(klass)
  _classes[klass] = true

  return klass
end

local function _createLookupMetamethod(klass, name)
  return function(...)
    local method = klass.super[name]
    assert( type(method)=='function', tostring(klass) .. " doesn't implement metamethod '" .. name .. "'" )
    return method(...)
  end
end

local function _setClassMetamethods(klass)
  for _,m in ipairs(klass.__metamethods) do
    klass[m]= _createLookupMetamethod(klass, m)
  end
end

local function _setDefaultInitializeMethod(klass, super)
  klass.initialize = function(instance, ...)
    return super.initialize(instance, ...)
  end
end

local function _includeMixin(klass, mixin)
  assert(type(mixin)=='table', "mixin must be a table")
  for name,method in pairs(mixin) do
    if name ~= "included" and name ~= "static" then klass[name] = method end
  end
  if mixin.static then
    for name,method in pairs(mixin.static) do
      klass.static[name] = method
    end
  end
  if type(mixin.included)=="function" then mixin:included(klass) end
  klass.__mixins[mixin] = true
end

Object = _createClass("Object", nil)

Object.static.__metamethods = { '__add', '__call', '__concat', '__div', '__le', '__lt', 
                                '__mod', '__mul', '__pow', '__sub', '__tostring', '__unm' }

function Object.static:allocate()
  assert(_classes[self], "Make sure that you are using 'Class:allocate' instead of 'Class.allocate'")
  return setmetatable({ class = self }, self.__instanceDict)
end

function Object.static:new(...)
  local instance = self:allocate()
  instance:initialize(...)
  return instance
end

function Object.static:subclass(name, spec)
  assert(_classes[self], "Make sure that you are using 'Class:subclass' instead of 'Class.subclass'")
  assert(type(name) == "string", "You must provide a name(string) for your class")

  spec = spec or {}

  local subclass = _createClass(name, self)
  _setClassMetamethods(subclass)
  _setDefaultInitializeMethod(subclass, self)
  self.subclasses[subclass] = true
  self:subclassed(subclass)

  for k, v in pairs(spec) do
    if k == "static" then
      for k1, v1 in pairs(v) do
        subclass.static[k1] = v1
      end
    else
      subclass[k] = v
    end
  end

  return subclass
end

function Object.static:subclassed(other) end

function Object.static:include( ... )
  assert(_classes[self], "Make sure you that you are using 'Class:include' instead of 'Class.include'")
  for _,mixin in ipairs({...}) do _includeMixin(self, mixin) end
  return self
end

function Object:initialize() end

function Object:__tostring() return "instance of " .. tostring(self.class) end

function class(name, ...)
  local super, spec = ...
  if not super then
    super = Object
    spec = {}
  elseif not _classes[super] then
    spec = super
    super = Object
  end

  return super:subclass(name, spec)
end

function instanceOf(aClass, obj)
  if not _classes[aClass] or type(obj) ~= 'table' or not _classes[obj.class] then return false end
  if obj.class == aClass then return true end
  return subclassOf(aClass, obj.class)
end

function subclassOf(other, aClass)
  if not _classes[aClass] or not _classes[other] or aClass.super == nil then return false end
  return aClass.super == other or subclassOf(other, aClass.super)
end

function includes(mixin, aClass)
  if not _classes[aClass] then return false end
  if aClass.__mixins[mixin] then return true end
  return includes(mixin, aClass.super)
end
