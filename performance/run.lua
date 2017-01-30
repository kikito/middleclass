local tabulize = require('performance.tabulize')
local iterations = 700000

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

local run_tests = function(lib_path)
  local pre = ([[
    local lib = require '%s'
    local class = _G.class or lib

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
    --class_creation = time(pre, "class('A')"),
    instantiation  = time(pre, "A:new()"),
    instance_method = time(pre, "a:foo()"),
    inherited_method = time(pre, "b:foo()"),
    static_method = time(pre, "A:bar()"),
    inherited_static_method = time(pre, "B:bar()")
  }
end

local versions = {'4_1', '4_0', '3_0', '2_0'}
local headers = {'test', unpack(versions)}
local tests = { --'class_creation',
                'instantiation', 'instance_method', 'inherited_method', 'static_method', 'inherited_static_method' }

print(("Executing tests for %s. JIT: %s ..."):format(_VERSION, tostring(not not _G.jit)))

local test_results = {}
for i,version in ipairs(versions) do
  test_results[version] = run_tests('performance.middleclass_' .. version)
end

local tabular_data = {}
for y,test in ipairs(tests) do
  tabular_data[y] = {tests[y]}
  for x,version in ipairs(versions) do
    tabular_data[y][x+1] = test_results[version][tests[y]]
  end
end

print(tabulize(tabular_data, headers))



