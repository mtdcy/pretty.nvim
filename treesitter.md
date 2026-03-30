# Tree-sitter 完全指南 — pretty.nvim

> **最后更新**: 2026-04-01  
> **适用版本**: Neovim 0.11+  
> **作者**: Chen Fang + 小五同学

---

## 📖 什么是 Tree-sitter？

**Tree-sitter** 是一个增量解析库，它将代码解析成 **抽象语法树（AST）**，而不是简单的文本匹配。

### 核心理念

```
传统方式（正则匹配）          Tree-sitter（语法树）
     ↓                              ↓
  文本行 → 正则匹配              代码 → 语法树 → 查询匹配
     ↓                              ↓
  基于模式猜测                   基于语法理解
```

---

## 🌳 Tree-sitter 工作原理

### 1️⃣ 代码 → 语法树

**示例代码**：
```lua
local function add(a, b)
  return a + b
end
```

**Tree-sitter 解析后的语法树**：
```
(chunk
  (function_declaration
    name: (identifier) "add"
    parameters: (parameters
      (identifier) "a"
      (identifier) "b")
    body: (block
      (return_statement
        (binary_expression
          left: (identifier) "a"
          right: (identifier) "b")))))
```

**关键点**：
- ✅ 知道 `add` 是函数名
- ✅ 知道 `a, b` 是参数
- ✅ 知道 `a + b` 是返回值
- ✅ 知道 `local function` 是函数声明

---

### 2️⃣ 语法树 → 应用效果

```
语法树 (AST)
    ↓
    ├──→ highlights.scm  →  语法高亮
    ├──→ folds.scm       →  代码折叠
    ├──→ indents.scm     →  自动缩进
    ├──→ injections.scm  →  语言注入
    ├──→ locals.scm      →  变量作用域
    └──→ cc_symbols.scm  →  符号导航
```

---

## 📂 pretty.nvim 目录结构

```
pretty.nvim/
├── parser/              # Tree-sitter 解析器（二进制文件）
│   ├── bash.so
│   ├── json.so
│   ├── vim.so
│   ├── yaml.so
│   └── ... (7 种语言)
│
├── parser-info/         # Parser 版本记录
│   ├── bash.revision
│   ├── vim.revision
│   └── ...
│
└── queries/             # 查询规则（.scm 文件）
    ├── lua/
    │   ├── highlights.scm      # 语法高亮
    │   ├── folds.scm           # 代码折叠
    │   ├── indents.scm         # 缩进规则
    │   ├── injections.scm      # 语言注入
    │   ├── locals.scm          # 局部变量
    │   ├── cc_symbols.scm      # 符号导航
    │   └── rainbow-*.scm       # 彩虹括号
    ├── vim/
    ├── yaml/
    └── ... (320+ 语言)
```

---

## 🔗 Parser 与 Queries 的关系

### 依赖关系

```
┌─────────────────────────────────────────────────────────┐
│                    代码文件 (.lua)                       │
└─────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────┐
│              Parser (parser/lua.so)                      │
│                   ⚠️ 必需！                              │
│  功能：解析代码 → 生成语法树 (AST)                        │
└─────────────────────────────────────────────────────────┘
                            ↓
                    语法树 (AST)
                    /    |    \
                   ↓     ↓     ↓
    ┌──────────────┐  ┌──────┴──────┐  ┌──────────────┐
    │ highlights   │  │   folds     │  │   indents    │
    │ queries/lua/ │  │ queries/lua/│  │ queries/lua/ │
    │ highlights   │  │ folds.scm   │  │ indents.scm  │
    │ .scm         │  │             │  │              │
    └──────────────┘  └─────────────┘  └──────────────┘
           ↓                ↓                ↓
      语法高亮          代码折叠         自动缩进
```

### 关键结论

| 情况 | Parser | Queries | 结果 |
|------|--------|---------|------|
| ✅ 完整 | 有 | 有 | Tree-sitter 完全工作 |
| ❌ 无 Parser | 无 | 有 | Queries 无法工作，回退传统方式 |
| ⚠️ 无 Queries | 有 | 无 | Parser 生成树但无法使用 |

**示例**：

```bash
# 有 queries/lua/folds.scm，但没有 parser/lua.so
❌ 无法生成语法树
❌ folds.scm 无法匹配 (function_declaration) 节点
⚠️ 回退到 style.lua 的配置：foldmethod = "syntax"
```

