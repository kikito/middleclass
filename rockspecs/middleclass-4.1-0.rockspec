package = "middleclass"
version = "4.1-0"
source = {
  url = "https://github.com/kikito/middleclass/archive/v4.1.0.tar.gz",
  dir = "middleclass-4.1.0"
}
description = {
   summary = "A simple OOP library for Lua",
   detailed = "It has inheritance, metamethods (operators), class variables and weak mixin support",
   homepage = "https://github.com/kikito/middleclass",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1"
}
build = {
   type = "builtin",
   modules = {
      middleclass = "middleclass.lua"
   }
}
