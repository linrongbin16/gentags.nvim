local logging = require("gentags.commons.logging")
local LogLevels = require("gentags.commons.logging").LogLevels
local configs = require("gentags.configs")

local M = {}

--- @param opts gentags.Options?
M.setup = function(opts)
  local cfg = configs.setup(opts)
  -- print(vim.inspect(cfg))

  logging.setup({
    name = "gentags",
    level = cfg.debug.enable and LogLevels.DEBUG or LogLevels.INFO,
    console_log = cfg.debug.console_log,
    file_log = cfg.debug.file_log,
    file_log_name = "gentags.log",
  })
  local logger = logging.get("gentags")

  -- cache dir
  logger:ensure(
    vim.fn.filereadable(cfg.cache_dir) <= 0,
    string.format(
      "%s (cache_dir) already exist but not a directory!",
      vim.inspect(cfg.cache_dir)
    )
  )
  vim.fn.mkdir(cfg.cache_dir, "p")

  -- init tags (first generate) when open/create file
  vim.api.nvim_create_autocmd({
    "BufReadPre",
    "BufNewFile",
    "FileReadPre",
  }, {
    callback = function(event)
      logging
        .get("gentags")
        :debug(string.format("|setup| enter buffer:%s", vim.inspect(event)))
      local dispatcher = require("gentags.dispatcher")
      if dispatcher.enabled() then
        dispatcher.load()
        dispatcher.init()
      end
    end,
  })

  -- update tags when write/modify file
  vim.api.nvim_create_autocmd({
    "BufWritePost",
    "FileWritePost",
    "FileAppendPost",
  }, {
    callback = function(event)
      logging
        .get("gentags")
        :debug(string.format("|setup| write buffer:%s", vim.inspect(event)))
      local dispatcher = require("gentags.dispatcher")
      if dispatcher.enabled() then
        dispatcher.update()
      end
    end,
  })

  -- terminate before leaving vim
  vim.api.nvim_create_autocmd({ "VimLeavePre" }, {
    callback = function(event)
      logging
        .get("gentags")
        :debug(string.format("|setup| leave vim:%s", vim.inspect(event)))
      require("gentags.dispatcher").terminate()
    end,
  })
end

return M
