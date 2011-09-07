return function(title, f)

  local start = os.clock()

  for i=0,10000 do f() end

  print( title, os.clock() - start )

end
