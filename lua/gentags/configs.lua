local M = {}

--- @alias gentags.Options table<any, any>
--- @type gentags.Options
local Defaults = {
  -- binary name
  tool = "ctags",

  -- ctags options
  ctags = {
    ["--tag-relative=never"] = true,

    -- exclude logs
    ["--exclude=*.log"] = true,

    -- exclude vcs
    ["--exclude=*.git"] = true,
    ["--exclude=*.svg"] = true,
    ["--exclude=*.hg"] = true,

    -- exclude nodejs
    ["--exclude=node_modules"] = true,

    -- exclude tags/cscope
    ["--exclude=*tags*"] = true,
    ["--exclude=*cscope.*"] = true,

    -- exclude python
    ["--exclude=*.pyc"] = true,

    -- exclude jvm class
    ["--exclude=*.class"] = true,

    -- exclude VS project generated
    ["--exclude=*.pdb"] = true,
    ["--exclude=*.sln"] = true,
    ["--exclude=*.csproj"] = true,
    ["--exclude=*.csproj.user"] = true,

    -- exclude blobs
    ["--exclude=*.exe"] = true,
    ["--exclude=*.dll"] = true,
    ["--exclude=*.mp3"] = true,
    ["--exclude=*.ogg"] = true,
    ["--exclude=*.flac"] = true,
    ["--exclude=*.swp"] = true,
    ["--exclude=*.swo"] = true,
    ["--exclude=*.bmp"] = true,
    ["--exclude=*.gif"] = true,
    ["--exclude=*.ico"] = true,
    ["--exclude=*.jpg"] = true,
    ["--exclude=*.png"] = true,
    ["--exclude=*.rar"] = true,
    ["--exclude=*.zip"] = true,
    ["--exclude=*.tar"] = true,
    ["--exclude=*.tar.gz"] = true,
    ["--exclude=*.tar.xz"] = true,
    ["--exclude=*.tar.bz2"] = true,
    ["--exclude=*.pdf"] = true,
    ["--exclude=*.doc"] = true,
    ["--exclude=*.docx"] = true,
    ["--exclude=*.ppt"] = true,
    ["--exclude=*.pptx"] = true,
  },

  -- workspace detection
  workspace = { [".git"] = true, [".svn"] = true },

  -- excluded filetypes
  disabled_filetypes = { ["neo-tree"] = true, ["NvimTree"] = true },

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
  Configs = vim.tbl_deep_extend("force", vim.deepcopy(Defaults), opts or {})
  return Configs
end

return M
