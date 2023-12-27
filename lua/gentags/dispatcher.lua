local paths = require("gentags.commons.paths")
local strings = require("gentags.commons.strings")
local uv = require("gentags.commons.uv")
local logging = require("gentags.commons.logging")

local configs = require("gentags.configs")

local M = {}

--- @param cwd string?
--- @return string?
local function get_workspace(cwd)
  local logger = logging.get("gentags") --[[@as commons.logging.Logger]]

  cwd = cwd or vim.fn.getcwd()
  while true do
    for _, pattern in ipairs(configs.get().workspace) do
      local target = paths.join(cwd, pattern)
      logger:debug(
        "|get_workspace| 1-cwd:%s, target:%s",
        vim.inspect(cwd),
        vim.inspect(target)
      )
      target =
        paths.normalize(target, { double_backslash = true, expand = true })
      local stat_result, stat_err = uv.fs_stat(target)
      logger:debug(
        "|get_workspace| 2-cwd:%s, target:%s, stat result:%s, stat err:%s",
        vim.inspect(cwd),
        vim.inspect(target),
        vim.inspect(stat_result),
        vim.inspect(stat_err)
      )
      if stat_result then
        return cwd
      end
    end
    local parent = paths.parent(cwd)
    if strings.blank(parent) then
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

local WORKER_MAP = {
  ctags = require("gentags.ctags"),
}

M.run = function()
  local cfg = configs.get()

  local target = string.lower(cfg.bin)
  local worker = WORKER_MAP[target]
  if worker then
    worker.run(get_context())
  else
    assert(false, string.format("%s is not supported!", vim.inspect(cfg.bin)))
  end
end

M.terminate = function()
  local cfg = configs.get()

  local target = string.lower(cfg.bin)
  local worker = WORKER_MAP[target]
  if worker then
    worker.terminate()
  else
    assert(false, string.format("%s is not supported!", vim.inspect(cfg.bin)))
  end
end

return M
