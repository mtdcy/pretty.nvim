# pretty.nvim

A collection of pre-configured nvim plugins, plug and play ready.

## UI / TermUI

![ui](picture/ui.png)

[More](picture)

## Requirements

- [neovim](https://github.com/neovim/neovim): ~0.6+ ==> **Neovim v0.9.4 embedded**
- [python3](): latest +pip +venv
- [npm](https://www.npmjs.com/): latest

## Installation

Clone this repo or download from Release, then run `install.sh`. 

==> **Dependencies are installed locally in pretty.nvim.**

```shell
git clone https://github.com/mtdcy/pretty.nvim.git
cd pretty.nvim && ./install.sh
```

## Features

- Preconfigured plugins and support/host binaries & neovim installer.
- Linters & checkers & conf templates.
- Sticky buffer for sidebars.
- Seamless buffer switch with `C-n` & `C-p`, even in terminal mode.
- Smart window & buffer close with `C-q`.
- Full functional bufferline with mouse clickable.
- Support copy text back from ssh session, [copyd](copyd.md)

## Settings

- g:pretty_verbose - How many messages show on screen.
- g:pretty_dark - Dark mode.
- g:pretty_autocomplete - Auto complete or complete with Tab.

### Key Mappings

Since mouse works even in terminal, you don't have to remember these key mappings.
There are only a few that cannot be done with the mouse, which marked as '[*]'.

#### Windows

[x] Prefer using `C-q` instead of `:quit` or `:close`, as it is smarter.

- [n] `F8` - Open bufexplorer on center screen. [*]
- [n] `F9` - Open NERDTree (file brower) on left side. [*]
- [n] `F10` - Open Tagbar or TOC on right side. [*]

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
:tnoremap <Esc>     <C-\><C-N>
```

After this, everything works like insert and normal mode.

#### Goto/Jump

[ ] TODO: map `gd` `gk` `gD` to single key.

- [n] `gg` - Goto first line
- [n] `gG` - Goto last line
- [n] `g[` - Goto start of code block
- [n] `g]` - Goto end of code block
- [n] `gd` - Goto symbols' definition
- [n] `gh` - Goto top of stack (home)
- [n] `gk` - Goto keyword's man page
- [n] `ge` - Goto next error
- [v] `gy` - Goto yank
- [n] `gp` - Goto paste
- [n] `gl` - Goto loclist

#### Features

- [v] `/` - Tabularize

## Plugins Embedded

### Window Plugins 

- [solarized8](https://github.com/lifepillar/vim-solarized8)@bde9cab3d
- [bufexplorer](https://github.com/jlanzarotta/bufexplorer)@7.4.26
- [NERDTree](https://github.com/preservim/nerdtree)@7.0.0
- [Tagbar](https://github.com/preservim/tagbar)@3.1.1
- [lightline.vim](https://github.com/itchyny/lightline.vim)@1c6b455c0
  - [lightline-ale](https://github.com/maximbaz/lightline-ale)@a861f691a
  - [lightline-bufferline](https://github.com/mengelbrecht/lightline-bufferline)@8a2e7ab94

### Function Plugins 

- [echodoc.vim](https://github.com/Shougo/echodoc.vim)@8c7e99e
- [vim-signify](https://github.com/mhinz/vim-signify/tree/master)@7d538b7
- [ALE](https://github.com/dense-analysis/ale)@3.3.0
- [deoplete.nvim](https://github.com/Shougo/deoplete.nvim)@62dd019
- [Neosnippet](https://github.com/Shougo/neosnippet.vim)@efb2a615d
  - [neosnippet-snippets](https://github.com/Shougo/neosnippet-snippets)@725c989f1
- [fugitive](https://github.com/tpope/vim-fugitive)@46eaf8918
- [Tabular](https://github.com/godlygeek/tabular)@339091ac4
- [lazygit.nvim](https://github.com/kdheepak/lazygit.nvim)@774dcec

### Language Plugins

[ ] FIXME: `vim-markdown` is pretty good but the toc does not work so well.

- Markdown : [vim-markdown](https://github.com/preservim/vim-markdown)@46add6c30
- Go       : [vim-go](https://github.com/fatih/vim-go)@973279275 - `:GoInstallBinaries`
- Rust     : [vim-racer](https://github.com/racer-rust/vim-racer)@d1aead98a
- Html5    : [html5.vim](https://github.com/othree/html5.vim.git)@ 485f2cd

### Howto Add Plugins 

I don't like plugin managers as I won't upgrade plugins frequently.

```shell
git remote add bufexplorer https://github.com/jlanzarotta/bufexplorer.git
git fetch bufexplorer
git checkout -b bufexplorer --track bufexplorer/master
# switch branch with: git branch bufexplorer --set-upstream-to=bufexplorer/xxxx
git pull bufexplorer master

git checkout main
git merge bufexplorer --allow-unrelated-histories --no-commit --squash
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

- Vim
  - [vimls](https://github.com/iamcco/vim-language-server) - `npm install vim-language-server`
- Sh
  - [shellcheck](https://github.com/koalaman/shellcheck) - `npm install shellcheck`
  - [shfmt](https://github.com/mvdan/sh) - `go install mvdan.cc/sh/v3/cmd/shfmt@latest`
- Go
  - [gopls]() - `go install golang.org/x/tools/gopls@latest`
  - [goimports]() - `go install golang.org/x/tools/cmd/goimports@latest`
- Rust
  - [cargo|rustc](https://www.rust-lang.org) - [Installation](https://www.rust-lang.org/tools/install)
  - [rustfmt]() - `rustup component add rustfmt`
- C/C++
  - [gcc]() or [clang]()
  - [clang-format]() - `npm install clang-format` - [参数](https://clang.llvm.org/docs/ClangFormatStyleOptions.html)
- Make
  - [checkmake](https://github.com/mrtazz/checkmake) - `go install github.com/mrtazz/checkmake/cmd/checkmake@latest`
- CMake
  - [cmakelint]() - `pip3 install cmakelint`
  - [cmake-format]() - `pip3 install cmake-format`
- Dockerfile
  - [haoolint](https://github.com/hadolint/hadolint) - `brew install hadolint`
  - [dprint](https://dprint.dev/) - `npm install dprint`
- Html
  - [htmlhint](https://github.com/htmlhint/HTMLHint) - `npm install htmlhint`
    - [.htmlhintrc](.htmlhintrc)
  - [prettier]() - `npm install prettier`
    - [.prettierrc](.prettierrc), [.prettierignore](.prettierignore)(use .gitignore syntax)
- Java
  - [javac]()
  - [clang-format]()
- JavaScript
  - [eslint]() - `npm install eslint`
    - [.eslintrc](.eslintrc)
  - [prettier-eslint](https://github.com/prettier/prettier-eslint-cli) - `npm install prettier-eslint-cli`
- Json
  - [jsonlint](https://github.com/zaach/jsonlint) - `npm install jsonlint`
  - [clang-format]()
- Markdown - [Rules](https://github.com/DavidAnson/markdownlint#rules--aliases)
  - [markdownlint](https://github.com/igorshubovych/markdownlint-cli) - `npm install markdownlint-cli`
    - [.markdownlint.yaml](.markdownlint.yaml)
  - [prettier](https://prettier.io/) - `npm install prettier`
- Yaml
  - [yamllint](https://github.com/adrienverge/yamllint) - `pip3 install yamllint`
  - [yamlfix](https://github.com/lyz-code/yamlfix) - `pip3 install yamlfix`
- Python
  - [pylint]() - `pip3 install pylint`
  - [autopep8](https://pypi.org/project/autopep8) - `pip3 install autopep8`

## Mirror

- [CN](https://git.mtdcy.top:8443/mtdcy/pretty.nvim.git)
- [PR](https://github.com/mtdcy/pretty.nvim.git)

## Copyrights and Licenses

- Files merged from other projects follow their own licenses.
- Files belonging to this project(mainly top-level files) are licensesd
  under the [BSD-2-Clause](LICENSE).
