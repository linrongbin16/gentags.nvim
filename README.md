<!-- markdownlint-disable MD001 MD013 MD034 MD033 MD051 -->

# gentags.nvim

<p align="center">
<a href="https://github.com/neovim/neovim/releases/v0.7.0"><img alt="Neovim" src="https://img.shields.io/badge/Neovim-v0.7+-57A143?logo=neovim&logoColor=57A143" /></a>
<a href="https://github.com/linrongbin16/commons.nvim"><img alt="commons.nvim" src="https://custom-icon-badges.demolab.com/badge/Powered_by-commons.nvim-teal?logo=heart&logoColor=fff&labelColor=deeppink" /></a>
<a href="https://luarocks.org/modules/linrongbin16/gentags.nvim"><img alt="luarocks" src="https://custom-icon-badges.demolab.com/luarocks/v/linrongbin16/gentags.nvim?label=LuaRocks&labelColor=063B70&logo=tag&logoColor=fff&color=blue" /></a>
<a href="https://github.com/linrongbin16/gentags.nvim/actions/workflows/ci.yml"><img alt="ci.yml" src="https://img.shields.io/github/actions/workflow/status/linrongbin16/gentags.nvim/ci.yml?label=GitHub%20CI&labelColor=181717&logo=github&logoColor=fff" /></a>
<a href="https://app.codecov.io/github/linrongbin16/gentags.nvim"><img alt="codecov" src="https://img.shields.io/codecov/c/github/linrongbin16/gentags.nvim?logo=codecov&logoColor=F01F7A&label=Codecov" /></a>
</p>

<p align="center"><i>
Tags generator/management for old school vimers in Neovim.
</i></p>

To be honest, it seems that tags have become useless in Neovim today, LSP and treesitter replaced tags and make (Neo)vim a modern editor.

While there exists gap when LSP server or treesitter implementations are insufficient, which brings tags back to us as a supplement to fill the gap.

## Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Install](#install)
- [Usage](#usage)
- [Configuration](#configuration)
- [Recommendations](#recommendations)
- [Alternatives](#alternatives)
- [Development](#development)
- [Contribute](#contribute)

## Features

- [x] Automatically generate tags in background jobs.
- [x] Support both workspace/single file mode.
- [x] Initial generate whole workspace on first file open, incremental update on file save.
- [x] Terminate immediately on nvim leave.
- [ ] Disk cache management and garbage collection.
- [ ] Real-time status for Neovim components such as statusline.

## Requirements

- Neovim &ge; 0.7.0.
- [universal-ctags](https://github.com/universal-ctags/ctags) (default backend).

PRs are welcome to add other backends.

## Install

<details>
<summary><b>With <a href="https://github.com/folke/lazy.nvim">lazy.nvim</a></b></summary>

```lua
require("lazy").setup({
  {
    "linrongbin16/gentags.nvim",
    config = function()
      require('gentags').setup()
    end,
  },
})
```

</details>

<details>
<summary><b>With <a href="https://github.com/lewis6991/pckr.nvim">pckr.nvim</a></b></summary>

```lua
require("pckr").add({
  {
    "linrongbin16/gentags.nvim",
    config = function()
      require("gentags").setup()
    end,
  },
})
```

</details>

## Usage

Gentags will register several background jobs when you editing files:

- Locate the workspace root directory, or fallback to single file mode.
- Generate and load tags on first file open.
- Update tags on file save.
- Terminate background jobs on nvim leave.

By default all tags are generated in `stdpath('cache') . '/gentags.nvim'` directory:

- For UNIX/Linux: `~/.cache/nvim/gentags.nvim`.
- For Windows: `$env:USERPROFILE\AppData\Local\Temp\nvim\gentags.nvim`.

## Configuration

To configure default options, please use:

```lua
require('gentags').setup(opts)
```

The `otps` is an optional lua table that overwrites default options.

For complete options and defaults, please see [configs.lua](https://github.com/linrongbin16/gentags.nvim/tree/main/lua/gentags/configs.lua).

## Recommendations

Recommend use tags with below plugins to smooth your editing flow:

- [vista.vim](https://github.com/liuchengxu/vista.vim): View and search symbols on current file.
- [cmp-nvim-tags](https://github.com/quangnguyen30192/cmp-nvim-tags): Code completion data source for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp).

## Alternatives

- [gentags.lua](https://github.com/JMarkin/gentags.lua): Auto generates tags by filetype.
- [vim-gutentags](https://github.com/ludovicchabant/vim-gutentags): A Vim plugin that manages your tag files.

## Development

To develop the project and make PR, please setup with:

- [lua_ls](https://github.com/LuaLS/lua-language-server).
- [stylua](https://github.com/JohnnyMorganz/StyLua).
- [luarocks](https://luarocks.org/).
- [luacheck](https://github.com/mpeterv/luacheck).

To run unit tests, please install below dependencies:

- [vusted](https://github.com/notomo/vusted).

Then test with `vusted ./test`.

## Contribute

Please open [issue](https://github.com/linrongbin16/gentags.nvim/issues)/[PR](https://github.com/linrongbin16/gentags.nvim/pulls) for anything about gentags.nvim.

Like gentags.nvim? Consider

[![Github Sponsor](https://img.shields.io/badge/-Sponsor%20Me%20on%20Github-magenta?logo=github&logoColor=white)](https://github.com/sponsors/linrongbin16)
[![Wechat Pay](https://img.shields.io/badge/-Tip%20Me%20on%20WeChat-brightgreen?logo=wechat&logoColor=white)](https://github.com/linrongbin16/lin.nvim/wiki/Sponsor)
[![Alipay](https://img.shields.io/badge/-Tip%20Me%20on%20Alipay-blue?logo=alipay&logoColor=white)](https://github.com/linrongbin16/lin.nvim/wiki/Sponsor)
