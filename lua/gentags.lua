local logging = require("gentags.commons.logging")
local LogLevels = require("gentags.commons.logging").LogLevels
local configs = require("gentags.configs")

local M = {}

--- @param opts gentags.Options?
M.setup = function(opts)
  local cfg = configs.setup(opts)
  -- print(vim.inspect(cfg))

  local function init_logging()
    if logging.get("gentags") == nil then
      logging.setup({
        name = "gentags",
        level = cfg.debug.enable and LogLevels.DEBUG or LogLevels.INFO,
        console_log = cfg.debug.console_log,
        file_log = cfg.debug.file_log,
        file_log_name = "gentags.log",
      })
    end
  end

  init_logging()
  local logger = logging.get("gentags") --[[@as commons.logging.Logger]]

  -- cache dir
  logger:ensure(
    vim.fn.filereadable(cfg.cache_dir) <= 0,
    "%s (cache_dir) already exist but not a directory!",
    vim.inspect(cfg.cache_dir)
  )
  vim.fn.mkdir(cfg.cache_dir, "p")

  vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
    callback = function(event)
      -- logging
      --   .get("gentags")
      --   :debug("|setup| enter buffer:%s", vim.inspect(event))
      vim.schedule(function()
        require("gentags.dispatcher").run()
      end)
    end,
  })
  vim.api.nvim_create_autocmd({ "VimLeavePre" }, {
    callback = function(event)
      -- logging.get("gentags"):debug("|setup| leave vim:%s", vim.inspect(event))
      require("gentags.dispatcher").terminate()
    end,
  })
end

return M
