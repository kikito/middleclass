return function(title, f)
  collectgarbage()

  local startTime = os.clock()

  for i=0,10000 do f() end

  local endTime = os.clock()
  
  print(string.format("| %s | %13.9f |", title, (endTime - startTime) * 1e3))
end
