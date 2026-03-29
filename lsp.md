# LSP 架构详解 — vim.lsp vs nvim-lspconfig vs ALE

> **最后更新**: 2026-03-29  
> **适用版本**: Neovim 0.11+

---

## 🏗️ 架构层次

```
┌─────────────────────────────────────────────────────────┐
│                    用户配置层                            │
│         (pretty.nvim / init/*.vim / init/*.lua)          │
└─────────────────────────────────────────────────────────┘
                            │
            ┌───────────────┼───────────────┐
            │               │               │
            ▼               ▼               ▼
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│    vim.lsp       │  │  nvim-lspconfig  │  │       ALE        │
│  (Neovim 内置)   │  │  (配置辅助插件)   │  │  (独立 LSP 客户端)  │
└──────────────────┘  └──────────────────┘  └──────────────────┘
            │               │               │
            └───────────────┼───────────────┘
                            │
                            ▼
            ┌───────────────────────────────┐
            │      LSP Server 进程           │
            │  (lua-language-server, gopls)  │
            └───────────────────────────────┘
```

---

## 📚 三者详细对比

### 1️⃣ **vim.lsp** — Neovim 内置 LSP 客户端

**身份**: Neovim 0.5+ 内置的核心模块

**职责**:
- ✅ 提供 LSP 协议的底层实现
- ✅ 管理 LSP 连接（启动/停止/通信）
- ✅ 提供 API 供插件调用

**核心 API**:
```lua
vim.lsp.start(config)           -- 启动 LSP 服务器
vim.lsp.buf.hover()             -- 显示文档
vim.lsp.buf.definition()        -- 跳转到定义
vim.lsp.buf.references()        -- 查找引用
vim.lsp.buf.code_action()       -- 代码操作
vim.diagnostic.get()            -- 获取诊断
```

**特点**:
- 📦 **内置**: 无需安装，Neovim 自带
- 🔧 **底层**: 需要自己写配置代码
- 💪 **灵活**: 可以完全控制 LSP 行为

**配置示例**:
```lua
-- 纯 vim.lsp 配置（需要写很多代码）
local config = {
  cmd = {"/path/to/lua-language-server"},
  on_attach = function(client, bufnr)
    -- 设置按键绑定
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {buffer=bufnr})
  end,
  capabilities = vim.lsp.protocol.make_client_capabilities()
}
vim.lsp.start(config)
```

---

### 2️⃣ **nvim-lspconfig** — LSP 配置辅助插件

**身份**: 社区插件（neovim 官方维护）

**职责**:
- ✅ 预定义常见 LSP 服务器的配置
- ✅ 简化 `vim.lsp.start()` 的调用
- ✅ 自动检测 LSP 服务器安装路径

**核心功能**:
```lua
-- 使用 nvim-lspconfig 配置（简洁！）
require('lspconfig').lua_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities
})
```

**特点**:
- 📦 **插件**: 需要单独安装 (`:Lazy lspconfig`)
- 🎯 **专注**: 只做 LSP 配置，不做其他
- 🚀 **简洁**: 一行代码启动 LSP
- 🔌 **生态**: 与 `cmp-nvim-lsp`、`fidget.nvim` 等插件集成好

**不包含**:
- ❌ Linter（语法检查）
- ❌ 诊断显示（需额外配置）
- ❌ 自动补全（需配合 `nvim-cmp`）

**适合场景**:
- ✅ 重度 LSP 用户
- ✅ 需要 LSP 完整功能（重命名、Code Lens 等）
- ✅ 愿意花时间配置

---

### 3️⃣ **ALE** — 异步 Lint 引擎（独立 LSP 客户端）

**身份**: 独立插件（比 vim.lsp 更早出现）

**职责**:
- ✅ 自己的 LSP 客户端实现（不依赖 vim.lsp）
- ✅ 命令行 Linter 集成（shellcheck、pylint 等）
- ✅ 诊断显示（虚拟文本、符号、列表）
- ✅ 自动修复（`ALEFix`）

**核心功能**:
```vim
" ALE 配置（VimScript）
let g:ale_linters = { 'lua': ['lua_language_server', 'luacheck'] }
let g:ale_fix_on_save = 1
```

**特点**:
- 📦 **插件**: 需要单独安装
- 🛡️ **独立**: 不依赖 vim.lsp，自己实现 LSP 协议
- 🔍 **Lint 优先**: 专注于语法检查
- 🎨 **显示完善**: 虚拟文本、符号、列表都内置
- ⚡ **异步**: 所有检查后台运行

