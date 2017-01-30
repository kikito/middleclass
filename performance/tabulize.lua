local pad = function(str, len)
  str = tostring(str)
  return str .. (' '):rep(len - #str)
end

local tabulize = function(rows, headers)
  local rows_count, columns_count = #rows, #headers

  local column_len = {}
  for x=1,columns_count do
    column_len[x] = #tostring(headers[x])
  end
  for y=1,rows_count do
    local row = rows[y]
    for x=1,#row do
      column_len[x] = math.max(column_len[x], #tostring(row[x]))
    end
  end

  local buffer, buffer_len = {}, 0
  local write = function(str)
    buffer_len = buffer_len + 1
    buffer[buffer_len] = tostring(str)
  end

  local separator = function()
    for x=1, columns_count do
      write('+')
      write(('-'):rep(column_len[x]))
    end
    write('+\n')
  end

  separator()

  for x=1, columns_count do
    write('|')
    write(pad(headers[x], column_len[x]))
  end
  write('|\n')

  separator()

  for y=1, rows_count do
    local row = rows[y]
    for x=1,#row do
      write('|')
      write(pad(row[x], column_len[x]))
    end
    write('|\n')
  end

  separator()

  return table.concat(buffer)
end

return tabulize