---

## 📊 核心功能对比

### 1️⃣ 语法高亮（highlights.scm）

**作用**：定义不同语法元素的高亮组

**示例**：
```scm
; 匹配 Lua 关键字
"return" @keyword.return
"local" @keyword

(function_declaration
  "function" @keyword.function)

(string) @string
(identifier) @variable
```

**效果对比**：

| 特性 | 无 Tree-sitter | 有 Tree-sitter |
|------|---------------|---------------|
| 识别方式 | 正则匹配 | 语法树节点 |
| 准确性 | ⚠️ 基于模式猜测 | ✅ 精确识别 |
| 语义高亮 | ❌ 无法实现 | ✅ 支持（类/方法/变量） |
| 复杂模式 | ❌ 容易出错 | ✅ 正确处理 |

---

### 2️⃣ 代码折叠（folds.scm）

**作用**：定义哪些代码块可以折叠

**示例**：
```scm
[
  (function_declaration)
  (if_statement)
  (table_constructor)
] @fold
```

**效果对比**：

| 特性 | 无 Tree-sitter | 有 Tree-sitter |
|------|---------------|---------------|
| 折叠边界 | ⚠️ 基于缩进猜测 | ✅ 精确语法边界 |
| 多行字符串 | ❌ 容易误判 | ✅ 正确识别 |
| 嵌套结构 | ⚠️ 可能错误 | ✅ 准确嵌套 |

---

### 3️⃣ 自动缩进（indents.scm）

**作用**：定义自动缩进行为

**示例**：
```scm
; 这些节点增加缩进
[
  (function_declaration)
  (table_constructor)
  (arguments)
] @indent

; 这些节点减少缩进
[
  "end"
  ")"
  "}"
] @indent.dedent
```

**效果对比**：

| 特性 | 无 Tree-sitter | 有 Tree-sitter |
|------|---------------|---------------|
| 复杂嵌套 | ⚠️ 可能错误 | ✅ 准确判断 |
| 多行 table | ❌ 不会格式化 | ✅ 正确展开 |
| 链式调用 | ⚠️ 容易出错 | ✅ 正确处理 |

---

### 4️⃣ 语言注入（injections.scm）

**作用**：在代码中嵌入其他语言的代码块

**示例**：
```scm
(function_call
  name: (identifier) @_cdef_identifier
  arguments: (arguments
    (string
      content: _ @injection.content)))
  (#set! injection.language "c")
  (#eq? @_cdef_identifier "cdef")
```

**效果**：
```lua
-- Lua 代码
ffi.cdef[[
  int printf(const char *fmt);  -- ← C 代码高亮
]])

vim.api.nvim_command([[
  autocmd BufWritePost *.lua format  -- ← Vim 代码高亮
]])
```

---

### 5️⃣ 符号导航（cc_symbols.scm）

**作用**：定义代码符号用于导航

**示例**：
```scm
(function_declaration
  name: (identifier) @name
  (#set! "kind" "Function")) @symbol

(variable_declaration
  name: (identifier) @name
  (#set! "kind" "Variable")) @symbol
```

**应用**：
- Aerial.nvim 符号列表
- Telescope 符号搜索
- `:PrettyFindSymbols` 符号导航

---

## 🎯 实际例子：`=` 格式化的差别

**测试代码**：
```lua
local function test( )
local x={a=1,b={c=2,d=3,},e=4,}
if x.a==1 and x.b.c==2 then
print("ok")
end
end
```

**❌ 无 Tree-sitter（基于 indentexpr）**：
```lua
local function test( )
local x={a=1,b={c=2,d=3,},e=4,}  -- ❌ table 没格式化
if x.a==1 and x.b.c==2 then
print("ok")                       -- ⚠️ 缩进可能对可能错
end
end
```

**✅ 有 Tree-sitter（基于 treesitter indent）**：
```lua
local function test()
  local x = {                     -- ✅ table 展开
    a = 1,
    b = {
      c = 2,
      d = 3,
    },
    e = 4,
  }
  if x.a == 1 and x.b.c == 2 then  -- ✅ 条件格式化
    print("ok")
  end
end
```

---

## ⚙️ 常用配置选项

### 1️⃣ 全局配置