**LSP 功能限制**:
- ✅ 诊断、悬浮窗、补全建议
- ❌ 重命名、Code Lens、Workspace Edits

**适合场景**:
- ✅ 需要语法检查（Linting）
- ✅ 希望配置简单
- ✅ 不需要 LSP 高级功能

---

## 🔄 三者关系图

```
┌────────────────────────────────────────────────────────────┐
│                     Neovim 编辑器                          │
│                                                            │
│  ┌──────────────────────────────────────────────────────┐ │
│  │                   vim.lsp                            │ │
│  │            (内置 LSP 客户端核心)                       │ │
│  └──────────────────────────────────────────────────────┘ │
│           ▲                          ▲                     │
│           │ 调用                     │ 不使用               │
│           │                          │                     │
│  ┌────────┴──────────┐    ┌──────────┴───────────────┐    │
│  │   nvim-lspconfig  │    │           ALE            │    │
│  │  (配置辅助插件)    │    │    (独立 LSP 客户端)      │    │
│  │                   │    │                          │    │
│  │ ✅ 简化 vim.lsp   │    │ ✅ 自己实现 LSP 协议       │    │
│  │ ✅ 预定义配置     │    │ ✅ 命令行 Linter 集成      │    │
│  │ ❌ 不依赖 ALE     │    │ ❌ 不使用 vim.lsp         │    │
│  └───────────────────┘    └──────────────────────────┘    │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

---

## ⚔️ 核心区别对比表

| 特性 | vim.lsp | nvim-lspconfig | ALE |
|------|---------|----------------|-----|
| **类型** | Neovim 内置模块 | 配置辅助插件 | 独立 LSP 客户端 + Linter |
| **依赖关系** | — | 依赖 vim.lsp | 独立（不使用 vim.lsp） |
| **LSP 协议实现** | ✅ 原生 | ✅ 调用 vim.lsp | ✅ 自己实现 |
| **配置复杂度** | 高（需手写） | 低（预定义） | 中（VimScript） |
| **Linter 集成** | ❌ 需额外配置 | ❌ 需额外配置 | ✅ 内置支持 |
| **诊断显示** | ✅ vim.diagnostic | ✅ vim.diagnostic | ✅ 内置（虚拟文本/符号） |
| **自动修复** | ❌ 需 code_action | ❌ 需 code_action | ✅ ALEFix 命令 |
| **LSP 功能完整度** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **社区生态** | — | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **维护状态** | ✅ Neovim 团队 | ✅ Neovim 团队 | ⚠️ 低活跃度 |

---

## 🎯 典型配置组合

### 组合 1：vim.lsp + nvim-lspconfig（主流方案）

```lua
-- 使用 nvim-lspconfig 配置 LSP
require('lspconfig').lua_ls.setup({...})
require('lspconfig').gopls.setup({...})

-- 使用 nvim-cmp 集成补全
require('cmp_nvim_lsp').default_capabilities()

-- 使用 fidget.nvim 显示 LSP 进度
require('fidget').setup()
```

**特点**:
- ✅ LSP 功能完整
- ✅ 生态丰富
- ⚠️ 需要额外配置 Linter

---

### 组合 2：ALE（pretty.nvim 方案）

```vim
" ALE 一体化配置
let g:ale_linters = { 'lua': ['lua_language_server'], 'go': ['gopls'] }
let g:ale_fix_on_save = 1
```

**特点**:
- ✅ 配置简单
- ✅ LSP + Linter 一体化
- ⚠️ LSP 功能有限

---

### 组合 3：混用（不推荐）

```lua
-- nvim-lspconfig 处理 LSP
require('lspconfig').lua_ls.setup({...})
```

```vim
" ALE 只做 Linting
let g:ale_linters = { 'lua': ['luacheck'] }  " 不用 lua_language_server
let g:ale_lsp_suggestions = 0  " 禁用 ALE 的 LSP 补全
```

**特点**:
- ⚠️ 配置复杂
- ⚠️ 可能冲突
- ❌ 不推荐

---

## ⚠️ 常见问题

### Q1: ALE 能调用 nvim-lspconfig 配置的 LSP 吗？

**❌ 不能**。ALE 自己建立独立的 LSP 连接，无法复用 nvim-lspconfig 的连接。

如果同时配置两者，会启动**两个独立的 LSP 进程**：
- ❌ 资源浪费（CPU/内存翻倍）
- ❌ 重复提示（悬浮窗、诊断）
- ❌ 配置冲突

---

### Q2: nvim-lspconfig 依赖 vim.lsp 吗？

**✅ 依赖**。nvim-lspconfig 是 vim.lsp 的配置封装，底层调用 `vim.lsp.start()`。

---

### Q3: ALE 依赖 vim.lsp 吗？

**❌ 不依赖**。ALE 自己实现 LSP 协议，完全独立于 vim.lsp。

---

### Q4: 三者能同时用吗？

**⚠️ 能，但不推荐**。同时运行会导致：
- 资源浪费
- 诊断冲突
- 配置复杂

---

### Q5: pretty.nvim 为什么选 ALE？

- **历史原因**: ALE 配置已经完善，支持 15+ 语言
- **设计哲学**: 轻量级 + 无侵入
- **用户体验**: 开箱即用，无需复杂配置
- **性能考虑**: 避免重复进程

---

### Q6: 新项目推荐哪个？

**推荐**: `vim.lsp + nvim-lspconfig`（主流方案）

**理由**:
- ✅ 社区主流，文档丰富
- ✅ LSP 功能完整
- ✅ 生态活跃，维护良好

**如果需要 Linting**: 额外配置 `nvim-lint` 或 `none-ls.nvim`

---

## 📊 历史演进

```
2017 ──► ALE 诞生（Vim 时代，早于 vim.lsp）
         └─ 自己实现 LSP 协议

