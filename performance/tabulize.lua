local pad = function(str, len, char)
  str = tostring(str)
  char = char or ' '
  return str .. char:rep(len - #str)
end

local Buffer = {
  write = function(self, str)
    self.len = self.len + 1
    self.strings[self.len] = tostring(str)
  end,
  flush = function(self)
    return table.concat(self.strings)
  end
}
local newBuffer = function()
  return setmetatable({len = 0, strings = {}}, {__index=Buffer})
end

local RowRenderer = {
  render = function(self, row, cell_separator, blank_char)
    for x=1, self.cols_count do
      self.buffer:write(cell_separator)
      self.buffer:write(pad(row[x], self.cols_len[x], blank_char))
    end
    self.buffer:write(cell_separator .. '\n')
  end
}
local newRowRenderer = function(buffer, cols_len, cols_count)
  return setmetatable({
    buffer = buffer,
    cols_len = cols_len,
    cols_count = cols_count
  }, {__index=RowRenderer})
end

local calculate_stats = function(rows, headers)
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

  return cols_len, cols_count, rows_count
end

local tabulize = function(rows, headers)
  local cols_len, cols_count, rows_count = calculate_stats(rows, headers)
  local buffer = newBuffer()
  local r      = newRowRenderer(buffer, cols_len, cols_count)

  local blank_row = {}
  for x=1, cols_count do blank_row[x] = "" end

  r:render(blank_row, '+', '-')
  r:render(headers,   '|', ' ')
  r:render(blank_row, '+', '-')

  for y=1, rows_count do
    r:render(rows[y], '|', ' ')
  end

  r:render(blank_row, '+', '-')

  return buffer:flush()
end

return tabulize
