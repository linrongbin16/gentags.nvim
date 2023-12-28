local logging = require("gentags.commons.logging")
local spawn = require("gentags.commons.spawn")
local tables = require("gentags.commons.tables")
local strings = require("gentags.commons.strings")

local configs = require("gentags.configs")

local M = {}

--- @alias gentags.CtagsJobId integer|string
--- @alias gentags.CtagsJobInfo {system_obj:vim.SystemObj}
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

--- @param ctx gentags.Context
M.load = function(ctx)
  init_logging()
  local logger = logging.get("gentags.ctags") --[[@as commons.logging.Logger]]
  logger:debug("|load| ctx:%s", vim.inspect(ctx))

  if strings.empty(ctx.tags) then
    return
  end

  if vim.fn.filereadable(ctx.tags) > 0 then
    logger:debug("|load| append tags:%s", vim.inspect(ctx.tags))
    vim.opt.tags:append(ctx.tags)
  end
end

--- @param ctx gentags.Context
M.init = function(ctx)
  init_logging()
  local logger = logging.get("gentags.ctags") --[[@as commons.logging.Logger]]
  logger:debug("|run| ctx:%s", vim.inspect(ctx))

  if strings.empty(ctx.tags) then
    return
  end

  local tmpfile = vim.fn.tempname() --[[@as string]]
  if strings.empty(tmpfile) then
    return
  end

  local system_obj = nil

  local function _on_stdout(line)
    logger:debug("|run._on_stdout| line:%s", vim.inspect(line))
  end

  local function _on_stderr(line)
    logger:debug("|run._on_stderr| line:%s", vim.inspect(line))
  end

  local function _close_file(fp)
    if fp then
      fp:close()
    end
  end

  local function _on_exit(completed)
    -- swap tmp file and tags file
    local fp1 = io.open(ctx.tags, "w")
    local fp2 = io.open(tmpfile, "r")
    if fp1 == nil or fp2 == nil then
      _close_file(fp1)
      _close_file(fp2)
    end

    ---@diagnostic disable-next-line: need-check-nil
    local content = fp2:read("*a")
    if content then
      ---@diagnostic disable-next-line: need-check-nil
      fp1:write(content)
    end

    _close_file(fp1)
    _close_file(fp2)

    if system_obj ~= nil then
      JOBS_MAP[system_obj.pid] = nil
    end
  end

  local cfg = configs.get()
  local opts = vim.deepcopy(tables.tbl_get(cfg, "ctags") or {})

  local cwd = nil
  if ctx.mode == "workspace" then
    assert(strings.not_empty(ctx.workspace))
    cwd = ctx.workspace
    table.insert(opts, "-R")
  else
    assert(ctx.mode == "file")
    assert(strings.not_empty(ctx.filename))
    table.insert(opts, "-L")
    table.insert(opts, ctx.filename)
  end

  -- output tags file
  table.insert(opts, "-f")
  table.insert(opts, tmpfile)

  local cmds = { "ctags", unpack(opts) }
  logger:debug("|run| cmds:%s", vim.inspect(cmds))

  system_obj = spawn.run(cmds, {
    cwd = cwd,
    on_stdout = _on_stdout,
    on_stderr = _on_stderr,
  }, _on_exit)

  assert(system_obj ~= nil)

  JOBS_MAP[system_obj.pid] = {
    system_obj = system_obj,
  }
end

--- @param ctx gentags.Context
M.update = function(ctx) end

--- @param ctx gentags.Context
--- @return gentags.StatusInfo
M.status = function(ctx)
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
  for job_id, job_info in pairs(JOBS_MAP) do
    if job_info ~= nil and job_info.system_obj ~= nil then
      job_info.system_obj:kill(9)
    end
  end
  JOBS_MAP = {}
end

return M
