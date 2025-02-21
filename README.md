# pretty.nvim

A collection of pre-configured nvim plugins, plug and play ready.

## UI / TermUI

![ui](picture/ui.png)

[More](picture)

## Requirements

- [neovim](https://github.com/neovim/neovim): ~0.6+ ==> **Neovim v0.10.3 embedded**
- [python3](): latest +pip +venv ==> **python3.13 won't work**
- [npm](https://www.npmjs.com/): latest

## Quick Start

```shell
# Github
bash -c "$(curl -fsSL https://raw.githubusercontent.com/mtdcy/pretty.nvim/main/install.sh)"
# CN
bash -c "$(curl -fsSL http://git.mtdcy.top/mtdcy/pretty.nvim/raw/branch/main/install.sh)"
```

==> **Dependencies are installed locally in pretty.nvim.**

## Features

- Preconfigured plugins and support/host binaries & neovim installer.
- Linters & checkers & conf templates.
- Sticky buffer for sidebars.
- Seamless buffer switch with `C-n` & `C-p`, even in terminal mode.
- Smart window & buffer close with `C-q`.
- Full functional bufferline with mouse clickable.
- Support copy text back from ssh session, [copyd](copyd.md)

## Settings

- g:pretty_verbose      - How many messages show on screen.
- g:pretty_dark         - Dark mode.
- g:pretty_autocomplete - Auto complete or complete with Tab.

### Key Mappings

Since mouse works even in terminal, you don't have to remember these key mappings.

> There are only a few that cannot be done with the mouse, which marked as '[*]'.

#### Windows

[x] Prefer using `C-q` instead of `:quit` or `:close`, as it is smarter.

- [n] `F8` - Open bufexplorer on center screen. [*]
- [n] `F9` - Open NERDTree (file brower) on left side. [*]
- [n] `F10` - Open Tagbar or TOC on right side. [*]
- [n] `F12` - Open LazyGit window. [*]

- [n] `C-h` - Move focus to left window.
- [n] `C-l` - Move focus to right window.
- [n] `C-j` - Move focus to below window.
- [n] `C-k` - Move focus to up window.

- [n] `C-q` - Close windows and buffers, util the last one.

#### Buffers

- [n] `C-e` - Buffer Explorer
- [n] `C-n` - Buffer Next
- [n] `C-p` - Buffer Prev

- [n] `<leader>1` - Select buffer 1
- [n] `<leader>2` - Select buffer 2
- [n] `<leader>3` - Select buffer 3
- [n] `<leader>4` - Select buffer 4
- [n] `<leader>5` - Select buffer 5
- [n] `<leader>6` - Select buffer 6
- [n] `<leader>7` - Select buffer 7
- [n] `<leader>8` - Select buffer 8
- [n] `<leader>9` - Select buffer 9
- [n] `<leader>0` - Select buffer 10

#### About terminal buffers

```vim
:tnoremap <Esc> <C-\><C-N>
```

After this, everything works like insert and normal mode.

#### Goto/Jump

[ ] TODO: map `gd` `gk` `gD` to single key.

- [n] `gg` - Goto first line
- [n] `gG` - Goto last line
- [n] `g[` - Goto start of code block
- [n] `g]` - Goto end of code block
- [n] `gd` - Goto symbols' definition
- [n] `gb` - Goto back to previous position
- [n] `gk` - Goto keyword's man page
- [n] `ge` - Goto next error
- [v] `gy` - Goto yank
- [n] `gp` - Goto paste
- [n] `gl` - Goto loclist

#### Features

- [v] `/` - Tabularize

## Plugins Embedded

- Colors
  - [solarized8](https://github.com/lifepillar/vim-solarized8)@6178a07
- Explorer
  - [NERDTree](https://github.com/preservim/nerdtree)@f3a4d8e
  - [Denite](https://github.com/Shougo/denite.nvim)@055dd68
- Tags List
  - [Tagbar](https://github.com/preservim/tagbar)@12edcb5
- Status Line
  - [lightline.vim](https://github.com/itchyny/lightline.vim)@58c97bc
  - [lightline-bufferline](https://github.com/mengelbrecht/lightline-bufferline)@8206632
- Linter
  - [ALE](https://github.com/dense-analysis/ale)@6db58b3
  - [lightline-ale](https://github.com/maximbaz/lightline-ale)@a861f691a
- Completor
  - [deoplete.nvim](https://github.com/Shougo/deoplete.nvim)@43d7457
  - [neosnippet](https://github.com/Shougo/neosnippet.vim)@efb2a61 + [snippets](https://github.com/Shougo/neosnippet-snippets)@725c989
- VCS
  - [lazygit.nvim](https://github.com/kdheepak/lazygit.nvim)@0ada6c6
  - [vim-signify](https://github.com/mhinz/vim-signify/tree/master)@8670143
- Misc
  - [Tabular](https://github.com/godlygeek/tabular)@339091a
  - [rainbow](https://github.com/luochen1990/rainbow)@61f719a
  - [vim-matchtag](https://github.com/leafOfTree/vim-matchtag)@54357c0
  - [nerdcommenter](https://github.com/preservim/nerdcommenter)@e361a44

### Howto Add Plugins

I don't like plugin managers as I won't upgrade plugins frequently.

```shell
git remote add bufexplorer https://github.com/jlanzarotta/bufexplorer.git
git fetch bufexplorer
git merge bufexplorer/master --allow-unrelated-histories --no-commit --squash
git checkout HEAD -- README.md .gitignore   # keep ours files
git mv LICENSE LICENSE.bufexplorer          # keep their license file
git rm -rf <...>                            # delete unneeded
vim README.md                               # update README
git add README.md

git commit -m "merged bufexplorer"
git push origin main
```

Delete plugin with `git revert`

## Plugins Configurations

### ALE

> Try to use python to install packages, because nvim has a stronger dependency on python.

> Try to find configurations on [codeac](https://www.codeac.io/documentation/index.html)

- Vim
  - [vimls](https://github.com/iamcco/vim-language-server) - `npm install vim-language-server`
  - [vint](https://github.com/Vimjas/vint) - `pip3 install vim-vint`
    - [.vintrc](.vintrc.yaml) - [Rules](https://github.com/Vimjas/vint/wiki/Vint-linting-policy-summary)
- Sh
  - [shellcheck](https://github.com/koalaman/shellcheck) - `pip3 install shellcheck-py`
    - [.shellcheckrc](lintrc/shellcheckrc)
- Go
  - [gopls](https://pkg.go.dev/golang.org/x/tools/gopls) - `go install golang.org/x/tools/gopls@latest`
  - [gofmt](https://pkg.go.dev/cmd/gofmt)
  - [goimports](https://pkg.go.dev/golang.org/x/tools/cmd/goimports) - `go install golang.org/x/tools/cmd/goimports@latest`
- Rust
  - [rust-analyzer](https://github.com/rust-lang/rust-analyzer) - `rustup component add rust-analyzer`
  - [rustfmt](https://github.com/rust-lang/rustfmt) - `rustup component add rustfmt`
    - .rustfmt.toml - `rustfmt --print-config default .rustfmt.toml`
- C/C++
  - [ccls](https://github.com/MaskRay/ccls)
    - [.ccls](https://github.com/MaskRay/ccls/wiki/Project-Setup#ccls-file)
  - [clang-format]() - `pip3 install clang-format` - [参数](https://clang.llvm.org/docs/ClangFormatStyleOptions.html)
- Make
  - [checkmake](https://github.com/mrtazz/checkmake) - `go install github.com/mrtazz/checkmake/cmd/checkmake@latest`
- CMake
  - [cmakelint](https://github.com/cmake-lint/cmake-lint) - `pip3 install cmakelint`
    - [.cmakelintrc](lintrc/cmakelintrc)
- Dockerfile
  - [haoolint](https://github.com/hadolint/hadolint) - `pip3 install hadolint-bin`
    - [.hadolint.yaml](lintrc/hadolint.yaml)
- Html,css
  - [htmlhint](https://github.com/htmlhint/HTMLHint)
    - [.htmlhintrc](lintrc/htmlhintrc)
  - [stylelint](https://github.com/stylelint/stylelint)
    - [.stylelintrc](linter/stylelintrc) - [rules](https://github.com/stylelint/stylelint/blob/main/docs/user-guide/rules.md)
- JavaScript|TypeScript
  - [tsserver](https://github.com/microsoft/TypeScript/wiki/Standalone-Server-%28tsserver%29) - `npm install typescript`
    - [tsserver.json](lintrc/tsserver.json)
  - [eslint](https://eslint.org) - `npm install eslint` - **load if .eslintrc.js exists**
    - [.eslintrc.js](lintrc/eslintrc) - [deprecated](https://eslint.org/docs/latest/use/configure/configuration-files-deprecated)

```shell
# quick start
npm config set registry https://mirrors.mtdcy.top/npmjs
npm install # tsserver can't find modules
nvim path/to/some.ts
```

- Java
  - [javac]()
- Json
  - [jsonlint](https://github.com/zaach/jsonlint) - `npm install jsonlint`
- Markdown - [Rules](https://github.com/DavidAnson/markdownlint#rules--aliases)
  - [markdownlint](https://github.com/igorshubovych/markdownlint-cli) - `npm install markdownlint-cli`
    - [.markdownlint.yaml](lintrc/markdownlint.yaml)
- Yaml
  - [yamllint](https://github.com/adrienverge/yamllint) - `pip3 install yamllint`
    - [.yamllint.yaml](lintrc/yamllint.yaml) - [Rules](https://yamllint.readthedocs.io/en/stable/rules.html)
- Python
  - [jedils](https://github.com/pappasam/jedi-language-server) - `pip3 install jedi-language-server`
  - [pylint](https://github.com/pylint-dev/pylint) - `pip3 install pylint`
    - [.pylintrc](lintrc/pylintrc) - `pylint --disable=bare-except,invalid-name --class-rgx='[A-Z][a-z]+' --generate-rcfile`
  - [flake8](https://github.com/PyCQA/flake8) - `pip3 install flake8`
    - [.flake8](lintrc/flake8) - 'flake8 suggests using tox.ini to keep configure'
  - [black](https://github.com/psf/black) - `pip3 install black`
    - [pyproject.toml](lintrc/black.toml) - 'put a [tool.black] section into pyproject.toml'
- Lua
  - [lua-language-server](https://github.com/LuaLS/lua-language-server) - **try build from source**
    - [.luarc.json](lintrc/luarc.json)
  - [luacheck](https://github.com/mpeterv/luacheck) - `luarocks install luacheck lanes`
    - [.luacheckrc](lintrc/luacheckrc) - [Rules](https://luacheck.readthedocs.io/en/stable/warnings.html)

## Mirror

- [CN](https://git.mtdcy.top:8443/mtdcy/pretty.nvim.git)
- [PR](https://github.com/mtdcy/pretty.nvim.git)

## Copyrights and Licenses

- Files merged from other projects follow their own licenses.
- Files belonging to this project(mainly top-level files) are licensesd
  under the [BSD-2-Clause](LICENSE).
