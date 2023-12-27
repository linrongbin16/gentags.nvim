local paths = require("commons.paths")
local uv = require("commons.uv")
local configs = require("gentags.configs")

local M = {}

--- @return string?
local function get_workspace()
  local cwd = vim.fn.getcwd()
  while true do
    for _, pattern in ipairs(configs.get().workspace.root) do
      local target = paths.join(cwd, pattern)
      target = paths.normalize(target, { double_backslash = true })
      local result, _ = uv.fs_stat(target)
      if result then
        return cwd
      end
    end
    local parent = paths.parent(cwd)
    if paths.blank(parent) or parent == cwd then
      break
    end
  end
  return nil
end

--- @alias gentags.Context {filename:string,workspace:string,lang:string}
--- @return gentags.Context
local function context()
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = paths.normalize(
    vim.api.nvim_buf_get_name(bufnr),
    { double_backslash = true, expand = true }
  )
  return {
    filename = filename,
  }
end

M.dispatch = function()
  local cfg = configs.get()
  local ctx = context()

  if string.lower(cfg.bin) == "ctags" then
    require("gentags.ctags").run(ctx)
  end
end

return M
