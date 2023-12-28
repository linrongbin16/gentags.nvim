local logging = require("gentags.commons.logging")
local paths = require("gentags.commons.paths")
local strings = require("gentags.commons.strings")
local uv = require("gentags.commons.uv")

local configs = require("gentags.configs")

local M = {}

--- @param cwd string?
--- @return string?
M.get_workspace = function(cwd)
  -- local logger = logging.get("gentags") --[[@as commons.logging.Logger]]

  cwd = cwd or vim.fn.getcwd()
  while true do
    -- logger:debug("|get_workspace| 0-cwd:%s", vim.inspect(cwd))
    for _, pattern in ipairs(configs.get().workspace) do
      local target = paths.join(cwd, pattern)
      -- logger:debug(
      --   "|get_workspace| 1-cwd:%s, target:%s",
      --   vim.inspect(cwd),
      --   vim.inspect(target)
      -- )
      target =
        paths.normalize(target, { double_backslash = true, expand = true })
      local stat_result, stat_err = uv.fs_stat(target)
      -- logger:debug(
      --   "|get_workspace| 2-cwd:%s, target:%s, stat result:%s, stat err:%s",
      --   vim.inspect(cwd),
      --   vim.inspect(target),
      --   vim.inspect(stat_result),
      --   vim.inspect(stat_err)
      -- )
      if stat_result then
        return cwd
      end
    end
    local parent = paths.parent(cwd)
    -- logger:debug(
    --   "|get_workspace| 3-cwd:%s, parent:%s",
    --   vim.inspect(cwd),
    --   vim.inspect(parent)
    -- )
    if strings.blank(parent) then
      break
    end
    cwd = parent
  end
  return nil
end

--- @return string
M.get_filename = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = paths.normalize(
    vim.api.nvim_buf_get_name(bufnr),
    { double_backslash = true, expand = true }
  )
  return filename
end

--- @return string
M.get_filetype = function()
  return vim.bo.filetype
end

--- @param filepath string?
--- @return string?
M.get_tags_name = function(filepath)
  if strings.empty(filepath) then
    return nil
  end
  while
    strings.not_empty(filepath) and strings.endswith(filepath, "/")
    or strings.endswith(filepath, "\\")
  do
    filepath = string.sub(filepath, 1, #filepath - 1)
  end
  while
    strings.not_empty(filepath) and strings.startswith(filepath, "/")
    or strings.startswith(filepath, "\\")
  do
    filepath = string.sub(filepath, 2)
  end

  filepath =
    paths.normalize(filepath, { double_backslash = true, expand = true })
  filepath = filepath:gsub("/", "%-"):gsub(" ", "%-"):gsub(":", "%-")
  while strings.startswith(filepath, "-") do
    filepath = string.sub(filepath, 2)
  end
  while strings.endswith(filepath, "-") do
    filepath = string.sub(filepath, 1, #filepath - 1)
  end
  filepath = filepath .. "-tags"

  local cache_dir = configs.get().cache_dir
  return paths.join(cache_dir, filepath)
end

--- @param filepath string
--- @return boolean
M.tags_exists = function(filepath)
  local tags_filename = M.get_tags_name(filepath)
  return vim.fn.filereadable(tags_filename) > 0
end

return M
