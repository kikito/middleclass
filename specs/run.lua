#!/usr/bin/env lua

-- command should be specs/run.lua
local command = debug.getinfo(1).short_src:gsub('\\', '/')

if command ~= 'specs/run.lua' then
  error('You must run the specs like this: specs/run.lua (or specs\\run.lua for windows)')
end

-- This only works if command is spec/run.lua
local config = {
  package_path = "package.path = './?.lua'",
  specs_dir= "specs/"
}

os.execute( ("tsc -f --before=%q %s*_spec.lua "):format( config.package_path, config.specs_dir ) )
