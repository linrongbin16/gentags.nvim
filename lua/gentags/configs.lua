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

  workspace = {
    root = { ".git", ".svn" },
  },

  -- cache management
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

  -- user command
  command = { name = "GenTags", desc = "Generate tags" },

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

--- @return gentags.Options
M.get = function()
  return Configs
end

--- @param opts gentags.Options?
--- @return gentags.Options
M.setup = function(opts)
  local workspace_root = vim.deepcopy(Defaults.workspace.root)
  Configs = vim.tbl_deep_extend("force", vim.deepcopy(Defaults), opts or {})
  Configs.workspace.root =
    vim.list_extend(vim.deepcopy(Configs.workspace.root), workspace_root)
  return Configs
end

return M