```lua
-- 启用 Tree-sitter（Neovim 0.11+ 自动启用）
vim.treesitter.start({ buf = 0 })

-- 禁用
vim.treesitter.stop({ buf = 0 })

-- 检查是否启用
local active = vim.treesitter.highlighter.active[bufnr]
```

### 2️⃣ 折叠配置

```lua
-- 使用 Tree-sitter 折叠
vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.wo.foldmethod = "expr"
```

### 3️⃣ pretty.nvim 配置方式（纯内置方案）

```lua
-- init/style.lua
-- 1. 全局启用 Tree-sitter 折叠
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- 2. 保存文件时自动启用 treesitter 并格式化
vim.api.nvim_create_autocmd("BufWritePost", {
  callback = function()
    vim.treesitter.start()
    style_do_format()
  end
})

-- 3. 预编译 parser 位置：parser/*.so
--    无需 nvim-treesitter 插件，无需编译
```

**⚠️ 注意**：pretty.nvim **不依赖** nvim-treesitter 插件，原因：
- ✅ Neovim 内置 `vim.treesitter` 模块已足够成熟
- ✅ 预编译 parser 避免编译失败和版本不稳定问题
- ✅ 减少插件依赖，降低维护成本



---

## 🔧 验证方法

### 检查 Parser 是否加载

```lua
-- 在 Neovim 中运行
:lua =vim.treesitter.get_parser(0, "lua")    -- 有 parser → 返回对象
:lua =vim.treesitter.get_parser(0, "python") -- 无 parser → 报错
```

### 检查 queries 是否生效

```vim
:InspectTree    -- 显示语法树和匹配的高亮
:set foldexpr?  -- 应该显示 v:lua.vim.treesitter.foldexpr()
```



---

## 📊 pretty.nvim 当前状态

- ✅ 全局使用 Tree-sitter 折叠（`vim.treesitter.foldexpr()`）
- ✅ 预编译 parser（`prebuilts/lib/nvim/parser/*.so`）
- ✅ 自动启用 treesitter （Neovim 0.11+）
- ✅ 不依赖 nvim-treesitter 插件

### 当前折叠配置（init/style.lua）

```lua
-- 默认全局使用 Tree-sitter 折叠
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevelstart = 99 -- 默认不折叠
vim.opt.foldnestmax = 1
vim.opt.foldminlines = 3 -- 不折叠最小的 if-else 语句

-- 文件类型特定配置（覆盖全局设置）
style.filetypes = {
  vim = { foldmethod = "marker", foldlevel = 0 },   -- 标记折叠（VimL 有明确的 {{{ 标记）
  lua = { foldmethod = "expr" },                    -- Tree-sitter 折叠（默认）
  yaml = { foldmethod = "expr" },                   -- Tree-sitter 折叠（默认）
  markdown = { foldlevel = 1 },                     -- H2 级别开始折叠
  -- 其他语言默认使用全局 Tree-sitter 折叠
}
```

**说明**：

- ✅ 默认使用 Tree-sitter 折叠（`vim.treesitter.foldexpr()`）
- ✅ 仅 VimL 使用 `marker` 折叠（因为 `.vim` 文件普遍使用 `{{{` 标记）
- ⚠️ 没有 parser 的语言会回退到 `syntax` 折叠（Neovim 默认行为）

---

## 🔍 vim.treesitter vs nvim-treesitter

### 核心区别

| 项目 | 类型 | 位置 | 作用 | 是否必需 |
|------|------|------|------|---------|
| **vim.treesitter** | Neovim 内置模块 | `runtime/lua/vim/treesitter/` | 核心 API | ✅ Neovim 自带 |
| **nvim-treesitter** | 社区插件 | `lua/nvim-treesitter/` | 配置管理 + 自动安装 | ❌ 可选 |

---

### 关键问题：不安装 nvim-treesitter 插件，内置功能能否工作？

**答案**：✅ **可以工作！**

**验证逻辑**：
```
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
              ↓
    调用 Neovim 内置函数
              ↓
    vim.treesitter.foldexpr() (runtime/lua/vim/treesitter/_fold.lua)
              ↓
    需要 parser 存在 (parser/lua.so)
              ↓
    ✅ 工作！不需要 nvim-treesitter 插件
```

**条件**：
1. Neovim 编译时启用了 tree-sitter（0.8+ 默认启用）
2. parser 存在（`parser/lua.so`）
3. queries 存在（`queries/lua/folds.scm`）

