local paths = require("gentags.commons.paths")
local uv = require("gentags.commons.uv")
local configs = require("gentags.configs")

local M = {}

--- @return string?
local function get_workspace()
  local cwd = vim.fn.getcwd()
  while true do
    for _, pattern in ipairs(configs.get().workspace) do
      local target = paths.join(cwd, pattern)
      target =
        paths.normalize(target, { double_backslash = true, expand = true })
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

--- @return string
local function get_filename()
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = paths.normalize(
    vim.api.nvim_buf_get_name(bufnr),
    { double_backslash = true, expand = true }
  )
  return filename
end

--- @alias gentags.Context {filename:string,workspace:string,lang:string}
--- @return gentags.Context
local function get_context()
  return {
    filename = get_filename(),
    workspace = get_workspace(),
    lang = vim.bo.filetype,
  }
end

M.dispatch = function()
  local cfg = configs.get()
  local ctx = get_context()

  if string.lower(cfg.bin) == "ctags" then
    require("gentags.ctags").run(ctx)
  end
end

return M
