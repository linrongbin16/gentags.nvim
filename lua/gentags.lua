local logger = require("gentags.logger")
local LogLevels = require("gentags.logger").LogLevels

local M = {}

--- @alias gentags.Options table<any, any>
--- @type gentags.Options
local Defaults = {
  -- cache directory
  --
  -- For *NIX: `~/.cache/nvim/gentags/`.
  --
  --- @type string
  cache_dir = vim.fn.stdpath("cache") .. "/gentags",

  -- disk cache garbage collection
  -- by default there's no garbage collection.
  gc = {
    -- when tags cache count (in cache directory) >= max value, for example: 100.
    --
    --- @type integer?
    maxfile = nil,

    -- when tags cache size (in cache directory) >= max value, for example:
    -- * 1GB
    -- * 100MB
    -- * 4096KB
    -- suffix: "GB", "MG", "KB"
    --
    --- @type string?
    maxsize = nil,

    -- garbage collection policy:
    -- * LRU (least recently used): remove the least recently used cache.
    --
    --- @type "LRU"|""
    policy = "LRU",

    -- excluded workspaces list
    -- tags for below workspaces are excluded from garbage collection policy.
    --
    --- @type string[]
    excluded = {},
  },

  -- underline binary
  binary = "ctags",

  -- user command
  command = { name = "GenTags", desc = "Generate tags" },

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
end

return M