2020 ──► Neovim 0.5 发布，内置 vim.lsp
         └─ 原生 LSP 支持

2020 ──► nvim-lspconfig 诞生
         └─ 简化 vim.lsp 配置

2026 ──► 现状
         ├─ 新项目：首选 vim.lsp + nvim-lspconfig
         └─ 老项目（如 pretty.nvim）：继续用 ALE
```

---

## 📝 总结

| 问题 | 答案 |
|------|------|
| **ALE 能调用 nvim-lspconfig 配置的 LSP 吗？** | ❌ 不能，ALE 自己建立独立连接 |
| **nvim-lspconfig 依赖 vim.lsp 吗？** | ✅ 依赖，它是 vim.lsp 的配置封装 |
| **ALE 依赖 vim.lsp 吗？** | ❌ 不依赖，自己实现 LSP 协议 |
| **三者能同时用吗？** | ⚠️ 能，但不推荐（资源浪费 + 冲突） |
| **pretty.nvim 为什么选 ALE？** | 历史原因 + 配置简单 + Lint 优先 |
| **新项目推荐哪个？** | vim.lsp + nvim-lspconfig（主流） |

---

## 🔗 参考链接

---

## 🔗 LSP 客户端复用机制

> **核心原理**: Neovim 的 `vim.lsp` 是**全局 LSP 客户端管理器**，所有插件通过它访问 LSP 服务。先启动的插件创建连接，后启动的插件自动复用。

### 架构示意

```
┌────────────────────────────────────────────────────────────┐
│                    Neovim 实例                              │
│                                                            │
│  ┌──────────────────────────────────────────────────────┐ │
│  │              vim.lsp 客户端管理器                     │ │
│  │  (全局单例，管理所有 LSP 连接)                         │ │
│  └──────────────────────────────────────────────────────┘ │
│           ▲                    ▲              ▲            │
│           │                    │              │            │
│    ┌──────┴──────┐     ┌──────┴──────┐  ┌───┴────┐       │
│    │    ALE      │     │  nvim-cmp   │  │ outline  │       │
│    │  (启动 LSP) │     │  (复用 LSP) │  │ (复用)   │       │
│    │             │     │              │  │          │       │
│    │ 诊断检查    │     │ 代码补全     │  │ 符号树   │       │
│    │ 悬浮窗      │     │              │  │          │       │
│    └─────────────┘     └──────────────┘  └──────────┘       │
│                                                            │
└────────────────────────────────────────────────────────────┘
                             │
                             ▼
              ┌─────────────────────────────┐
              │   lua-language-server       │
              │   (单个进程，服务所有请求)    │
              └─────────────────────────────┘
```

---

### 复用机制详解

#### 1️⃣ **ALE 启动 LSP 的过程**

```lua
-- ALE 内部代码（简化版）
-- 当检测到 Lua 文件时，ALE 会：

local config = {
  cmd = {"lua-language-server"},
  root_dir = vim.loop.cwd(),
  filetypes = {"lua"},
  init_options = {...},
}

