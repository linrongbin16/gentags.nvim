local tbl = require("gentags.commons.tbl")
local str = require("gentags.commons.str")
local path = require("gentags.commons.path")
local logging = require("gentags.commons.logging")

local configs = require("gentags.configs")
local utils = require("gentags.utils")

local M = {}

-- A tool module has these APIs: load/init/update/terminate/status
--
--- @alias gentags.Context {workspace:string?,filename:string?,filetype:string?,tags_file:string?,tags_handle:string?,mode:"workspace"|"singlefile"}
--
--- @alias gentags.LoadMethod fun(ctx:gentags.Context):nil
--- @alias gentags.InitMethod fun(ctx:gentags.Context):nil
--- @alias gentags.UpdateMethod fun(ctx:gentags.Context):nil
--- @alias gentags.TerminateMethod fun(ctx:gentags.Context):nil
--- @alias gentags.StatusInfo {running:boolean,jobs:integer}
--- @alias gentags.StatusMethod fun(ctx:gentags.Context):gentags.StatusInfo
--
--- @alias gentags.Tool {load:gentags.LoadMethod,init:gentags.InitMethod,update:gentags.UpdateMethod,terminate:gentags.TerminateMethod,status:gentags.StatusMethod}
--- @type table<string, gentags.Tool>
local TOOLS_MAP = {
  ctags = require("gentags.ctags"),
}

--- @return gentags.Tool
local function get_tool()
  local cfg = configs.get()
  local tool = cfg.tool
  local toolchain = TOOLS_MAP[string.lower(tool)] --[[@as gentags.Tool]]
  logging.get("gentags"):ensure(
    toolchain ~= nil,
    string.format("%s is not supported!", vim.inspect(tool))
  )
  return toolchain
end

--- @return gentags.Context
M.get_context = function()
  local logger = logging.get("gentags")

  local filename = utils.get_filename()
  local filetype = utils.get_filetype()

  local filedir = nil
  if str.not_empty(filename) then
    filedir = path.parent(filename)
  end
  local workspace = utils.get_workspace(filedir)

  logger:debug(
    string.format(
      "|get_context| filename:%s, filetype:%s, workspace:%s",
      vim.inspect(filename),
      vim.inspect(filetype),
      vim.inspect(workspace)
    )
  )

  local tags_handle = nil
  local tags_file = nil
  if str.not_empty(workspace) then
    tags_handle = utils.get_tags_handle(workspace --[[@as string]])
    tags_file = utils.get_tags_file(tags_handle --[[@as string]])
  elseif str.not_empty(filename) then
    tags_handle = utils.get_tags_handle(filename)
    tags_file = utils.get_tags_file(tags_handle)
  end

  local mode = str.not_empty(workspace) and "workspace" or "singlefile"

  return {
    workspace = workspace,
    filename = filename,
    filetype = filetype,
    tags_file = tags_file,
    tags_handle = tags_handle,
    mode = mode,
  }
end

--- @return boolean
M.enabled = function()
  local logger = logging.get("gentags")
  local cfg = configs.get()

  local filename = utils.get_filename()
  local filetype = utils.get_filetype()

  if tbl.list_contains(cfg.disabled_filetypes, filetype) then
    return false
  end

  local normalized_filename =
    path.normalize(filename, { expand = true, double_backslash = true })
  if
    not tbl.List
      :copy(cfg.disabled_filenames)
      :filter(function(f)
        return path.normalize(f, { expand = true, double_backslash = true })
          == normalized_filename
      end)
      :empty()
  then
    return false
  end

  local filedir = nil
  if str.not_empty(filename) then
    filedir = path.parent(filename)
  end

  local workspace = utils.get_workspace(filedir)

  local normalized_workspace = str.not_empty(workspace)
      and path.normalize(
        workspace --[[@as string]],
        { expand = true, double_backslash = true }
      )
    or nil
  if
    not tbl.List
      :copy(cfg.disabled_workspaces)
      :filter(function(w)
        return path.normalize(w, { expand = true, double_backslash = true })
          == normalized_workspace
      end)
      :empty()
  then
    return false
  end

  return true
end

M.load = function()
  vim.schedule(function()
    local logger = logging.get("gentags")
    local ok, ctx = pcall(M.get_context)
    logger:ensure(
      ok,
      string.format("failed to get context:%s", vim.inspect(ctx))
    )
    local tool = get_tool()
    local ok2, err2 = pcall(tool.load, ctx)
    logger:ensure(ok2, string.format("failed to load:%s", vim.inspect(err2)))
  end)
end

M.init = function()
  vim.schedule(function()
    local logger = logging.get("gentags")
    local ok, ctx = pcall(M.get_context)
    logger:ensure(
      ok,
      string.format("failed to get context:%s", vim.inspect(ctx))
    )
    local tool = get_tool()
    local ok2, err2 = pcall(tool.init, ctx)
    logger:ensure(ok2, string.format("failed to init:%s", vim.inspect(err2)))
  end)
end

M.update = function()
  vim.schedule(function()
    local logger = logging.get("gentags")
    local ok, ctx = pcall(M.get_context)
    logger:ensure(
      ok,
      string.format("failed to get context:%s", vim.inspect(ctx))
    )
    local tool = get_tool()
    local ok2, err2 = pcall(tool.update, ctx)
    logger:ensure(ok2, string.format("failed to update:%s", vim.inspect(err2)))
  end)
end

M.terminate = function()
  local logger = logging.get("gentags")
  local ok, ctx = pcall(M.get_context)
  logger:ensure(ok, string.format("failed to get context:%s", vim.inspect(ctx)))
  local tool = get_tool()
  local ok2, err2 = pcall(tool.terminate, ctx)
  logger:ensure(ok2, string.format("failed to terminate:%s", vim.inspect(err2)))
end

M.status = function()
  local logger = logging.get("gentags")
  local ok, ctx = pcall(M.get_context)
  logger:ensure(ok, string.format("failed to get context:%s", vim.inspect(ctx)))
  local tool = get_tool()
  local ok2, err2 = pcall(tool.status, ctx)
  logger:ensure(
    ok2,
    string.format("failed to get status:%s", vim.inspect(err2))
  )
end

local gc_running = false

M.gc = function()
  vim.schedule(function()
    if gc_running then
      return
    end

    gc_running = true

    -- run gc here

    vim.schedule(function()
      gc_running = false
    end)
  end)
end

return M
