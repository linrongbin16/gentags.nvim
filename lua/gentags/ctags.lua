local logging = require("gentags.commons.logging")
local spawn = require("gentags.commons.spawn")
local tables = require("gentags.commons.tables")
local strings = require("gentags.commons.strings")
local uv = require("gentags.commons.uv")

local configs = require("gentags.configs")

local M = {}

--- @table<integer|string, vim.SystemObj>
local JOBS_MAP = {}

--- @table<string, boolean>
local TAGS_LOCKING_MAP = {}

--- @table<string, boolean>
local TAGS_LOADED_MAP = {}

--- @table<string, boolean>
local TAGS_INITED_MAP = {}

--- @param ctx gentags.Context
M.load = function(ctx)
  local logger = logging.get("gentags") --[[@as commons.logging.Logger]]
  logger:debug("|load| ctx:%s", vim.inspect(ctx))

  if strings.empty(ctx.tags_file) then
    return
  end
  if TAGS_LOADED_MAP[ctx.tags_file] then
    return
  end
  if vim.fn.filereadable(ctx.tags_file) <= 0 then
    return
  end
  logger:debug("|load| load tags:%s", vim.inspect(ctx.tags_file))
  vim.opt.tags:append(ctx.tags_file)
  TAGS_LOADED_MAP[ctx.tags_file] = true
end

--- @param fp any
M._close_file = function(fp)
  if fp then
    fp:close()
  end
end

-- write src into dst
--- @param src string
--- @param dst string
M._dump_file = function(src, dst)
  assert(strings.not_empty(src))
  assert(strings.not_empty(dst))

  local logger = logging.get("gentags") --[[@as commons.logging.Logger]]

  local dst_fp = io.open(dst, "w")
  local src_fp = io.open(src, "r")
  if dst_fp == nil or src_fp == nil then
    if dst_fp == nil then
      logger:err("|_dump_file| failed to open dst file:%s", vim.inspect(dst))
    end
    if src_fp == nil then
      logger:err("|_dump_file| failed to open src file:%s", vim.inspect(src))
    end
    M._close_file(dst_fp)
    M._close_file(src_fp)
  end

  ---@diagnostic disable-next-line: need-check-nil
  local content = src_fp:read("*a")
  if content then
    ---@diagnostic disable-next-line: need-check-nil
    dst_fp:write(content)
  end

  M._close_file(dst_fp)
  M._close_file(src_fp)
  logger:debug(
    "|_dump_file| dump src %s to dst %s",
    vim.inspect(src),
    vim.inspect(dst)
  )
end

--- @param ctx gentags.Context
--- @param on_exit (fun():nil)|nil
--- @return table?
M._write = function(ctx, on_exit)
  local logger = logging.get("gentags") --[[@as commons.logging.Logger]]
  logger:debug("|_write| ctx:%s", vim.inspect(ctx))

  -- no tags name
  if strings.empty(ctx.tags_file) then
    return nil
  end
  -- tags name already exist, e.g. already running ctags for this tags
  if TAGS_LOCKING_MAP[ctx.tags_file] then
    return nil
  end

  local tmpfile = vim.fn.tempname() --[[@as string]]
  if strings.empty(tmpfile) then
    return nil
  end

  local system_obj = nil

  local function _on_stdout(line)
    logger:debug("|_write._on_stdout| line:%s", vim.inspect(line))
  end

  local function _on_stderr(line)
    logger:debug("|_write._on_stderr| line:%s", vim.inspect(line))
  end

  local function _on_exit(completed)
    -- logger:debug(
    --   "|_write._on_exit| completed:%s, sysobj:%s, JOBS_MAP:%s",
    --   vim.inspect(completed),
    --   vim.inspect(sysobj),
    --   vim.inspect(JOBS_MAP)
    -- )

    local rename_result, rename_err = uv.fs_rename(tmpfile, ctx.tags_file)
    if rename_result == nil then
      logger:warn(
        "failed to save tags on %s, error: %s",
        vim.inspect(ctx.tags_file),
        vim.inspect(rename_err)
      )
    else
      logger:debug(
        "|_write._on_exit| tags generate completed to:%s",
        vim.inspect(ctx.tags_file)
      )
    end

    if system_obj == nil then
      logger:err(
        "|_write._on_exit| system_obj %s must not be nil!",
        vim.inspect(system_obj)
      )
    end
    if system_obj ~= nil then
      -- if JOBS_MAP[system_obj.pid] == nil then
      --   logger:debug(
      --     "|_write._on_exit| debug-error! job id %s must exist!",
      --     vim.inspect(system_obj)
      --   )
      -- end
      JOBS_MAP[system_obj.pid] = nil
    end
    -- if TAGS_LOCKING_MAP[ctx.tags_file] == nil then
    --   logger:debug(
    --     "|_write._on_exit| debug-error! tags %s must be locked!",
    --     vim.inspect(ctx)
    --   )
    -- end
    TAGS_LOCKING_MAP[ctx.tags_file] = nil

    if type(on_exit) == "function" then
      on_exit()
    end
  end

  local cfg = configs.get()
  local opts = vim.deepcopy(tables.tbl_get(cfg, "ctags") or {})

  local cwd = nil
  if ctx.mode == "workspace" then
    assert(strings.not_empty(ctx.workspace))
    cwd = ctx.workspace
    table.insert(opts, "-R")
  end

  -- output tags file
  table.insert(opts, "-f")
  table.insert(opts, tmpfile)

  if ctx.mode == "singlefile" then
    -- only generate tags for target source file
    assert(strings.not_empty(ctx.filename))
    table.insert(opts, ctx.filename)
  end

  local cmds = { "ctags", unpack(opts) }
  logger:debug("|_write| ctx:%s, cmds:%s", vim.inspect(ctx), vim.inspect(cmds))

  system_obj = spawn.run(cmds, {
    cwd = cwd,
    on_stdout = _on_stdout,
    on_stderr = _on_stderr,
  }, _on_exit)

  assert(system_obj ~= nil)

  JOBS_MAP[system_obj.pid] = system_obj
  TAGS_LOCKING_MAP[ctx.tags_file] = true

  return { cmds = cmds, system_obj = system_obj }
