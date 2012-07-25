package = "middleclass"
version = "2.0-0"
source = {
   url = "url",
}
description = {
   summary = "Tools to make your life as a Lua developer more pleasant",
   homepage = "http://luaforge.net",
   license = "MIT/X11"
}
dependencies = {
   "lua >= 5.1"
}
build = {
   type = "builtin",
   modules = {
      ["middleclass"] = "middleclass.lua",
   }
}
