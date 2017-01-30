local pad = function(str, len, char)
  str = tostring(str)
  char = char or ' '
  return str .. char:rep(len - #str)
end

local tabulize = function(rows, headers)
  local rows_count, cols_count = #rows, #headers

  local cols_len = {}
  for x=1,cols_count do
    cols_len[x] = #tostring(headers[x])
  end
  for y=1,rows_count do
    local row = rows[y]
    for x=1,#row do
      cols_len[x] = math.max(cols_len[x], #tostring(row[x]))
    end
  end

  local buffer, buffer_len = {}, 0
  local write = function(str)
    buffer_len = buffer_len + 1
    buffer[buffer_len] = tostring(str)
  end
  local write_row = function(row, cell_separator, blank_char)
    for x=1, cols_count do
      write(cell_separator)
      write(pad(row[x], cols_len[x], blank_char))
    end
    write(cell_separator .. '\n')
  end

  local fake_row = {}
  for x=1, cols_count do fake_row[x] = "" end

  write_row(fake_row, '+', '-')
  write_row(headers,  '|', ' ')
  write_row(fake_row, '+', '-')

  for y=1, rows_count do
    write_row(rows[y], '|', ' ')
  end

  write_row(fake_row, '+', '-')

  return table.concat(buffer)
end

return tabulize
