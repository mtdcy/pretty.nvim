# PROJECT.md - pretty.nvim 项目说明

> **重要**: 本文件描述 pretty.nvim 项目的结构和组成，帮助 AI 助手理解项目范围。

---

## 📁 项目结构

### 自有文件（我们维护的代码）

```
pretty.nvim/
├── init.vim              # 主配置文件（入口）
├── README.md             # 项目文档
├── install.sh            # 安装脚本
├── run                   # 运行脚本
├── cmdlets.sh            # 命令行工具
├── .editorconfig         # 编辑器配置
├── .gitignore            # Git 忽略规则
├── .vintrc.yaml          # Vim lint 配置
├── .flake8               # Python lint 配置
├── package.json          # Node.js 依赖
├── package-lock.json     # Node.js 依赖锁定
├── requirements.txt      # Python 依赖
├── lazygit.yml           # LazyGit 配置
├── gitconfig             # Git 配置
│
├── init/                 # 初始化配置（我们的核心配置）
│   ├── ai.vim            # AI 功能配置
│   ├── codecompanion.lua # CodeCompanion 配置
│   ├── neoai.lua         # NeoAI 配置
│   ├── completion.vim    # 补全配置
│   ├── explorer.vim      # 文件浏览器配置
│   ├── menu.vim          # 菜单配置
│   ├── misc.vim          # 杂项配置
│   ├── tab.vim           # 标签页配置
│   ├── taglist.vim       # 标签列表配置
│   ├── ui.vim            # UI 配置
│   ├── vcs.vim           # 版本控制配置
│   └── wm.vim            # 窗口管理配置
│
├── init/                 # 初始化脚本目录
├── scripts/              # 自有脚本
├── lazygit/              # LazyGit 配置
├── lintrc/               # Lint 配置
├── .github/              # GitHub 配置
├── patches/              # 第三方插件修改补丁（重要！）
│   └── neoai-openai-base-url.patch  # neoai 支持自定义 base_url
│
└── LICENSE.*             # 第三方插件许可证（保留但不由我们维护）
```

---

### 第三方插件目录（原则上不修改）

**例外情况**：如果第三方插件有 bug 或需要增强，按以下流程处理：

1. **修改插件代码** - 临时修改 `lua/`、`plugin/` 等目录的源码
2. **生成 patch** - `git diff lua/path/to/file.lua > patches/plugin-name-fix.patch`
3. **记录说明** - 在 PROJECT.md 中记录修改原因和 patch 文件名
4. **更新应用** - 更新插件后，应用 patch：`git apply patches/plugin-name-fix.patch`

**当前 patch 列表**：
- `patches/neoai-openai-base-url.patch` - neoai 支持自定义 base_url（阿里云百炼等 OpenAI 兼容 API）

---

### 第三方插件目录（默认不修改）

```
pretty.nvim/
├── lua/                  # Lua 插件代码（第三方）
│   ├── ale/              # ALE 插件
│   ├── codecompanion/    # CodeCompanion 插件
│   ├── neoai/            # NeoAI 插件（第三方）
│   ├── dotenv.lua        # dotenv 插件
│   ├── lazygit.lua       # LazyGit 插件
│   ├── plenary/          # Plenary 插件
│   └── ...
│
├── ale_linters/          # ALE Linters（149 个语言支持）
├── autoload/             # 自动加载函数（第三方）
├── colors/               # 配色方案（第三方）
├── data/                 # 数据文件（第三方）
├── doc/                  # 文档（第三方）
├── ftdetect/             # 文件类型检测（第三方）
├── ftplugin/             # 文件类型插件（第三方）
├── indent/               # 缩进配置（第三方）
├── neosnippets/          # Neosnippet 片段（第三方）
├── nerdtree_plugin/      # NERDTree 插件（第三方）
├── node_modules/         # Node.js 依赖（第三方）
├── plugin/               # 插件主目录（第三方）
├── prebuilts/            # 预编译 Neovim（第三方）
├── py3env/               # Python 环境（第三方）
├── python3/              # Python3 插件（第三方）
├── pythonx/              # PythonX 插件（第三方）
├── queries/              # Treesitter 查询（第三方）
├── rplugin/              # 远程插件（第三方）
├── syntax/               # 语法高亮（第三方）
│
└── picture/              # 界面截图（资源文件）
```

