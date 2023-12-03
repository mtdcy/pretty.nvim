# pretty.nvim

A collection of nvim plugins/Personal nvim settings.

## Mirror

- [CN](https://git.mtdcy.top:8443/mtdcy/pretty.nvim.git)
- [PR](https://github.com/mtdcy/pretty.nvim.git)

## Plugins

- [solarized8](https://github.com/lifepillar/vim-solarized8)@bde9cab3d
- [bufexplorer](https://github.com/jlanzarotta/bufexplorer)@7.4.26
- [NERDTree](https://github.com/preservim/nerdtree)@7.0.0
- [Tagbar](https://github.com/preservim/tagbar)@3.1.1
- [echodoc.vim](https://github.com/Shougo/echodoc.vim)@8c7e99e
- [vim-signify](https://github.com/mhinz/vim-signify/tree/master)@7d538b7
- [ALE](https://github.com/dense-analysis/ale)@3.3.0
- [deoplete.nvim](https://github.com/Shougo/deoplete.nvim)@62dd019
- [Neosnippet](https://github.com/Shougo/neosnippet.vim)@efb2a615d
  - [neosnippet-snippets](https://github.com/Shougo/neosnippet-snippets)@725c989f1
- [lightline.vim](https://github.com/itchyny/lightline.vim)@1c6b455c0
  - [lightline-ale](https://github.com/maximbaz/lightline-ale)@a861f691a
- [fugitive](https://github.com/tpope/vim-fugitive)@46eaf8918
- [Tabular](https://github.com/godlygeek/tabular)@339091ac4
- [vim-markdown](https://github.com/preservim/vim-markdown)@46add6c30

### Language Plugins

- Go: [vim-go](https://github.com/fatih/vim-go)@973279275
- Rust: [vim-racer](https://github.com/racer-rust/vim-racer)@d1aead98a

## Configurations

### ALE

- Vim
  - [vimls](https://github.com/iamcco/vim-language-server) - `npm install -g vim-language-server`
- Sh
  - [shellcheck](https://github.com/koalaman/shellcheck) - `brew install shellcheck`
  - [shfmt]() - `brew install shfmt`
- Go
  - [go]()
  - [gopls]() - `go install golang.org/x/tools/gopls@latest`
  - [goimports]() - `go install golang.org/x/tools/cmd/goimports@latest`
- Rust
  - [cargo]()
  - [racer]()
  - [rustfmt]() - `cargo install rustfmt`
- C/C++
  - [gcc]() or [clang]()
  - [clang-format]() - `npm install -g clang-format` - [参数](https://clang.llvm.org/docs/ClangFormatStyleOptions.html)
- CMake
  - [cmakelint]() - `pip3 install cmakelint`
  - [cmake-format]() - `pip3 install cmake-format`
- Dockerfile
  - [haoolint](https://github.com/hadolint/hadolint) - `brew install hadolint`
  - [dprint](https://dprint.dev/) - `npm install -g dprint`
- Html
  - [htmlhint](https://github.com/htmlhint/HTMLHint) - `npm install -g htmlhint`
  - [tidy]() - `brew install tidy-html5`
- Java
  - [javac]()
  - [clang-format]()
- JavaScript
  - [eslint]() - `npm install -g eslint`
- Json
  - [jsonlint](https://github.com/zaach/jsonlint) - `npm install -g jsonlint`
  - [clang-format]()
- Markdown
  - [markdownlint](https://github.com/DavidAnson/markdownlint-cli2) - `npm install -g markdownlint-cli2`
  - [prettier](https://prettier.io/) - `npm install -g prettier`
- Yaml
  - [yamllint](https://github.com/adrienverge/yamllint) - `pip3 install yamllint`
  - [yamlfix](https://github.com/lyz-code/yamlfix) - `pip3 install yamlfix`
- Python
  - [pylint]() - `pip3 install pylint`
  - [autopep8](https://pypi.org/project/autopep8) - `pip3 install autopep8`
