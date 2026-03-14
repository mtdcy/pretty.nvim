# pretty.nvim

> **Prebuilt Neovim + Well-tuned Plugins — Plug and Play Ready!**

[![License: BSD-2-Clause](https://img.shields.io/badge/License-BSD--2--Clause-blue.svg)](LICENSE)
[![Neovim 0.10.4](https://img.shields.io/badge/Neovim-0.10.4-green.svg?logo=neovim)](https://github.com/neovim/neovim)
[![PR Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](#contributing)

**开箱即用的 Neovim 配置，预置精心调优的插件和工具链，5 分钟打造专业开发环境。**

---

## ✨ 核心特色

- 🚀 **即装即用** — 一键安装，无需复杂配置
- 📦 **预编译 Neovim** — 内置 nvim 0.10.4，避免版本兼容问题
- 🎨 **Solarized8 主题** — 经典配色，护眼高效
- 🔍 **智能补全** — deoplete + neosnippet 代码片段
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

## 🐳 Docker 部署

```bash
# GitHub (国际)
curl -fsSL https://raw.githubusercontent.com/mtdcy/Dockerfiles/main/nvim/nvim.sh | sudo tee /usr/local/bin/nvim

# 国内镜像
curl -fsSL https://git.mtdcy.top/mtdcy/Dockerfiles/raw/branch/main/nvim/nvim.sh | sudo tee /usr/local/bin/nvim

# 添加执行权限
chmod a+x /usr/local/bin/nvim
```

---

## 📋 系统要求

| 组件 | 版本 | 说明 |
|------|------|------|
| **Neovim** | 0.10.4 (内置) | 预编译版本，无需单独安装 |
| **Python3** | 3.8 - 3.12 | ⚠️ **Python 3.13 暂不支持** |
| **Node.js** | 18+ | 用于 LSP 和补全插件 |
| **Git** | 2.0+ | 版本控制和插件更新 |
| **curl** | 任意 | 下载安装脚本 |

### 为什么 Python 3.13 不支持？

部分 Python 插件（如 `pynvim`）尚未完全兼容 Python 3.13，建议：

```bash
# Ubuntu/Debian
sudo apt install python3.11 python3.11-venv

# macOS
brew install python@3.11
```

---

## ⌨️ 核心快捷键

> 💡 **提示**: 鼠标在终端中也可用，不记得快捷键可以直接点击！

### 窗口管理

| 快捷键 | 功能 | 模式 |
|--------|------|------|
| `F8` | 代码格式化 | n,i |
| `F9` | 打开文件浏览器 (左) | n,i |
| `F10` | 打开标签列表 (右) | n,i |
| `F12` | 打开 LazyGit | n,i |
| `C-h/j/k/l` | 切换焦点窗口 | n,i |
| `C-w` | 智能关闭窗口 | n,i |

### 缓冲区管理

| 快捷键 | 功能 | 模式 |
|--------|------|------|
| `C-o` | 打开文件查找器 | n,i |
| `C-e` | 缓冲区列表 | n,i |
| `C-g` | 搜索项目关键词 | n,i |
| `C-n` | 下一个缓冲区 | n,i |
| `C-p` | 上一个缓冲区 | n,i |
| `<leader>1-0` | 选择缓冲区 1-10 | n |

### 代码跳转

| 快捷键 | 功能 | 模式 |
|--------|------|------|
| `gg` | 跳转到首行 | n |
| `gG` | 跳转到末行 | n |
| `g[` / `g]` | 跳转到代码块开始/结束 | n |
| `gd` | 跳转到定义 | n |
| `gb` | 返回上一位置 | n |
| `gk` | 查看关键词文档 | n |
| `ge` | 跳转到下一个错误 | n |

### 其他实用功能

| 快捷键 | 功能 | 模式 |
|--------|------|------|
| `/` | 代码对齐 (Tabular) | v |
| `C-\` + `C-n` | Terminal 退出插入模式 | t |

**模式说明**: `n`=普通模式, `i`=插入模式, `v`=可视模式, `t`=终端模式

---

## 🔌 内置插件

### 颜色主题
- [solarized8](https://github.com/lifepillar/vim-solarized8) — 经典 Solarized 配色

### 文件浏览
- [NERDTree](https://github.com/preservim/nerdtree) — 文件树浏览
- [Denite](https://github.com/Shougo/denite.nvim) — 模糊搜索

### 代码导航
- [Tagbar](https://github.com/preservim/tagbar) — 标签/符号列表

### 状态栏
- [lightline.vim](https://github.com/itchyny/lightline.vim) — 轻量状态栏
- [lightline-bufferline](https://github.com/mengelbrecht/lightline-bufferline) — 缓冲区标签

### 代码检查
- [ALE](https://github.com/dense-analysis/ale) — 异步代码检查
- [lightline-ale](https://github.com/maximbaz/lightline-ale) — ALE 状态显示

### 代码补全
- [deoplete.nvim](https://github.com/Shougo/deoplete.nvim) — 自动补全
- [neosnippet](https://github.com/Shougo/neosnippet.vim) — 代码片段

### 版本控制
- [lazygit.nvim](https://github.com/kdheepak/lazygit.nvim) — Git GUI
- [vim-signify](https://github.com/mhinz/vim-signify) — Git 变更标记

### 实用工具
- [Tabular](https://github.com/godlygeek/tabular) — 代码对齐
- [rainbow](https://github.com/luochen1990/rainbow) — 彩虹括号
- [vim-matchtag](https://github.com/leafOfTree/vim-matchtag) — HTML 标签匹配
- [nerdcommenter](https://github.com/preservim/nerdcommenter) — 快速注释

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

## 📖 文档

- [配色方案](colorscheme.md) — Solarized8 变体说明
- [复制粘贴](copyd.md) — SSH 会话复制功能
- [缓冲区](sticky_buffer.md) — 固定缓冲区功能

---

## ❓ 常见问题

### 安装失败怎么办？

1. **检查网络连接**
   ```bash
   curl -I https://github.com
   ```

2. **检查 Python 版本**
   ```bash
   python3 --version  # 应该是 3.8 - 3.12
   ```

3. **清理后重试**
   ```bash
   rm -rf ~/.nvim
   bash -c "$(curl -fsSL https://raw.githubusercontent.com/mtdcy/pretty.nvim/main/install.sh)"
   ```

### 插件加载失败？

```bash
# 更新插件
nvim --update

# 重新构建 Python 依赖
cd ~/.nvim
rm -rf py3env
./install.sh
```

### 如何自定义配置？

在 `~/.nvim/init.vim` 基础上创建个人配置：

```vim
" 在文件末尾添加个人配置
" 你的自定义映射
nnoremap <leader>q :quit<CR>

" 你的自定义插件设置
" ...
```

### 如何贡献代码？

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 提交 Pull Request

详见 [贡献指南](#contributing)

---

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

### 提交 Issue

请提供以下信息：
- Neovim 版本 (`nvim --version`)
- 操作系统和版本
- 问题描述和复现步骤
- 错误截图或日志

### 提交 PR

1. Fork 本仓库
2. 创建特性分支
3. 确保代码通过基本测试
4. 提交 PR 并描述更改内容

### 开发环境搭建

```bash
# 克隆仓库
git clone https://github.com/mtdcy/pretty.nvim.git
cd pretty.nvim

# 安装依赖
./install.sh

# 启动开发
nvim
```

---

## 🌐 镜像站点

| 地区 | 地址 |
|------|------|
| 中国大陆 | https://git.mtdcy.top:8443/mtdcy/pretty.nvim.git |
| 全球 | https://github.com/mtdcy/pretty.nvim.git |

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
