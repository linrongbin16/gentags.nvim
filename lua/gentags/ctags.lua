local logging = require("gentags.commons.logging")
local spawn = require("gentags.commons.spawn")
local tables = require("gentags.commons.tables")
local strings = require("gentags.commons.strings")

local configs = require("gentags.configs")

local M = {}

--- @table<integer|string, vim.SystemObj>
local JOBS_MAP = {}

--- @table<string, boolean>
local TAGS_LOCKING_MAP = {}

--- @table<string, boolean>
local TAGS_LOADED_MAP = {}

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

  if
    strings.not_empty(ctx.tags_file)
    and not TAGS_LOADED_MAP[ctx.tags_file]
    and vim.fn.filereadable(ctx.tags_file) > 0
  then
    logger:debug("|load| append tags_file:%s", vim.inspect(ctx.tags_file))
    vim.opt.tags:append(ctx.tags_file)
    TAGS_LOADED_MAP[ctx.tags_file] = true
  end

  if
    strings.not_empty(ctx.tags_pattern)
    and not TAGS_LOADED_MAP[ctx.tags_pattern]
  then
    logger:debug("|load| append tags_pattern:%s", vim.inspect(ctx.tags_pattern))
    vim.opt.tags:append(ctx.tags_pattern)
    TAGS_LOADED_MAP[ctx.tags_pattern] = true
  end
end

--- @param ctx gentags.Context
M.init = function(ctx)
  init_logging()
  local logger = logging.get("gentags.ctags") --[[@as commons.logging.Logger]]
  logger:debug("|run| ctx:%s", vim.inspect(ctx))

  -- no tags name
  if strings.empty(ctx.tags_file) then
    return
  end
  -- tags name already exist, e.g. already running ctags for this tags
  if TAGS_LOCKING_MAP[ctx.tags_file] then
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
    -- logger:debug(
    --   "|run._on_exit| completed:%s, sysobj:%s, JOBS_MAP:%s",
    --   vim.inspect(completed),
    --   vim.inspect(sysobj),
    --   vim.inspect(JOBS_MAP)
    -- )

    -- swap tmp file and tags file
    local fp1 = io.open(ctx.tags_file, "w")
    local fp2 = io.open(tmpfile, "r")
    if fp1 == nil or fp2 == nil then
      if fp1 == nil then
        logger:err(
          "|init._on_exit| failed to open tags file:%s",
          vim.inspect(ctx.tags_file)
        )
      end
      if fp2 == nil then
        logger:err(
          "|init._on_exit| failed to open tmp file:%s",
          vim.inspect(tmpfile)
        )
      end
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

    if system_obj == nil then
      logger:err(
        "|init._on_exit| system_obj %s must not be nil!",
        vim.inspect(system_obj)
      )
    end
    if system_obj ~= nil then
      if JOBS_MAP[system_obj.pid] == nil then
        logger:err(
          "|init._on_exit| job id %s must exist!",
          vim.inspect(system_obj)
        )
      end
      JOBS_MAP[system_obj.pid] = nil
    end
    if TAGS_LOCKING_MAP[ctx.tags_file] ~= nil then
      logger:err("|init._on_exit| tags %s must be locked!", vim.inspect(ctx))
    end
    TAGS_LOCKING_MAP[ctx.tags_file] = nil
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

  JOBS_MAP[system_obj.pid] = system_obj
  TAGS_LOCKING_MAP[ctx.tags_file] = true
end

--- @param ctx gentags.Context
M.update = function(ctx)
  M.init(ctx)
end

--- @param ctx gentags.Context
--- @return gentags.StatusInfo
M.status = function(ctx)
  local running = tables.tbl_not_empty(JOBS_MAP)
  local jobs = 0
  for pid, system_obj in pairs(JOBS_MAP) do
    jobs = jobs + 1
  end
  return {
    running = running,
    jobs = jobs,
  }
end

M.terminate = function()
  for pid, system_obj in pairs(JOBS_MAP) do
    if system_obj ~= nil then
      system_obj:kill(9)
    end
  end
  JOBS_MAP = {}
  TAGS_LOCKING_MAP = {}
end

return M
