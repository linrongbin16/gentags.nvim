local logging = require("gentags.commons.logging")
local spawn = require("gentags.commons.spawn")
local tables = require("gentags.commons.tables")

local configs = require("gentags.configs")
local utils = require("gentags.utils")

local M = {}

--- @alias gentags.pid integer|string
--- @table<gentags.pid, vim.SystemObj>
local JOBS_MAP = {}

M.run = function()
  local logger = logging.get("gentags") --[[@as commons.logging.Logger]]

  local workspace = utils.get_workspace()
  local filename = utils.get_filename()
  local filetype = utils.get_filetype()
  logger:debug(
    "|run| workspace:%s, filename:%s, filetype:%s",
    vim.inspect(workspace),
    vim.inspect(filename),
    vim.inspect(filetype)
  )

  local sysobj = nil

  local function _on_stdout(line)
    logger:debug("|run._on_stdout| line:%s", vim.inspect(line))
  end

  local function _on_stderr(line)
    logger:debug("|run._on_stderr| line:%s", vim.inspect(line))
  end

  local function _on_exit(completed)
    logger:debug(
      "|run._on_exit| completed:%s, sysobj:%s, JOBS_MAP:%s",
      vim.inspect(completed),
      vim.inspect(sysobj),
      vim.inspect(JOBS_MAP)
    )
    if sysobj ~= nil then
      JOBS_MAP[sysobj.pid] = nil
    end
  end

  local cfg = configs.get()
  local opts = (tables.tbl_get(cfg, "opts", filetype) ~= nil)
      and tables.tbl_get(cfg, "opts", "filetype")
    or cfg.fallback_opts
  local cmds = { "ctags", unpack(opts) }
  logger:debug("|run| cmds:%s", vim.inspect(cmds))

  sysobj = spawn.run(cmds, {
    on_stdout = _on_stdout,
    on_stderr = _on_stderr,
  }, _on_exit)
  assert(sysobj ~= nil)
  JOBS_MAP[sysobj.pid] = sysobj
end

--- @alias gentags.StatusInfo {running:boolean,jobs:integer}
M.status = function()
  local running = tables.tbl_not_empty(JOBS_MAP)
  local jobs = 0
  for pid, job in pairs(JOBS_MAP) do
    jobs = jobs + 1
  end
  return {
    running = running,
    jobs = jobs,
  }
end

M.terminate = function()
  for pid, sysobj in pairs(JOBS_MAP) do
    if sysobj ~= nil then
      sysobj:kill(9)
    end
  end
  JOBS_MAP = {}
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
