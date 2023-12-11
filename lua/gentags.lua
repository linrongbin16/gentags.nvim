local logger = require("gentags.logger")
local LogLevels = require("gentags.logger").LogLevels

local M = {}

--- @alias gentags.Options table<any, any>
--- @type gentags.Options
local Defaults = {
  binary = "ctags",

  command = { name = "GenTags", desc = "Generate tags" },

  cache = {
    dir = vim.fn.stdpath("cache") .. "/gentags",

    garbage_policy = {
      maxfile = 100,
      maxsize = "1GB",
    },
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
  -- For Windows: `$env:USERPROFILE\AppData\Local\nvim-data\gentags.log`.
  -- For *NIX: `~/.local/share/nvim/gentags.log`.
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