-- ALE 调用 vim.lsp.start() 启动 LSP 服务器
vim.lsp.start(config, {
  reuse_client = function(client, conf)
    -- 检查是否已有相同配置的客户端
    return client.config.name == conf.name
  end
})

-- 结果：lua-language-server 进程启动
-- vim.lsp 保存了这个连接的引用
```

**关键点**:
- ✅ ALE 调用 `vim.lsp.start()` 启动 LSP
- ✅ `vim.lsp` 是 Neovim 内置模块，管理所有 LSP 连接
- ✅ 连接信息保存在 `vim.lsp._clients` 中
- ✅ LSP 进程独立于 ALE 运行

---

#### 2️⃣ **nvim-cmp 复用 LSP**

```lua
-- cmp_nvim_lsp 内部代码（简化版）
local function get_lsp_clients(bufnr)
  -- 直接调用 vim.lsp.get_clients() 获取现有连接
  return vim.lsp.get_clients({ bufnr = bufnr })
end

local function request_completions(client, params)
  -- 通过现有 LSP 连接请求补全
  client.request('textDocument/completion', params, function(err, result)
    -- 返回补全项给 nvim-cmp
    callback(result)
  end, bufnr)
end

-- 当用户输入时：
-- 1. nvim-cmp 触发补全
-- 2. cmp_nvim_lsp 获取现有 LSP 客户端
-- 3. 通过 LSP 协议请求补全
-- 4. 显示补全列表
```

**关键**: `cmp_nvim_lsp` **不启动**自己的 LSP，它只是 `vim.lsp` 的包装器！

---

#### 3️⃣ **outline.nvim 复用 LSP**

```lua
-- outline.nvim 内部代码（简化版）
local function get_symbol_provider()
  -- 1. 获取当前缓冲区的 LSP 客户端
  local clients = vim.lsp.get_clients({
    bufnr = vim.api.nvim_get_current_buf(),
  })
  
  -- 2. 检查是否有可用的 LSP 客户端
  if #clients > 0 then
    -- 3. 直接使用现有的 LSP 连接！
    return clients[1]
  end
  
  -- 4. 如果没有 LSP，降级到 Treesitter/Ctags
  return nil
end

-- 请求文档符号
local function request_symbols(client, bufnr)
  client.request('textDocument/documentSymbol', {
    textDocument = vim.lsp.util.make_text_document_params(bufnr),
  }, function(err, result)
    -- 处理符号列表
    outline.render(result)
  end, bufnr)
end
```

**关键点**:
- ✅ outline 调用 `vim.lsp.get_clients()` 获取现有连接
- ✅ **不创建新的 LSP 连接**，直接复用
- ✅ 通过 LSP 协议请求 `textDocument/documentSymbol`
- ✅ 所有插件共享同一个 `lua-language-server` 进程

---

### 完整流程示例

**场景**: 打开 `main.lua` 文件

```
1. 用户打开 main.lua
   │
   ▼
2. ALE 检测到 Lua 文件类型
   │
   ▼
3. ALE 检查配置文件 (.luarc.json)
   │
   ▼
4. ALE 调用 vim.lsp.start() 启动 lua-language-server
   │
   ▼
5. vim.lsp 保存连接信息到 vim.lsp._clients
   │
   ▼
6. lua-language-server 进程运行（后台）
   │
   ▼
7. 用户输入代码，nvim-cmp 触发补全
   │
   ▼
8. cmp_nvim_lsp 调用 vim.lsp.get_clients()
   │
   ▼
9. cmp_nvim_lsp 发现已有 lua-language-server 连接
   │
   ▼
10. cmp_nvim_lsp 使用现有连接请求补全
    │
    ▼
11. lua-language-server 返回补全项
    │
    ▼
12. nvim-cmp 显示补全列表 ✅

--- (同时) ---

13. 用户按 F10 打开 outline 窗口
    │
    ▼
14. outline 调用 vim.lsp.get_clients()
    │
    ▼
15. outline 发现已有 lua-language-server 连接
    │
    ▼
16. outline 直接使用现有连接请求符号
    │
    ▼
17. lua-language-server 返回符号列表
    │
    ▼