---

## 🎯 AI 助手工作指南

### 项目范围

**可以修改**:
- ✅ `init.vim` - 主配置文件
- ✅ `init/*.vim` 和 `init/*.lua` - 初始化配置
- ✅ `scripts/*` - 自有脚本
- ✅ `README.md` - 项目文档
- ✅ `install.sh` - 安装脚本
- ✅ `.github/*` - GitHub 配置

**不要修改**:
- ❌ `lua/` - 第三方 Lua 插件代码
- ❌ `ale_linters/` - ALE 语言支持
- ❌ `autoload/` - 第三方自动加载函数
- ❌ `plugin/` - 第三方插件
- ❌ `prebuilts/` - 预编译 Neovim
- ❌ `py3env/` - Python 环境
- ❌ `node_modules/` - Node.js 依赖
- ❌ 所有 `LICENSE.*` 文件（只读）

---

### 开发原则

1. **VimScript 优先** - 能用 VimScript 就不用 Lua
2. **配置和功能分离** - 配置是配置，功能实现是功能实现
3. **不修改第三方插件** - lua/、plugin/ 等目录由插件自己维护
4. **简洁至上** - 不必要的功能就删除
5. **专业工具做专业事** - Inline 模式完全交给 AI 插件处理

---

## 📦 依赖管理

### Node.js 依赖

```bash
# 安装
npm install

# 位置
pretty.nvim/node_modules/
```

### Python 依赖

```bash
# 安装
pip install -r requirements.txt

# 位置
pretty.nvim/py3env/
```

### 预编译 Neovim

```
位置：pretty.nvim/prebuilts/
版本：Neovim 0.10.4
```

---

## 🔧 开发流程

### 添加新功能

1. 在 `init/` 目录创建配置文件
2. 在 `init.vim` 中加载配置
3. 测试功能
4. 更新 `README.md`
5. Git 提交（不推送）

### 修改现有功能

1. 定位到 `init/` 目录的对应文件
2. 修改配置或功能实现
3. 测试功能
4. Git 提交（不推送）

### 安装新插件

1. 将插件代码放到对应目录（`lua/`、`plugin/` 等）
2. 在 `init.vim` 或 `init/*.vim` 中加载插件
3. 添加依赖到 `package.json` 或 `requirements.txt`
4. 运行 `npm install` 或 `pip install`
5. 测试插件
6. Git 提交（不推送）

### 修改第三方插件（例外流程）

1. **评估必要性** - 确认修改是必要的，且无法通过配置解决
2. **修改代码** - 临时修改插件源码
3. **生成 patch** - `git diff lua/path/to/file.lua > patches/plugin-name-fix.patch`
4. **测试功能** - 确保修改有效
5. **记录说明** - 更新 PROJECT.md 记录 patch 用途
6. **Git 提交** - 提交 patch 文件（不提交 lua/ 目录的修改）
7. **更新插件时** - 应用 patch：`git apply patches/plugin-name-fix.patch`

---

## 📝 注意事项

1. **lua/neoai/ 是第三方插件** - 不要修改其源码，只通过 `init/neoai.lua` 配置
2. **LICENSE.* 文件保留** - 即使不维护对应插件，也保留许可证文件
3. **prebuilts/ 是二进制** - 不要修改预编译的 Neovim
4. **node_modules/ 和 py3env/ 是依赖** - 通过 package.json 和 requirements.txt 管理

---

*最后更新：2026-03-16*
