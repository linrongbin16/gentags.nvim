local logging = require("gentags.commons.logging")
local spawn = require("gentags.commons.spawn")

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
    if sysobj ~= nil then
      JOBS_MAP[sysobj.pid] = nil
    end
  end

  local cfg = configs.get()
  local opts = cfg.opts[filetype] ~= nil and cfg.opts[filetype]
    or cfg.fallback_opts

  sysobj = spawn.run({ "ctags", unpack(opts) }, {
    on_stdout = _on_stdout,
    on_stderr = _on_stderr,
  }, _on_exit)
  assert(sysobj ~= nil)
  JOBS_MAP[sysobj.pid] = sysobj
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
