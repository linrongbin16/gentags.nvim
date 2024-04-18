local str = require("gentags.commons.str")
local path = require("gentags.commons.path")
local uv = require("gentags.commons.uv")
-- local logging = require("gentags.commons.logging")

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
      local target = path.join(cwd, pattern)
      -- logger:debug(
      --   "|get_workspace| 1-cwd:%s, target:%s",
      --   vim.inspect(cwd),
      --   vim.inspect(target)
      -- )
      target =
        path.normalize(target, { double_backslash = true, expand = true })
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
    local parent = path.parent(cwd)
    -- logger:debug(
    --   "|get_workspace| 3-cwd:%s, parent:%s",
    --   vim.inspect(cwd),
    --   vim.inspect(parent)
    -- )
    if str.blank(parent) then
      break
    end
    cwd = parent
  end
  return nil
end

--- @return string
M.get_filename = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = path.normalize(
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
M.get_tags_handle = function(filepath)
  if str.empty(filepath) then
    return nil
  end
  while
    str.not_empty(filepath)
    and (
      str.endswith(filepath --[[@as string]], "/")
      or str.endswith(filepath --[[@as string]], "\\")
    )
  do
    filepath = string.sub(filepath --[[@as string]], 1, #filepath - 1)
  end
  while
    str.not_empty(filepath)
    and (
      str.startswith(filepath --[[@as string]], "/")
      or str.startswith(filepath --[[@as string]], "\\")
    )
  do
    filepath = string.sub(filepath --[[@as string]], 2)
  end

  filepath = path.normalize(
    filepath --[[@as string]],
    { double_backslash = true, expand = true }
  )
  filepath = filepath:gsub("/", "%-"):gsub(" ", "%-"):gsub(":", "%-")
  while str.startswith(filepath, "-") do
    filepath = string.sub(filepath, 2)
  end
  while str.endswith(filepath, "-") do
    filepath = string.sub(filepath, 1, #filepath - 1)
  end

  local cache_dir = configs.get().cache_dir
  return path.join(cache_dir, filepath)
end

--- @param tags_handle string?
--- @return string?
M.get_tags_file = function(tags_handle)
  if str.empty(tags_handle) then
    return nil
  end
  return tags_handle .. "-tags"
end

return M
