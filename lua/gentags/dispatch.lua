local paths = require("commons.paths")

local M = {}

--- @alias gentags.Context {filename:string,workspace:string,lang:string}
--- @return gentags.Context
local function collect()
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = paths.normalize(
    vim.api.nvim_buf_get_name(bufnr),
    { double_backslash = true, expand = true }
  )
  return {
    filename = filename,
  }
end

--- @param opts gentags.Options
M.dispatch = function(opts)
  local ctx = collect()

  if string.lower(opts.toolchain.binary) == "ctags" then
    require("gentags.ctags").run(ctx, opts)
  end
end

return M
