package = "middleclass"
version = "2.0-0"
source = {
   url = "https://github.com/kikito/middleclass/tarball/master",
}
description = {
   summary = "Object-orientation for Lua",
   homepage = "https://github.com/kikito/middleclass",
   license = "MIT-LICENSE"
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
