local logging = require("gentags.commons.logging")
local strings = require("gentags.commons.strings")
local paths = require("gentags.commons.paths")
local tables = require("gentags.commons.tables")

local configs = require("gentags.configs")
local utils = require("gentags.utils")

local M = {}

-- A tool module has these APIs: load/init/update/terminate
--
--- @alias gentags.Context {workspace:string?,filename:string?,filetype:string?,tags_file:string?,tags_handle:string?,tags_pattern:string?,mode:"workspace"|"singlefile"}
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
  assert(
    toolchain ~= nil,
    string.format("%s is not supported!", vim.inspect(tool))
  )
  return toolchain
end

--- @return gentags.Context
local function get_context()
  local cfg = configs.get()
  local logger = logging.get("gentags") --[[@as commons.logging.Logger]]

  local workspace = utils.get_workspace()
  logger:debug("|get_context| workspace:%s", vim.inspect(workspace))

  local filename = utils.get_filename()
  local filetype = utils.get_filetype()

  local tags_handle = nil
  local tags_file = nil
  local tags_pattern = nil
  if strings.not_empty(workspace) then
    tags_handle = utils.get_tags_handle(workspace --[[@as string]])
    tags_file = utils.get_tags_file(tags_handle --[[@as string]])
    tags_pattern = utils.get_tags_pattern(tags_handle --[[@as string]])
  elseif
    strings.not_empty(filename)
    and not tables.list_contains(cfg.exclude_filetypes or {}, filetype)
  then
    tags_handle = utils.get_tags_handle(filename)
    tags_file = utils.get_tags_file(tags_handle)
    tags_pattern = utils.get_tags_pattern(tags_handle --[[@as string]])
  end

  local mode = strings.not_empty(workspace) and "workspace" or "singlefile"

  return {
    workspace = workspace,
    filename = filename,
    filetype = filetype,
    -- tags file is the output tags file name, for example:
    -- 'Users-linrongbin-github-linrongbin16-gentags.nvim-tags'
    -- the file name is created by workspace/singlefile path (replace '/', ':', ' ' to '-')
    -- with suffix '-tags'
    tags_file = tags_file,
    -- tags file is the output tags file name, without the suffix '-tags', for example:
    -- 'Users-linrongbin-github-linrongbin16-gentags.nvim'
    -- this is like a unique ID of a tags, so call it 'handle'
    tags_handle = tags_handle,
    -- the pattern to let nvim find all other tags file under the workspace, for example
    -- 'Users-linrongbin-github-linrongbin16-gentags.nvim*tags'
    -- so all other tags files can be find
    -- this could be useless, maybe I will remove it later.
    tags_pattern = tags_pattern,
    mode = mode,
  }
end

M.load = function()
  vim.schedule(function()
    get_tool().load(get_context())
  end)
end

M.init = function()
  vim.schedule(function()
    get_tool().init(get_context())
  end)
end

M.update = function()
  vim.schedule(function()
    get_tool().update(get_context())
  end)
end

M.terminate = function()
  get_tool().terminate(get_context())
end

M.status = function()
  get_tool().status(get_context())
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
