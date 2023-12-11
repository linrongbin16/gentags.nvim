local M = {}

M.INT32_MAX = 2147483647
M.INT32_MIN = -2147483648

--- @param s string
--- @param t string
--- @param start integer?  by default start=1
--- @return integer?
M.string_find = function(s, t, start)
  start = start or 1
  for i = start, #s do
    local match = true
    for j = 1, #t do
      if i + j - 1 > #s then
        match = false
        break
      end
      local a = string.byte(s, i + j - 1)
      local b = string.byte(t, j)
      if a ~= b then
        match = false
        break
      end
    end
    if match then
      return i
    end
  end
  return nil
end

return M
