local logging = require("gentags.commons.logging")
local strings = require("gentags.commons.strings")
local paths = require("gentags.commons.paths")
local tables = require("gentags.commons.tables")

local configs = require("gentags.configs")
local utils = require("gentags.utils")

local M = {}

-- A tool module has these APIs: load/init/update/terminate
--
--- @alias gentags.Context {workspace:string?,filename:string?,filetype:string?,tags_file:string?,tags_handle:string?,mode:"workspace"|"singlefile"}
--- @alias gentags.LoadMethod fun(ctx:gentags.Context):nil
--- @alias gentags.InitMethod fun(ctx:gentags.Context):nil
--- @alias gentags.UpdateMethod fun(ctx:gentags.Context):nil
--- @alias gentags.TerminateMethod fun(ctx:gentags.Context):nil
--- @alias gentags.StatusInfo {running:boolean,jobs:integer}
--- @alias gentags.StatusMethod fun(ctx:gentags.Context):gentags.StatusInfo
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
  local cfg = configs.get()
  local logger = logging.get("gentags") --[[@as commons.logging.Logger]]

  local filename = utils.get_filename()
  local filetype = utils.get_filetype()

  local filedir = nil
  if
    strings.not_empty(filename)
    and not tables.list_contains(cfg.exclude_filetypes or {}, filetype)
  then
    filedir = paths.parent(filename)
  end
  local workspace = utils.get_workspace(filedir)

  logger:debug(
    "|get_context| filename:%s, filetype:%s, workspace:%s",
    vim.inspect(filename),
    vim.inspect(filetype),
    vim.inspect(workspace)
  )

  local tags_handle = nil
  local tags_file = nil
  if strings.not_empty(workspace) then
    tags_handle = utils.get_tags_handle(workspace --[[@as string]])
    tags_file = utils.get_tags_file(tags_handle --[[@as string]])
  elseif
    strings.not_empty(filename)
    and not tables.list_contains(cfg.exclude_filetypes or {}, filetype)
  then
    tags_handle = utils.get_tags_handle(filename)
    tags_file = utils.get_tags_file(tags_handle)
  end

  local mode = strings.not_empty(workspace) and "workspace" or "singlefile"

  return {
    workspace = workspace,
    filename = filename,
    filetype = filetype,
    tags_file = tags_file,
    tags_handle = tags_handle,
    mode = mode,
  }
end

M.load = function()
  vim.schedule(function()
    local ok, ctx_or_err = pcall(M.get_context)
    local logger = logging.get("gentags") --[[@as commons.logging.Logger]]
    logger:ensure(ok, "failed to get context:%s", vim.inspect(ctx_or_err))
    local tool = get_tool()
    local ok2, err2 = pcall(tool.load, ctx_or_err)
    logger:ensure(ok2, "failed to load:%s", vim.inspect(err2))
  end)
end

M.init = function()
  vim.schedule(function()
    local ok, ctx_or_err = pcall(M.get_context)
    local logger = logging.get("gentags") --[[@as commons.logging.Logger]]
    logger:ensure(ok, "failed to get context:%s", vim.inspect(ctx_or_err))
    local tool = get_tool()
    local ok2, err2 = pcall(tool.init, ctx_or_err)
    logger:ensure(ok2, "failed to init:%s", vim.inspect(err2))
  end)
end

M.update = function()
  vim.schedule(function()
    local ok, ctx_or_err = pcall(M.get_context)
    local logger = logging.get("gentags") --[[@as commons.logging.Logger]]
    logger:ensure(ok, "failed to get context:%s", vim.inspect(ctx_or_err))
    local tool = get_tool()
    local ok2, err2 = pcall(tool.update, ctx_or_err)
    logger:ensure(ok2, "failed to update:%s", vim.inspect(err2))
  end)
end

M.terminate = function()
  local ok, ctx_or_err = pcall(M.get_context)
  local logger = logging.get("gentags") --[[@as commons.logging.Logger]]
  logger:ensure(ok, "failed to get context:%s", vim.inspect(ctx_or_err))
  local tool = get_tool()
  local ok2, err2 = pcall(tool.update, ctx_or_err)
  logger:ensure(ok2, "failed to terminate:%s", vim.inspect(err2))
end

M.status = function()
  local ok, ctx_or_err = pcall(M.get_context)
  local logger = logging.get("gentags") --[[@as commons.logging.Logger]]
  logger:ensure(ok, "failed to get context:%s", vim.inspect(ctx_or_err))
  local tool = get_tool()
  local ok2, err2 = pcall(tool.status, ctx_or_err)
  logger:ensure(ok2, "failed to get status:%s", vim.inspect(err2))
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
