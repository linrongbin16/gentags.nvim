local M = {}

--- @alias gentags.Options table<any, any>
--- @type gentags.Options
local Defaults = {

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
M.setup = function(opts) end

return M