end

--- @param ctx gentags.Context
--- @param on_exit (fun():nil)|nil
--- @return table?
M._append = function(ctx, on_exit)
  local logger = logging.get("gentags") --[[@as commons.logging.Logger]]
  logger:debug("|_append| ctx:%s", vim.inspect(ctx))

  if strings.empty(ctx.filename) then
    return nil
  end
  if strings.empty(ctx.tags_file) then
    return nil
  end
  if TAGS_LOCKING_MAP[ctx.tags_file] then
    return nil
  end

  local system_obj = nil

  local function _on_stdout(line)
    logger:debug("|update._on_stdout| line:%s", vim.inspect(line))
  end

  local function _on_stderr(line)
    logger:debug("|update._on_stderr| line:%s", vim.inspect(line))
  end

  local function _on_exit(completed)
    -- logger:debug(
    --   "|update._on_exit| completed:%s, sysobj:%s, JOBS_MAP:%s",
    --   vim.inspect(completed),
    --   vim.inspect(sysobj),
    --   vim.inspect(JOBS_MAP)
    -- )

    if system_obj == nil then
      logger:err(
        "|update._on_exit| system_obj %s must not be nil!",
        vim.inspect(system_obj)
      )
    end
    if system_obj ~= nil then
      JOBS_MAP[system_obj.pid] = nil
    end
    TAGS_LOCKING_MAP[ctx.tags_file] = nil

    if type(on_exit) == "function" then
      on_exit()
    end
  end

  local cfg = configs.get()
  local opts = vim.deepcopy(tables.tbl_get(cfg, "ctags") or {})

  -- append mode
  table.insert(opts, "--append=yes")

  -- output tags file
  table.insert(opts, "-f")
  table.insert(opts, ctx.tags_file)

  -- only generate tags for target source file
  table.insert(opts, ctx.filename)

  local cmds = { "ctags", unpack(opts) }
  logger:debug("|update| cmds:%s", vim.inspect(cmds))

  system_obj = spawn.run(cmds, {
    on_stdout = _on_stdout,
    on_stderr = _on_stderr,
  }, _on_exit)

  assert(system_obj ~= nil)

  JOBS_MAP[system_obj.pid] = system_obj
  TAGS_LOCKING_MAP[ctx.tags_file] = true

  return { cmds = cmds, system_obj = system_obj }
end

M.init = function(ctx)
  if strings.empty(ctx.tags_file) then
    return
  end
  if TAGS_INITED_MAP[ctx.tags_file] then
    return
  end
  M._write(ctx, function()
    TAGS_INITED_MAP[ctx.tags_file] = true
    M.load(ctx)
  end)
end

--- @param ctx gentags.Context
M.update = function(ctx)
  if
    ctx.mode == "singlefile"
    or (
      strings.not_empty(ctx.tags_file)
      and vim.fn.filereadable(ctx.tags_file) <= 0
    )
  then
    -- if working in singlefile mode, or in workspace mode but the output tags file not exist
    -- go back to generate tags for whole workspace

    local logger = logging.get("gentags") --[[@as commons.logging.Logger]]
    logger:debug("|update| go back to init, ctx:%s", vim.inspect(ctx))
    vim.schedule(function()
      M.init(ctx)
    end)
  else
    assert(ctx.mode == "workspace")

    if strings.empty(ctx.workspace) then
      return
    end

    assert(vim.fn.filereadable(ctx.tags_file) > 0)

    -- if working in workspace and the output tags already exist, it will do two steps:
    --   1. generate tags only for current saved files, and append it to the tags file
    --   2. then re-generate the whole workspace tags again and replace the existing tags, this is for more accurate data

    local logger = logging.get("gentags") --[[@as commons.logging.Logger]]
    logger:debug(
      "|update| go to append for current file first, ctx:%s",
      vim.inspect(ctx)
    )

    M._append(ctx, function()
      -- trigger re-generate tags in write mode for whole workspace again
      vim.defer_fn(function()
        logging.get("gentags"):debug(
          "|update._append.on_exit| trigger re-init the whole tags file again, ctx:%s",
          vim.inspect(ctx)
        )
        M._write(ctx, function()
          TAGS_INITED_MAP[ctx.tags_file] = true
          M.load(ctx)
        end)
      end, 1000)
    end)
  end
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
