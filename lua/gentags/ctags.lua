local logging = require("gentags.commons.logging")
local spawn = require("gentags.commons.spawn")
local tables = require("gentags.commons.tables")
local strings = require("gentags.commons.strings")

local configs = require("gentags.configs")
local utils = require("gentags.utils")

local M = {}

--- @alias gentags.CtagsJobId integer|string
--- @table<gentags.CtagsJobId, vim.SystemObj>
local JOBS_MAP = {}

local function init_logging()
  if logging.get("gentags.ctags") == nil then
    local LogLevels = require("gentags.commons.logging").LogLevels
    local cfg = configs.get()
    logging.setup({
      name = "gentags.ctags",
      level = cfg.debug.enable and LogLevels.DEBUG or LogLevels.INFO,
      console_log = cfg.debug.console_log,
      file_log = cfg.debug.file_log,
      file_log_name = "gentags.log",
    })
  end
end

M.load = function()
  init_logging()
  local logger = logging.get("gentags.ctags") --[[@as commons.logging.Logger]]

  local workspace = utils.get_workspace()
  logger:debug("|load| workspace:%s", vim.inspect(workspace))
  if strings.empty(workspace) then
    return
  end

  local output_tags_file = utils.get_tags_name(workspace --[[@as string]])
  if vim.fn.filereadable(output_tags_file) > 0 then
    logger:debug("|load| append tags:%s", vim.inspect(output_tags_file))
    vim.opt.tags:append(output_tags_file)
  end
end

--- @param ctx gentags.Context
M.init = function(ctx)
  vim.schedule_wrap(function()
    init_logging()
    local logger = logging.get("gentags.ctags") --[[@as commons.logging.Logger]]
    logger:debug("|run| ctx:%s", vim.inspect(ctx))

    if strings.empty(ctx.workspace) then
      return
    end

    local sysobj = nil

    local function _on_stdout(line)
      logger:debug("|run._on_stdout| line:%s", vim.inspect(line))
    end

    local function _on_stderr(line)
      logger:debug("|run._on_stderr| line:%s", vim.inspect(line))
    end

    local function _on_exit(completed)
      -- logger:debug(
      --   "|run._on_exit| completed:%s, sysobj:%s, JOBS_MAP:%s",
      --   vim.inspect(completed),
      --   vim.inspect(sysobj),
      --   vim.inspect(JOBS_MAP)
      -- )
      if sysobj ~= nil then
        JOBS_MAP[sysobj.pid] = nil
      end
    end

    local cfg = configs.get()
    local opts = vim.deepcopy(tables.tbl_get(cfg, "ctags") or { "-R" })

    -- output tags file
    local output_tags_file = ctx.tags or utils.get_tags_name(ctx.filename)
    table.insert(opts, "-f")
    table.insert(opts, output_tags_file)

    local cmds = { "ctags", unpack(opts) }
    logger:debug("|run| cmds:%s", vim.inspect(cmds))

    sysobj = spawn.run(cmds, {
      on_stdout = _on_stdout,
      on_stderr = _on_stderr,
    }, _on_exit)
    assert(sysobj ~= nil)
    JOBS_MAP[sysobj.pid] = sysobj
  end)
end

M.update = function() end

--- @return gentags.StatusInfo
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

return M
