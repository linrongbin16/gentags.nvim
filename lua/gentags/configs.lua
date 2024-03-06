local tbl = require("gentags.commons.tbl")
local str = require("gentags.commons.str")

local M = {}

--- @alias gentags.Options table<any, any>
--- @type gentags.Options
local Defaults = {
  -- binary name
  tool = "ctags",

  -- ctags options
  ctags = {
    "--tag-relative=never",

    -- Recommended Options:
    --
    -- -- exclude logs
    -- "--exclude=*.log",
    --
    -- -- exclude vcs
    -- "--exclude=*.git",
    -- "--exclude=*.svg",
    -- "--exclude=*.hg",
    --
    -- -- exclude nodejs
    -- "--exclude=node_modules",
    --
    -- -- exclude tags/cscope
    -- "--exclude=*tags*",
    -- "--exclude=*cscope.*",
    --
    -- -- exclude python
    -- "--exclude=*.pyc",
    --
    -- -- exclude jvm class
    -- "--exclude=*.class",
    --
    -- -- exclude VS project generated
    -- "--exclude=*.pdb",
    -- "--exclude=*.sln",
    -- "--exclude=*.csproj",
    -- "--exclude=*.csproj.user",
    --
    -- -- exclude blobs
    -- "--exclude=*.exe",
    -- "--exclude=*.dll",
    -- "--exclude=*.mp3",
    -- "--exclude=*.ogg",
    -- "--exclude=*.flac",
    -- "--exclude=*.swp",
    -- "--exclude=*.swo",
    -- "--exclude=*.bmp",
    -- "--exclude=*.gif",
    -- "--exclude=*.ico",
    -- "--exclude=*.jpg",
    -- "--exclude=*.png",
    -- "--exclude=*.rar",
    -- "--exclude=*.zip",
    -- "--exclude=*.tar",
    -- "--exclude=*.tar.gz",
    -- "--exclude=*.tar.xz",
    -- "--exclude=*.tar.bz2",
    -- "--exclude=*.pdf",
    -- "--exclude=*.doc",
    -- "--exclude=*.docx",
    -- "--exclude=*.ppt",
    -- "--exclude=*.pptx",
  },

  -- workspace detection
  workspace = { ".git", ".svn", ".hg" },

  -- excluded workspace
  disabled_workspaces = {},

  -- excluded filetypes
  disabled_filetypes = {

    -- Recommended Options:
    --
    -- "neo-tree",
    -- "NvimTree",
  },

  -- excluded filenames
  disabled_filenames = {},

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
  local user_ctags_opts = tbl.tbl_get(opts, "ctags") or {}
  local ctags_opts = vim.deepcopy(Defaults.ctags or {})
  for _, o in ipairs(user_ctags_opts) do
    if str.not_empty(o) then
      table.insert(ctags_opts, o)
    end
  end

  local user_workspace_opts = tbl.tbl_get(opts, "workspace") or {}
  local workspace_opts = vim.deepcopy(Defaults.workspace or {})
  for _, w in ipairs(user_workspace_opts) do
    if str.not_empty(w) then
      table.insert(workspace_opts, w)
    end
  end

  Configs = vim.tbl_deep_extend("force", vim.deepcopy(Defaults), opts or {})
  Configs.ctags = ctags_opts
  Configs.workspace = workspace_opts

  return Configs
end

return M
