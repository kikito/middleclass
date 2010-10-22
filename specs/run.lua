#!/usr/bin/env lua

-- command is either specs/run.lua or ./run.lua, with anti-slashes transformed into slashes
local command = debug.getinfo(1).short_src:gsub('\\', '/')

-- This works if command is ./run.lua
local config = {
  package_path = "package.path = '../?.lua'",
  specs_dir= ""
}
-- change config if the command is specs/run.lua
if command == 'specs/run.lua' then
  config = {
    package_path = "package.path = './?.lua'",
    specs_dir= "specs/"
  }
end

os.execute( ("tsc -f --before=%q %s*_spec.lua "):format( config.package_path, config.specs_dir ) )
