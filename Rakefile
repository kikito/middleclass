require 'erb'

base_dir = Dir.pwd

# Tasks

task :default => :test

task :test do
  lua_path_command = "package.path = '#{base_dir}/middleclass/?.lua;' .. package.path"
  sh "tsc -f --before=\"#{lua_path_command}\" spec/*.lua"
end
