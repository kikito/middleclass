require 'erb'


base_dir = Dir.pwd

# Tasks

task :default => :test

task :test do
  lua_path_command = "(function() package.path = '#{base_dir}/lib/?.lua;' .. package.path end)()"
  sh "tsc -f --before=\"#{lua_path_command}\" test/*.lua"
end
