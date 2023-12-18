local logging = require("commons.logging")
local LogLevels = require("commons.logging").LogLevels
local configs = require("gentags.configs")

local M = {}

--- @param opts gentags.Options?
M.setup = function(opts)
  local cfg = configs.setup(opts)

  logging.setup({
    name = "gentags",
    level = cfg.debug.enable and LogLevels.DEBUG or LogLevels.INFO,
    console_log = cfg.debug.console_log,
    file_log = cfg.debug.file_log,
    file_log_name = "gentags.log",
  })

  -- cache dir
  logging.get("gentags"):ensure(
    vim.fn.filereadable(cfg.cache.dir) <= 0,
    "%s (cache.dir) already exist but not a directory!",
    vim.inspect(cfg.cache.dir)
  )
  vim.fn.mkdir(cfg.cache.dir, "p")
end

return M
