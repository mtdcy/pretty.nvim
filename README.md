# pretty.nvim

> **Prebuilt Neovim + Well-tuned Plugins — Plug and Play Ready!**

[![License: BSD-2-Clause](https://img.shields.io/badge/License-BSD--2--Clause-blue.svg)](LICENSE)
[![Neovim 0.11.6](https://img.shields.io/badge/Neovim-0.11.6-green.svg?logo=neovim)](https://github.com/neovim/neovim)
[![AI Powered](https://img.shields.io/badge/AI-Powered-purple.svg?logo=openai)](https://github.com/olimorris/codecompanion.nvim)
[![PR Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](#contributing)

**开箱即用的 Neovim 配置，预置精心调优的插件和工具链，5 分钟打造专业开发环境。**

---

## ✨ 核心特色

- 🤖 **AI 驱动** — CodeCompanion 集成，支持OpenAI 兼容 API
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

### 🤖 AI 功能

| 快捷键 | 功能 | 模式 |
|--------|------|------|
| `<leader>ai` | AI 行内模式（选中代码后使用，支持范围操作） | n, v |
| `F5` | AI 对话模式（打开/关闭聊天窗口） | n |
| `Enter` | 发送消息/确认选择 | n, i（对话窗口内） |
| `Shift+Enter` | 换行输入 | i（对话窗口内） |

### 🔍 Finder/搜索

| 快捷键 | 功能 | 模式 |
|--------|------|------|
| `C-o` | 打开文件搜索 | n, i |
| `C-e` | 打开缓冲区列表 | n, i |
| `C-g` | 全局项目关键词搜索 | n, i |
| **Finder窗口内操作** | --- | --- |
| `j/k/⬆/⬇` | 上下移动选择 | n |
| `Enter` | 打开选中项 | n |
| `p` | 切换预览窗口显示/隐藏 | n |
| `1-9` | 快速选择第1-9个条目 | n |
| `Q/q` | 关闭Finder窗口 | n |

### 🪟 窗口管理

| 快捷键 | 功能 | 模式 |
|--------|------|------|
| `F8` | 代码格式化 | n, i |
| `F9` | 打开/关闭左侧文件树（nvim-tree） | n, i |
| `F10` | 打开/关闭右侧代码大纲（aerial） | n, i |
| `F12` | 打开LazyGit GUI | n, i |
| `C-h/j/k/l` | 快速切换窗口焦点 | n, i |
| `C-w` | 智能关闭当前窗口/缓冲区 | n, i |

### 📋 缓冲区管理

| 快捷键 | 功能 | 模式 |
|--------|------|------|
| `C-n` | 切换到下一个缓冲区 | n, i |
| `C-p` | 切换到上一个缓冲区 | n, i |
| `<leader>1-0` | 快速切换第1-10个缓冲区 | n |

### ✨ 编辑辅助

| 快捷键 | 功能 | 模式 |
|--------|------|------|
| `Tab` | 选择下一个补全候选/触发补全 | i, c |
| `Enter` | 确认补全/提交命令 | i, c |
| `/` | 选中代码一键对齐（Tabular） | v |

### 🔖 代码跳转

| 快捷键 | 功能 | 模式 |
|--------|------|------|
| `gd` | 跳转到变量/函数定义 | n |
| `gb` | 返回上一个跳转位置 | n |
| `gk` | 查看光标处代码文档 | n |
| `ge` | 跳转到下一个错误/警告位置 | n |
| `gg` | 跳转到文件首行 | n |
| `gG` | 跳转到文件末行 | n |
| `g[` / `g]` | 跳转到代码块开始/结束 | n |

**模式说明**: `n`=普通模式, `i`=插入模式, `v`=可视模式, `c`=命令行模式, `t`=终端模式

---

## 🤖 AI 功能

> 💡 **AI Powered**: 集成 CodeCompanion.nvim，让你的编辑器拥有 AI 编程能力！

### 快速开始

**1. 配置环境变量**（`~/.zshrc` 或 `~/.bashrc`）

```bash
export AICODING_BASE_URL="https://coding.dashscope.aliyuncs.com/v1"  # 阿里云百炼
export AICODING_API_KEY="sk-your-api-key-here"                       # 你的 API Key
export AICODING_MODEL="qwen3-coder-next"                             # 可选：指定模型
```

**2. 重启终端** 或执行 `source ~/.zshrc`

**3. 在 Neovim 中使用**

| 场景 | 操作 |
|------|------|
| **对话模式** | 按 `F5` 打开聊天窗口，直接提问 |
| **行内模式** | 选中代码 → 按 `<leader>ai` → 输入指令 |
| **自动上下文** | 自动包含当前文件内容，无需手动添加 |

**示例**：
```
# 对话模式
F5 → "这个函数有什么优化空间？"

# 行内模式
选中代码 → ;ai → "添加错误处理"
```

**按键说明**：
| 按键 | 功能 | 说明 |
|------|------|------|
| `Enter` | 发送消息 | 在聊天窗口输入后按 Enter 发送 |
| `Shift+Enter` | 换行 | 输入多行内容时使用 |

---

## 🔌 内置插件

### 🤖 AI 编程
- [codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim) — AI 编程助手，兼容OpenAI/阿里云百炼等API

### 🎨 主题与UI
- [solarized8](https://github.com/lifepillar/vim-solarized8) — 经典 Solarized 护眼配色
- [noice.nvim](https://github.com/folke/noice.nvim) — 命令行/通知/消息美化接管
- [nvim-notify](https://github.com/rcarriga/nvim-notify) — 优雅的通知弹窗
- [nui.nvim](https://github.com/MunifTanjim/nui.nvim) — 统一UI组件库（noice/telescope依赖）

### 📂 文件与搜索
- [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) — 轻量高性能文件树
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) — 全功能模糊搜索（文件/缓冲区/代码搜索等
  - [telescope-fzy-native.nvim](https://github.com/nvim-telescope/telescope-fzy-native.nvim) — fzy原生高速排序扩展
  - [telescope-lazygit.nvim](https://github.com/kdheepak/lazygit.nvim) — LazyGit集成扩展
  - [telescope-nerdy](https://github.com/2kabhishek/nerdy.nvim) — 图标搜索扩展
  - [telescope-emoji](https://github.com/nvim-telescope/telescope-emoji.nvim) — 表情搜索扩展

### 📝 代码导航与补全
- [aerial.nvim](https://github.com/stevearc/aerial.nvim) — 结构化代码大纲/符号列表
- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) — 高性能自动补全框架
  - [cmp-omni](https://github.com/hrsh7th/cmp-omni) — OmniFunc补全源（ALE LSP补全）
  - [cmp-buffer](https://github.com/hrsh7th/cmp-buffer) — 缓冲区内容补全源
  - [cmp-path](https://github.com/hrsh7th/cmp-path) — 路径补全源
  - [cmp-cmdline](https://github.com/hrsh7th/cmp-cmdline) — 命令行补全源

### ✅ 代码质量
- [ALE](https://github.com/dense-analysis/ale) — 异步代码检查/自动修复，支持50+编程语言

### 🔀 版本控制
- [lazygit.nvim](https://github.com/kdheepak/lazygit.nvim) — 全功能Git GUI集成
- [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) — 行级Git变更标记

### 🛠️ 实用工具
- [rainbow](https://github.com/luochen1990/rainbow) — 彩虹括号高亮
- [Tabular](https://github.com/godlygeek/tabular) — 一键代码对齐
- [nerdcommenter](https://github.com/preservim/nerdcommenter) — 快速注释/取消注释
- [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) — 统一文件/符号图标支持

### 添加插件

本项目不使用插件管理器，直接通过 Git 合并：

```bash
# 添加新插件
git remote add bufexplorer https://github.com/jlanzarotta/bufexplorer.git
git fetch bufexplorer
git merge bufexplorer/master --allow-unrelated-histories --no-commit --squash
git checkout HEAD -- README.md .gitignore   # 保留当前文件
git mv LICENSE LICENSE.bufexplorer          # 保留插件许可证
git rm -rf <不需要的文件>                    # 删除不需要的文件
vim README.md                               # 更新说明
git commit -m "merged bufexplorer"
git push origin main

# 删除插件
git revert <commit-hash>
```

---

---

## 🛠️ 语言支持配置

### Vim
- **vim-language-server** — `npm install vim-language-server`
- **vint** — `pip3 install vim-vint`
- 配置文件：[.vintrc.yaml](.vintrc.yaml)

### Shell
- **shellcheck** — `pip3 install shellcheck-py`
- 配置文件：[lintrc/shellcheckrc](lintrc/shellcheckrc)

### Go
- **gopls** — `go install golang.org/x/tools/gopls@latest`
- **gofmt** — 内置
- **goimports** — `go install golang.org/x/tools/cmd/goimports@latest`

### Rust
- **rust-analyzer** — `rustup component add rust-analyzer`
- **rustfmt** — `rustup component add rustfmt`
- 配置文件：`.rustfmt.toml`

### C/C++
- **ccls** — 需要编译安装
- **clang-format** — `pip3 install clang-format`
- 配置文件：`.ccls`

### Python
- **jedi-language-server** — `pip3 install jedi-language-server`
- **pylint** — `pip3 install pylint`
- **flake8** — `pip3 install flake8`
- **black** — `pip3 install black`
- 配置文件：
  - [lintrc/pylintrc](lintrc/pylintrc)
  - [lintrc/flake8](lintrc/flake8)
  - [lintrc/black.toml](lintrc/black.toml)

### JavaScript/TypeScript
- **tsserver** — `npm install typescript`
- **eslint** — `npm install eslint`
- **prettier** — `npm install prettier`
- 配置文件：
  - [lintrc/eslintrc](lintrc/eslintrc)
  - [lintrc/prettierrc](https://prettier.io/docs/configuration)

### Markdown
- **markdownlint** — `npm install markdownlint-cli`
- 配置文件：[lintrc/markdownlint.yaml](lintrc/markdownlint.yaml)

### YAML
- **yamllint** — `pip3 install yamllint`
- **yamlfix** — `pip3 install yamlfix`
- 配置文件：
  - [lintrc/yamllint.yaml](lintrc/yamllint.yaml)
  - [lintrc/yamlfix.toml](lintrc/yamlfix.toml)

### Lua
- **lua-language-server** — 建议从源码编译
- **luacheck** — `luarocks install luacheck lanes`
- 配置文件：
  - [lintrc/luarc.json](lintrc/luarc.json)
  - [lintrc/luacheckrc](lintrc/luacheckrc)

### 快速安装所有依赖

```bash
# 设置国内镜像 (可选)
npm config set registry https://mirrors.mtdcy.top/npmjs

# 安装 Node.js 依赖
npm install

# 安装 Python 依赖 (在 nvim 中自动完成)
nvim --update
```

---

## 📄 许可证

- 本项目顶级文件使用 [BSD-2-Clause](LICENSE) 许可证
- 合并自其他项目的文件遵循其原有许可证
- 详见各 `LICENSE.*` 文件

---

## 👤 作者

**Chen Fang**
- GitHub: [@mtdcy](https://github.com/mtdcy)
- Email: mtdcy.chen@gmail.com

---

## 🙏 致谢

感谢所有开源插件的作者和维护者！pretty.nvim 站在巨人的肩膀上。

---

<div align="center">

**如果这个项目对你有帮助，请给一个 ⭐ Star！**

Made with ❤️ by Chen Fang

</div>
