require 'middleclass'

time = require 'performance/time'

time('class creation', function()
  local c = class('A')
end)
