local logging = require("commons.logging")
local LogLevels = require("commons.logging").LogLevels

local M = {}

--- @alias gentags.Options table<any, any>
--- @type gentags.Options
local Defaults = {
  -- generate tools
  toolchain = {
    binary = "ctags",
    options = {
      c = "ctags",
      cpp = "ctags",
      lua = "ctags",
      markdown = "",
    },
    fallback_options = "-R",
  },

  -- user command
  command = { name = "GenTags", desc = "Generate tags" },

  -- cache
  cache = {
    -- cache directory
    -- For *NIX: `~/.cache/nvim/gentags.nvim/`.
    dir = vim.fn.stdpath("cache") .. "/gentags.nvim",

    -- garbage collection policy:
    -- * LRU (least recently used): remove the least recently used.
    --
    --- @type "LRU"
    gc_policy = "LRU",

    -- garbage collection trigger by:
    --  * count: by tags cache count, for example: 100.
    --  * size: by tags cache size, for example: 1GB, 300MB, 4096KB, with suffix "GB", "MG", "KB".
    --
    --- @type {name:"count"|"size",value:string|integer}|nil
    gc_trigger = nil,

    -- tags cache that will be exclude from garbage collection.
    gc_exclude = {},
  },

  -- debug options
  debug = {
    -- enable debug mode
    enable = false,

    -- print logs to messages.
    console_log = true,

    -- write logs to file.
    -- For *NIX: `~/.local/share/nvim/gentags.log`.
    -- For Windows: `$env:USERPROFILE\AppData\Local\nvim-data\gentags.log`.
    file_log = false,
  },
}

--- @type gentags.Options
local Configs = {}

--- @param opts gentags.Options?
M.setup = function(opts)
  Configs = vim.tbl_deep_extend("force", vim.deepcopy(Defaults), opts or {})

  logging.setup({
    name = "gentags",
    level = Configs.debug.enable and LogLevels.DEBUG or LogLevels.INFO,
    console_log = Configs.debug.console_log,
    file_log = Configs.debug.file_log,
    file_log_name = "gentags.log",
  })

  -- cache dir
  logging.get("gentags"):ensure(
    vim.fn.filereadable(Configs.cache_dir) <= 0,
    "%s (cache_dir) already exist but not a directory!",
    vim.inspect(Configs.cache_dir)
  )
  vim.fn.mkdir(Configs.cache_dir, "p")
end

return M
