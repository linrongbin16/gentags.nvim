local logging = require("gentags.commons.logging")
local strings = require("gentags.commons.strings")
local paths = require("gentags.commons.paths")
local tables = require("gentags.commons.tables")

local configs = require("gentags.configs")
local utils = require("gentags.utils")

local M = {}

-- A tool module has these APIs: load/init/update/terminate
--
--- @alias gentags.Context {workspace:string?,filename:string?,filetype:string?,tags:string?}
--- @alias gentags.LoadMethod fun(ctx:gentags.Context):nil
--- @alias gentags.InitMethod fun(ctx:gentags.Context):nil
--- @alias gentags.UpdateMethod fun(ctx:gentags.Context):nil
--- @alias gentags.TerminateMethod fun(ctx:gentags.Context):nil
--- @alias gentags.StatusInfo {running:boolean,jobs:integer}
--- @alias gentags.StatusMethod fun(ctx:gentags.Context):gentags.StatusInfo
--- @alias gentags.Tool {load:gentags.LoadMethod,init:gentags.InitMethod,update:gentags.UpdateMethod,terminate:gentags.TerminateMethod}
--- @type table<string, gentags.Tool>
local TOOLS_MAP = {
  ctags = require("gentags.ctags"),
}

--- @return gentags.Tool
local function get_toolchain()
  local cfg = configs.get()
  local tool = cfg.tool
  local toolchain = TOOLS_MAP[string.lower(tool)] --[[@as gentags.Tool]]
  assert(
    toolchain ~= nil,
    string.format("%s is not supported!", vim.inspect(tool))
  )
  return toolchain
end

local function get_context()
  local cfg = configs.get()
  local logger = logging.get("gentags") --[[@as commons.logging.Logger]]

  local workspace = utils.get_workspace()
  logger:debug("|load| workspace:%s", vim.inspect(workspace))

  local filename = utils.get_filename()
  local filetype = utils.get_filetype()

  local tags = nil
  if strings.not_empty(workspace) then
    tags = utils.get_tags_name(workspace --[[@as string]])
  elseif
    strings.not_empty(filename)
    and not tables.list_contains(cfg.exclude_filetypes or {}, filetype)
  then
    tags = utils.get_tags_name(filename)
  end

  return {
    workspace = workspace,
    filename = filename,
    filetype = filetype,
    tags = tags,
  }
end

M.load = function()
  get_toolchain().load(get_context())
end

M.init = function()
  get_toolchain().init(get_context())
end

M.update = function()
  get_toolchain().update(get_context())
end

M.terminate = function()
  get_toolchain().terminate(get_context())
end

local gc_running = false

M.gc = function()
  if gc_running then
    return
  end

  gc_running = true

  -- run gc here

  vim.schedule(function()
    gc_running = false
  end)
end

return M
