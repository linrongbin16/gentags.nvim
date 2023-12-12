local logger = require("gentags.logger")
local LogLevels = require("gentags.logger").LogLevels

local M = {}

--- @alias gentags.Options table<any, any>
--- @type gentags.Options
local Defaults = {
  -- generate tags command tools
  binary = {
    mapping = { c = "ctags", cpp = "ctags", lua = "ctags", markdown = "" },
    fallback = "ctags -a",
  },

  -- user command
  command = { name = "GenTags", desc = "Generate tags" },

  -- cache directory
  --
  -- For *NIX: `~/.cache/nvim/gentags.nvim/`.
  --
  --- @type string
  cache_dir = vim.fn.stdpath("cache") .. "/gentags.nvim",

  -- disk cache garbage collection.
  -- by default there's no pre-configured garbage collection, e.g. no tags cache will be removed.
  gc = {
    -- when tags cache count (in cache directory) > max value, for example: 100.
    --
    --- @type integer?
    maxfile = nil,

    -- when tags cache size (in cache directory) > max value, for example:
    -- * 1GB
    -- * 100MB
    -- * 4096KB
    -- suffix: "GB", "MG", "KB"
    --
    --- @type string?
    maxsize = nil,

    -- garbage collection policy:
    -- * LRU (least recently used): remove the least recently used.
    --
    --- @type "LRU"
    policy = "LRU",

    -- excluded directories list
    -- tags for below directories are excluded from garbage collection policy.
    --
    --- @type string[]
    exclude = {},
  },

  -- enable debug mode
  --
  --- @type boolean
  debug = false,

  -- print logs to console (command line).
  --
  --- @type boolean
  console_log = true,

  -- write logs to file.
  --
  -- For *NIX: `~/.local/share/nvim/gentags.log`.
  -- For Windows: `$env:USERPROFILE\AppData\Local\nvim-data\gentags.log`.
  --
  --- @type boolean
  file_log = false,
}

--- @type gentags.Options
local Configs = {}

--- @param opts gentags.Options?
M.setup = function(opts)
  Configs = vim.tbl_deep_extend("force", vim.deepcopy(Defaults), opts or {})

  logger.setup({
    level = Configs.debug and LogLevels.DEBUG or LogLevels.INFO,
    console_log = Configs.console_log,
    file_log = Configs.file_log,
  })

  -- cache dir
  logger.ensure(
    vim.fn.filereadable(Configs.cache_dir) <= 0,
    "%s (cache_dir) already exist but not a directory!",
    vim.inspect(Configs.cache_dir)
  )
  vim.fn.mkdir(Configs.cache_dir, "p")
end

return M
