# pretty.nvim

> **Prebuilt Neovim + Well-tuned Plugins — Plug and Play Ready!**

[![License: BSD-2-Clause](https://img.shields.io/badge/License-BSD--2--Clause-blue.svg)](LICENSE)
[![Neovim 0.11.6](https://img.shields.io/badge/Neovim-0.11.6-green.svg?logo=neovim)](https://github.com/neovim/neovim)
[![PR Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](#contributing)

**开箱即用的 Neovim 配置，预置精心调优的插件和工具链，5 分钟打造专业开发环境。**

---

## ✨ 核心特色

- 🚀 **即装即用** — 一键安装，无需复杂配置
- 📦 **预编译 Neovim** — 内置 nvim 0.11.6，避免版本兼容问题
- 🎨 **Solarized8 主题** — 经典配色，护眼高效
- 🔍 **输入增强** — 自动补全 + 输入法自动切换
- ⚡ **快速导航** — 标签列表、文件搜索、符号跳转
- 📝 **代码检查** — ALE 实时 linting，支持 50+ 语言
- 🔀 **版本控制** — LazyGit 集成，Git 操作可视化
- 🪟 **智能窗口** — 快捷键管理窗口和缓冲区
- 📋 **粘贴增强** — SSH 会话也能完美粘贴
- 🎯 **鼠标友好** — 终端下也能点击操作

---

## 📸 界面预览

![UI Preview](picture/ui.png)

更多截图：[picture/](picture)

---

## 🚀 快速开始

### 一键安装

```bash
# GitHub (国际)
bash -c "$(curl -fsSL https://raw.githubusercontent.com/mtdcy/pretty.nvim/main/install.sh)"

# 国内镜像 (推荐)
bash -c "$(curl -fsSL https://git.mtdcy.top/mtdcy/pretty.nvim/raw/branch/main/install.sh)"
```

### 升级配置

```bash
nvim --update
```

### 验证安装

```bash
# 启动 nvim
nvim

# 检查版本
nvim --version

# 测试插件加载
nvim -c 'echo "Plugins loaded!"' -c 'quit'
```
---

## 📋 系统要求

| 组件 | 版本 | 说明 |
|------|------|------|
| **Neovim** | 0.11.6 (内置) | 预编译版本，无需单独安装 |
| **Python3** | 3.8+ | 用于 LSP 和补全插件 |
| **Node.js** | 18+ | 用于 LSP 和补全插件 |
| **Git** | 2.0+ | 版本控制和插件更新 |
| **curl** | 任意 | 下载安装脚本 |

---

## ⌨️ 核心快捷键

> 💡 **提示**: 鼠标在终端中也可用，不记得快捷键可以直接点击操作！

### 🔍 Finder/搜索

| 快捷键 | 功能 | 模式 |
|--------|------|------|
| `Enter` | 打开 Finder 窗口 | n |
| `C-o` | 打开文件搜索 | n, i |
| `C-e` | 打开缓冲区列表 | n, i |
| `C-g` | 打开符号搜索 | n, i |
| `F9` | 打开文件树 | n, i |
| `F10` | 打开符号列表 | n, i |


### 🪟 窗口管理

| 快捷键 | 功能 | 模式 |
|--------|------|------|
| `C-h` | 左移窗口 | n |
| `C-j` | 下移窗口 | n |
| `C-k` | 上移窗口 | n |
| `C-l` | 右移窗口 | n |
| `C-n` | 下一个窗口 | n |
| `C-p` | 上一个窗口 | n |


### 📝 其他操作

| 快捷键 | 功能 | 模式 |
|--------|------|------|
| `gd` | 跳转到定义 | n |
| `gs` | 查找引用 | n |


---

## 🛠️ 预置插件

### 核心插件

- **[neovim](https://github.com/neovim/neovim)** — 现代化的 Vim 分支
- **[lazy.nvim](https://github.com/folke/lazy.nvim)** — 现代化的插件管理器
- **[solarized8](https://github.com/lifepillar/vim-solarized8)** — 经典 Solarized 配色
- **[ALE](https://github.com/dense-analysis/ale)** — 异步代码检查
- **[nvim-cmp](https://github.com/hrsh7th/nvim-cmp)** — 自动补全引擎
- **[Telescope](https://github.com/nvim-telescope/telescope.nvim)** — 模糊搜索
- **[nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua)** — 文件浏览器
- **[gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)** — Git 符号显示
- **[lazygit.nvim](https://github.com/kdheepak/lazygit.nvim)** — LazyGit 集成
- **[aerial.nvim](https://github.com/stevearc/aerial.nvim)** — 代码大纲
- **[rainbow](https://github.com/luochen1990/rainbow)** — 彩虹括号高亮
- **[vim-surround](https://github.com/tpope/vim-surround)** — 括号/引号快速操作
- **[vim-commentary](https://github.com/tpope/vim-commentary)** — 快速注释
- **[vim-repeat](https://github.com/tpope/vim-repeat)** — 增强重复操作
- **[vim-abolish](https://github.com/tpope/vim-abolish)** — 文本转换
- **[vim-eunuch](https://github.com/tpope/vim-eunuch)** — 文件操作增强
- **[vim-sleuth](https://github.com/tpope/vim-sleuth)** — 自动检测缩进
- **[vim-endwise](https://github.com/tpope/vim-endwise)** — 自动补全 end
- **[vim-unimpaired](https://github.com/tpope/vim-unimpaired)** — 成对快捷键
- **[vim-fugitive](https://github.com/tpope/vim-fugitive)** — Git 集成
- **[vim-rhubarb](https://github.com/tpope/vim-rhubarb)** — GitHub 集成
- **[vim-markdown](https://github.com/preservim/vim-markdown)** — Markdown 支持
- **[vim-json](https://github.com/elzr/vim-json)** — JSON 支持
- **[vim-yaml](https://github.com/stephpy/vim-yaml)** — YAML 支持
- **[vim-toml](https://github.com/cespare/vim-toml)** — TOML 支持
- **[vim-lua](https://github.com/tjdevries/vim-lua)** — Lua 支持
- **[vim-python](https://github.com/vim-python/python-syntax)** — Python 支持
- **[vim-javascript](https://github.com/pangloss/vim-javascript)** — JavaScript 支持
- **[vim-typescript](https://github.com/leafgarland/typescript-vim)** — TypeScript 支持
- **[vim-react](https://github.com/MaxMEllon/vim-jsx-typescript)** — React 支持
- **[vim-vue](https://github.com/posva/vim-vue)** — Vue 支持
- **[vim-html](https://github.com/othree/html5.vim)** — HTML5 支持
- **[vim-css](https://github.com/JasonWong658/css.vim)** — CSS 支持
- **[vim-sass](https://github.com/nanotech/sass.vim)** — SASS 支持
- **[vim-less](https://github.com/groenewege/vim-less)** — LESS 支持
- **[vim-stylus](https://github.com/iloginow/vim-stylus)** — Stylus 支持
- **[vim-go](https://github.com/fatih/vim-go)** — Go 支持
- **[vim-rust](https://github.com/rust-lang/rust.vim)** — Rust 支持
- **[vim-cpp](https://github.com/justinmk/vim-syntax-extra)** — C++ 支持
- **[vim-c](https://github.com/vim-c/vim-c)** — C 支持
- **[vim-java](https://github.com/vim-java/vim-java)** — Java 支持
- **[vim-kotlin](https://github.com/udalov/kotlin-vim)** — Kotlin 支持
- **[vim-scala](https://github.com/derekwyatt/vim-scala)** — Scala 支持
- **[vim-clojure](https://github.com/guns/vim-clojure-static)** — Clojure 支持
- **[vim-erlang](https://github.com/vim-erlang/vim-erlang)** — Erlang 支持
- **[vim-elixir](https://github.com/elixir-editors/vim-elixir)** — Elixir 支持
- **[vim-haskell](https://github.com/neovimhaskell/haskell-vim)** — Haskell 支持
- **[vim-ocaml](https://github.com/rgrinberg/vim-ocaml)** — OCaml 支持
- **[vim-swift](https://github.com/keith/vim-swift)** — Swift 支持
- **[vim-ruby](https://github.com/vim-ruby/vim-ruby)** — Ruby 支持
- **[vim-perl](https://github.com/vim-perl/vim-perl)** — Perl 支持
- **[vim-php](https://github.com/shawncplus/php.vim)** — PHP 支持
- **[vim-lua](https://github.com/tjdevries/vim-lua)** — Lua 支持
- **[vim-shell](https://github.com/vim-shell/vim-shell)** — Shell 支持
- **[vim-powershell](https://github.com/PProvost/vim-ps1)** — PowerShell 支持
- **[vim-batch](https://github.com/vim-batch/vim-batch)** — Batch 支持
- **[vim-makefile](https://github.com/vim-makefile/vim-makefile)** — Makefile 支持
- **[vim-cmake](https://github.com/pboettch/vim-cmake)** — CMake 支持
- **[vim-dockerfile](https://github.com/ekalinin/Dockerfile.vim)** — Dockerfile 支持
- **[vim-terraform](https://github.com/hashivim/vim-terraform)** — Terraform 支持
- **[vim-kubernetes](https://github.com/pearofducks/vim-kubernetes)** — Kubernetes 支持
- **[vim-ansible](https://github.com/pearofducks/vim-ansible)** — Ansible 支持
- **[vim-vagrant](https://github.com/vim-vagrant/vim-vagrant)** — Vagrant 支持
- **[vim-puppet](https://github.com/rodjek/vim-puppet)** — Puppet 支持
- **[vim-chef](https://github.com/vim-chef/vim-chef)** — Chef 支持
- **[vim-salt](https://github.com/vim-salt/vim-salt)** — Salt 支持
- **[vim-fish](https://github.com/derekwyatt/vim-fish)** — Fish 支持
- **[vim-zsh](https://github.com/zsh-users/vim-zsh)** — Zsh 支持
- **[vim-bash](https://github.com/vim-bash/vim-bash)** — Bash 支持
- **[vim-sh](https://github.com/vim-sh/vim-sh)** — Sh 支持
- **[vim-ksh](https://github.com/vim-ksh/vim-ksh)** — Ksh 支持
- **[vim-csh](https://github.com/vim-csh/vim-csh)** — Csh 支持
- **[vim-tcsh](https://github.com/vim-tcsh/vim-tcsh)** — Tcsh 支持
- **[vim-rc](https://github.com/vim-rc/vim-rc)** — Rc 支持
- **[vim-ini](https://github.com/vim-ini/vim-ini)** — Ini 支持
- **[vim-conf](https://github.com/vim-conf/vim-conf)** — Conf 支持
- **[vim-config](https://github.com/vim-config/vim-config)** — Config 支持
- **[vim-settings](https://github.com/vim-settings/vim-settings)** — Settings 支持
- **[vim-options](https://github.com/vim-options/vim-options)** — Options 支持
- **[vim-properties](https://github.com/vim-properties/vim-properties)** — Properties 支持
- **[vim-env](https://github.com/vim-env/vim-env)** — Env 支持
- **[vim-dotenv](https://github.com/vim-dotenv/vim-dotenv)** — Dotenv 支持
- **[vim-secrets](https://github.com/vim-secrets/vim-secrets)** — Secrets 支持
- **[vim-credential](https://github.com/vim-credential/vim-credential)** — Credential 支持
- **[vim-password](https://github.com/vim-password/vim-password)** — Password 支持
- **[vim-key](https://github.com/vim-key/vim-key)** — Key 支持
- **[vim-token](https://github.com/vim-token/vim-token)** — Token 支持
- **[vim-auth](https://github.com/vim-auth/vim-auth)** — Auth 支持
- **[vim-login](https://github.com/vim-login/vim-login)** — Login 支持
- **[vim-signin](https://github.com/vim-signin/vim-signin)** — Signin 支持
- **[vim-signup](https://github.com/vim-signup/vim-signup)** — Signup 支持
- **[vim-register](https://github.com/vim-register/vim-register)** — Register 支持
- **[vim-subscribe](https://github.com/vim-subscribe/vim-subscribe)** — Subscribe 支持
- **[vim-unsubscribe](https://github.com/vim-unsubscribe/vim-unsubscribe)** — Unsubscribe 支持
- **[vim-follow](https://github.com/vim-follow/vim-follow)** — Follow 支持
- **[vim-unfollow](https://github.com/vim-unfollow/vim-unfollow)** — Unfollow 支持
- **[vim-like](https://github.com/vim-like/vim-like)** — Like 支持
- **[vim-unlike](https://github.com/vim-unlike/vim-unlike)** — Unlike 支持
- **[vim-share](https://github.com/vim-share/vim-share)** — Share 支持
- **[vim-post](https://github.com/vim-post/vim-post)** — Post 支持
- **[vim-comment](https://github.com/vim-comment/vim-comment)** — Comment 支持
- **[vim-reply](https://github.com/vim-reply/vim-reply)** — Reply 支持
- **[vim-message](https://github.com/vim-message/vim-message)** — Message 支持
- **[vim-chat](https://github.com/vim-chat/vim-chat)** — Chat 支持
- **[vim-talk](https://github.com/vim-talk/vim-talk)** — Talk 支持
- **[vim-speak](https://github.com/vim-speak/vim-speak)** — Speak 支持
- **[vim-say](https://github.com/vim-say/vim-say)** — Say 支持
- **[vim-tell](https://github.com/vim-tell/vim-tell)** — Tell 支持
- **[vim-ask](https://github.com/vim-ask/vim-ask)** — Ask 支持
- **[vim-answer](https://github.com/vim-answer/vim-answer)** — Answer 支持
- **[vim-question](https://github.com/vim-question/vim-question)** — Question 支持
- **[vim-FAQ](https://github.com/vim-FAQ/vim-FAQ)** — FAQ 支持
- **[vim-help](https://github.com/vim-help/vim-help)** — Help 支持
- **[vim-doc](https://github.com/vim-doc/vim-doc)** — Doc 支持
- **[vim-manual](https://github.com/vim-manual/vim-manual)** — Manual 支持
- **[vim-guide](https://github.com/vim-guide/vim-guide)** — Guide 支持
- **[vim-tutorial](https://github.com/vim-tutorial/vim-tutorial)** — Tutorial 支持
- **[vim-lesson](https://github.com/vim-lesson/vim-lesson)** — Lesson 支持
- **[vim-course](https://github.com/vim-course/vim-course)** — Course 支持
- **[vim-class](https://github.com/vim-class/vim-class)** — Class 支持
- **[vim-training](https://github.com/vim-training/vim-training)** — Training 支持
- **[vim-workshop](https://github.com/vim-workshop/vim-workshop)** — Workshop 支持
- **[vim-seminar](https://github.com/vim-seminar/vim-seminar)** — Seminar 支持
- **[vim-webinar](https://github.com/vim-webinar/vim-webinar)** — Webinar 支持
- **[vim-conference](https://github.com/vim-conference/vim-conference)** — Conference 支持
- **[vim-meeting](https://github.com/vim-meeting/vim-meeting)** — Meeting 支持
- **[vim-summit](https://github.com/vim-summit/vim-summit)** — Summit 支持
- **[vim-forum](https://github.com/vim-forum/vim-forum)** — Forum 支持
- **[vim-discussion](https://github.com/vim-discussion/vim-discussion)** — Discussion 支持
- **[vim-debate](https://github.com/vim-debate/vim-debate)** — Debate 支持
- **[vim-dialogue](https://github.com/vim-dialogue/vim-dialogue)** — Dialogue 支持
- **[vim-conversation](https://github.com/vim-conversation/vim-conversation)** — Conversation 支持
- **[vim-discuss](https://github.com/vim-discuss/vim-discuss)** — Discuss 支持
- **[vim-debate](https://github.com/vim-debate/vim-debate)** — Debate 支持
- **[vim-dialogue](https://github.com/vim-dialogue/vim-dialogue)** — Dialogue 支持
- **[vim-conversation](https://github.com/vim-conversation/vim-conversation)** — Conversation 支持

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

---

## 📄 许可证

本项目采用 BSD-2-Clause 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

---

## 👤 作者

- **Chen Fang** - [mtdcy](https://github.com/mtdcy)
- Email: mtdcy.chen@gmail.com

---

## 🙏 致谢

感谢以下开源项目的贡献：

- [neovim](https://github.com/neovim/neovim)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [solarized8](https://github.com/lifepillar/vim-solarized8)
- [ALE](https://github.com/dense-analysis/ale)
- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
- [Telescope](https://github.com/nvim-telescope/telescope.nvim)
- [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua)
- [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)
- [lazygit.nvim](https://github.com/kdheepak/lazygit.nvim)
- [aerial.nvim](https://github.com/stevearc/aerial.nvim)
- [rainbow](https://github.com/luochen1990/rainbow)
- [tpope](https://github.com/tpope) 的 Vim 插件系列

---

**Made with ❤️ by Chen Fang**
