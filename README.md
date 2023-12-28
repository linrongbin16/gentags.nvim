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

## Table of Contents

- [Features](#features)
- [Install](#install)
- [Usage](#usage)
- [Configuration](#configuration)
- [Alternatives](#alternatives)
- [Development](#development)
- [Contribute](#contribute)

## Features

- [x] Support both workspace/single file.
- [ ] Incremental update on file save.
- [ ] Disk cache management and garbage collection.
- [x] Async run & terminate immediately on vim leave.
- [ ] Real-time status for Neovim components such as statusline.

## Install

Requirements:

- Neovim &ge; 0.7.0.
- (Default) [universal-ctags](https://github.com/universal-ctags/ctags).

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

## Configuration

For complete options and defaults, please see [configs.lua](https://github.com/linrongbin16/gentags.nvim/tree/main/lua/gentags/configs.lua).

## Alternatives

- [gentags.lua](https://github.com/JMarkin/gentags.lua)
- [vim-gutentags](https://github.com/ludovicchabant/vim-gutentags)

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