18. outline 渲染符号树 ✅
```

**关键**: 整个流程只有**一个** `lua-language-server` 进程！

---

### 各插件的 LSP 请求类型

| 插件 | LSP 请求方法 | 用途 |
|------|-------------|------|
| **ALE** | `textDocument/publishDiagnostics` | 诊断检查 |
| **ALE** | `textDocument/definition` | 跳转定义 |
| **ALE** | `textDocument/hover` | 悬浮窗文档 |
| **ALE** | `textDocument/codeAction` | 代码修复 |
| **nvim-cmp** | `textDocument/completion` | 自动补全 |
| **nvim-cmp** | `completionItem/resolve` | 补全项详情 |
| **outline** | `textDocument/documentSymbol` | 文档符号树 |
| **aerial** | `textDocument/documentSymbol` | 代码大纲 |
| **telescope** | `textDocument/references` | 查找引用 |
| **telescope** | `textDocument/definition` | 跳转定义 |

**所有请求都通过同一个 LSP 连接！**

---

### 对比：独立 vs 共享 LSP 客户端

#### ❌ 如果每个插件都启动自己的 LSP

```
ALE      → lua-language-server (进程 1)
outline  → lua-language-server (进程 2)
nvim-cmp → lua-language-server (进程 3)

结果:
- ❌ 3 个独立进程，资源浪费
- ❌ 每个进程独立分析代码，结果可能不一致
- ❌ CPU/内存占用翻倍
```

#### ✅ 实际：共享 LSP 客户端

```
ALE      ┐
outline  ├─→ lua-language-server (单个进程)
nvim-cmp ┘

结果:
- ✅ 只有 1 个进程
- ✅ 所有插件共享分析结果
- ✅ 资源占用最小化
```

---

### 验证方法

#### 方法 1: 查看 LSP 客户端列表

```lua
-- 在 Neovim 中执行
:lua =vim.lsp.get_clients()

-- 输出示例:
-- [
--   {
--     id = 1,
--     name = "lua_language_server",
--     config = { ... },
--     attached_buffers = { 1, 2, 3 },
--   }
-- ]
```

#### 方法 2: 查看系统进程

```bash
# 在终端执行
ps aux | grep lua-language-server

# 输出（只有 1 个进程）:
# user  12345  0.5%  0.3%  lua-language-server ...
```

#### 方法 3: 检查 ALE 的 LSP 信息

```vim
:ALEInfo
```

#### 方法 4: 检查 outline 的 Provider

```lua
:lua =require('outline').get_providers()
```

---

### 注意事项

#### 1️⃣ **确保 ALE 正确启动 LSP**

```vim
" init/ale.vim 中
let g:ale_lsp_suggestions = 1    " 启用 LSP 建议（影响补全）
let g:ale_lint_on_enter = 1      " 进入文件时启动 LSP
```

#### 2️⃣ **nvim-cmp 配置正确**

```lua
-- 确保 sources 包含 nvim_lsp
sources = {
  { name = 'nvim_lsp' },  -- ← 必须有这个
}
```

#### 3️⃣ **避免重复启动 LSP**

```lua
-- ❌ 错误：不要同时配置 lspconfig
require('lspconfig').lua_ls.setup()  -- 会导致 2 个进程！

-- ✅ 正确：只用 ALE 启动 LSP
-- nvim-cmp 和 outline 自动复用
```

---

### 优势总结

| 优势 | 说明 |
|------|------|
| **资源优化** | 单个 LSP 进程服务所有插件，避免重复分析代码 |
| **状态一致** | 所有插件看到相同的符号/诊断信息，避免数据不一致 |
| **解耦设计** | 插件不需要知道其他插件的存在，通过 `vim.lsp` 统一接口通信 |
| **灵活扩展** | 新插件可以无缝接入现有 LSP 生态，无需重复配置 |

---

### 核心结论

> 在 pretty.nvim 中，**ALE 是 LSP 的启动者**，nvim-cmp、outline、aerial、telescope 等插件都是**复用者**。它们通过 `vim.lsp.get_clients()` 获取现有连接，共享同一个 LSP 进程。这就是 Neovim LSP 架构的精髓！

---

## 🔗 参考链接

- [vim.lsp 官方文档](https://neovim.io/doc/user/lsp.html)
- [nvim-lspconfig GitHub](https://github.com/neovim/nvim-lspconfig)
- [ALE GitHub](https://github.com/dense-analysis/ale)
- [LSP 协议规范](https://microsoft.github.io/language-server-protocol/)
- [cmp_nvim_lsp GitHub](https://github.com/hrsh7th/cmp-nvim-lsp)
- [outline.nvim GitHub](https://github.com/hedyhli/outline.nvim)

---

*本文档由 pretty.nvim 维护，欢迎 PR 补充！*
