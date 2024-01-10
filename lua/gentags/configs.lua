local M = {}

--- @alias gentags.Options table<any, any>
--- @type gentags.Options
local Defaults = {
  -- binary name
  tool = "ctags",

  -- ctags options
  ctags = {
    "--tag-relative=never",

    -- exclude vcs
    "--exclude=*.git",
    "--exclude=*.svg",
    "--exclude=*.hg",
    "--exclude=*.log",

    -- exclude blob/binary files
    "--exclude=*.exe",
    "--exclude=*.dll",
    "--exclude=*.mp3",
    "--exclude=*.ogg",
    "--exclude=*.flac",
    "--exclude=*.swp",
    "--exclude=*.swo",
    "--exclude=*.bmp",
    "--exclude=*.gif",
    "--exclude=*.ico",
    "--exclude=*.jpg",
    "--exclude=*.png",
    "--exclude=*.rar",
    "--exclude=*.zip",
    "--exclude=*.tar",
    "--exclude=*.tar.gz",
    "--exclude=*.tar.xz",
    "--exclude=*.tar.bz2",
    "--exclude=*.pdf",
    "--exclude=*.doc",
    "--exclude=*.docx",
    "--exclude=*.ppt",
    "--exclude=*.pptx",
  },

  -- workspace detection
  workspace = { ".git", ".svn" },

  -- excluded filetypes
  disabled_filetypes = { "neo-tree", "NvimTree" },

  -- excluded workspace
  disabled_workspaces = {},

  -- excluded files
  disabled_files = {},

  -- cache directory
  -- For *NIX: `~/.cache/nvim/gentags.nvim`.
  -- For Windows: `$env:USERPROFILE\AppData\Local\Temp\nvim\gentags.nvim`.
  cache_dir = vim.fn.stdpath("cache") .. "/gentags.nvim",

  -- garbage collection
  gc = {
    -- policy:
    --   - LRU (least recently used): remove the least recently used.
    --- @type "LRU"
    policy = "LRU",

    -- trigger by:
    --  * count: by tags cache count, for example: 100.
    --  * size: by tags cache size, for example: 1GB, 300MB, 4096KB, with suffix "GB", "MG", "KB".
    --
    --- @type {name:"count"|"size",value:string|integer}|nil
    trigger = nil,

    -- tags cache that will be exclude from gc.
    exclude = {},
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
  local workspace = vim.deepcopy(Defaults.workspace)
  Configs = vim.tbl_deep_extend("force", vim.deepcopy(Defaults), opts or {})
  Configs.workspace =
    vim.list_extend(vim.deepcopy(Configs.workspace), workspace)
  return Configs
end

return M