---

### nvim-treesitter 插件的实际用途

| 功能模块 | nvim-treesitter 提供 | Neovim 内置 | 是否必需 |
|---------|---------------------|------------|---------|
| **Parser 安装** | ✅ TSInstall | ❌ 无 | ⚠️ 需要（或手动） |
| **Parser 管理** | ✅ 自动下载/编译 | ❌ 无 | ⚠️ 需要（或手动） |
| **Highlight** | ✅ 模块化管理 | ✅ vim.treesitter.highlighter | ❌ 可选 |
| **Fold** | ✅ fold.lua | ✅ vim.treesitter.foldexpr() | ❌ 可选 |
| **Indent** | ✅ indent.lua | ✅ vim.treesitter.indentexpr() | ❌ 可选 |
| **Text Objects** | ✅ textobjects | ❌ 无 | ✅ 需要插件 |
| **Incremental Selection** | ✅ 模块 | ❌ 无 | ✅ 需要插件 |
| **Query 管理** | ✅ 自动加载 | ⚠️ 基础支持 | ⚠️ 需要插件 |
| **配置简化** | ✅ configs.setup() | ❌ 无 | ⚠️ 需要插件 |

---

### pretty.nvim 使用方式

```lua
-- init/style.lua
-- 1. 全局 Tree-sitter 折叠
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- 2. 保存文件时自动启用 treesitter
vim.api.nvim_create_autocmd("BufWritePost", {
  callback = function()
    vim.treesitter.start()
    style_do_format()
  end
})

-- 3. 预编译 parser 位置：prebuilts/lib/nvim/parser/*.so
--    无需编译，无需 nvim-treesitter 插件
```

**nvim-treesitter 插件的价值**（pretty.nvim 未使用）：
| 价值 | 说明 | pretty.nvim 方案 |
|------|------|-----------------|
| **Parser 自动安装** | `:TSInstall lua` 自动下载编译 | ❌ 手动下载预编译 |
| **配置简化** | `configs.setup()` | ❌ 直接用内置 API |
| **Query 自动加载** | 自动从 queries/ 加载 | ✅ 同左（内置支持） |
| **额外功能** | textobjects, incremental selection | ❌ 不需要 |
| **版本管理** | 管理 parser grammar 版本 | ❌ 手动管理 |

**pretty.nvim 选择纯内置方案的原因**：
- ✅ 减少插件依赖
- ✅ 预编译 parser 避免编译失败
- ✅ Neovim 内置 API 已足够成熟

---

### 设计哲学

```
💡 为了获得性能与体验及行业标准统一，原则上：
   外置工具 > treesitter > vim 内置
```

| 层级 | 工具 | 优先级 | 说明 |
|------|------|--------|------|
| **外置工具** | stylua, shfmt, ruff | ✅ 最高 | 行业标准，专业工具 |
| **treesitter** | vim.treesitter | ⚠️ 中等 | Neovim 内置，足够成熟 |
| **vim 内置** | syntax, indent | ❌ 兜底 | 无 treesitter 时回退 |

**pretty.nvim 的选择**：
- ✅ 格式化：优先 LSP → 外置工具（stylua/yamlfix/ruff）→ vim 内置 `=`
- ✅ 折叠：默认 Tree-sitter → 特定语言用 marker（如 VimL）
- ✅ 高亮：Neovim 内置 treesitter 高亮
- ✅ Parser：预编译二进制，避免编译失败

---

## 📚 参考资料

- **Tree-sitter 官方文档**: https://tree-sitter.github.io/
- **Neovim Tree-sitter**: https://neovim.io/doc/user/treesitter.html
- **nvim-treesitter 插件**: https://github.com/nvim-treesitter/nvim-treesitter
- **SCM 查询语法**: https://tree-sitter.github.io/tree-sitter/using-parsers#pattern-matching-with-queries
- **pretty.nvim queries**: `queries/` 目录

---

## 📝 更新日志

| 日期 | 更新内容 |
|------|---------|
| 2026-04-01 | 更新折叠配置为 Tree-sitter 默认，移除 nvim-treesitter 插件依赖说明 |
| 2026-03-31 | 初始版本，整理 Tree-sitter 话题讨论 |

---

*本文档由 小五同学 整理，基于与方哥的技术讨论*
