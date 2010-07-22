require 'erb'


base_dir = Dir.pwd

# Tasks

task :default => :test

task :test do
  lua_load_path = "#{base_dir}/MiddleClass.lua"
  sh "tsc -f --load=\"#{lua_load_path}\" test/*.lua"
end
