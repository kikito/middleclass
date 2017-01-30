local iterations = 500000

local time = function(preparation_str, test_str)
  local code = ([[
    %s
    collectgarbage()
    local startTime = os.clock()
    for i=0,%d do
      %s
    end
    local endTime = os.clock()
    return endTime - startTime
  ]]):format(preparation_str, iterations, test_str)

  local loadstring = _G.loadstring or _G.load
  return loadstring(code)()
end

local time_lib = function(lib_path)
  local pre = ([[
    local class = require '%s'

    local A = class('A')

    function A:foo()
      return 1
    end

    function A.static:bar()
      return 2
    end

    local B = class('B', A)

    local a = A:new()
    local b = B:new()
  ]]):format(lib_path)

  return {
    class_creation          = time(pre, "class('A')"),
    instance_creation       = time(pre, "A:new()"),
    instance_method         = time(pre, "a:foo()"),
    inherited_method        = time(pre, "b:foo()"),
    static_method           = time(pre, "A:bar()"),
    inherited_static_method = time(pre, "B:bar()")
  }
end

local current_results = time_lib('middleclass')

for k,v in pairs(current_results) do
  print(k,v)
end



