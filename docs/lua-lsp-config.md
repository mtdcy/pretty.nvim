# Lua Language Server 配置说明

## 📋 配置文件

### **1. `.luarc.json`** - lua-language-server 配置

**作用**：配置 Lua 语言服务器的行为，包括诊断、补全、格式化等。

**关键配置**：

#### **运行时配置**
```json
"runtime.version": "LuaJIT",
"runtime.path": [
  "lua/?.lua",
  "lua/?/init.lua"
]
```
- 使用 LuaJIT 运行时
- 配置模块搜索路径

#### **诊断配置**
```json
"diagnostics": {
  "disable": [
    "lowercase-global",      -- 不禁用全局变量小写警告
    "undefined-global",      -- 不禁用未定义全局变量警告
    "unused-local",          -- 不禁用未使用局部变量警告
  ],
  "globals": [
    "vim",                   -- Neovim API
    "describe", "it",        -- Busted 测试框架
  ]
}
```

#### **工作区配置**
```json
"workspace": {
  "library": [
    "$VIMRUNTIME/lua",       -- Neovim Lua API
    "${3rd}/neovim/library"  -- Neovim 类型定义
  ],
  "ignoreDir": [
    "/node_modules",
    "/.git",
    "/prebuilts",
    "/py3env"
  ]
}
```

---

### **2. `.luacheckrc`** - Luacheck Linter 配置

**作用**：配置 Luacheck 静态分析工具的行为。

**关键配置**：

```lua
-- 允许未使用的变量和参数
unused_args = false
unused_vars = false

-- 忽略特定警告
ignore = {
  "212", -- unused argument
  "213", -- unused variable
  "431", -- line too long
}

-- 行长度限制
max_line_length = 120
```

---

## 🎯 禁用的警告说明

### **为什么禁用这些警告？**

| 警告代码 | 说明 | 禁用原因 |
|----------|------|----------|
| `lowercase-global` | 全局变量小写 | Neovim 插件习惯用 `g:` 全局变量 |
| `undefined-global` | 未定义全局变量 | `vim` 等是 Neovim 注入的全局变量 |
| `unused-local` | 未使用局部变量 | 开发中临时变量很常见 |
| `unused-vararg` | 未使用变长参数 | 有时需要保留参数签名 |
| `param-type-mismatch` | 参数类型不匹配 | Lua 是动态类型，过于严格 |
| `assign-type-mismatch` | 赋值类型不匹配 | 动态类型特性 |

---

## 🔧 自定义配置

### **添加更多全局变量**

在 `.luarc.json` 中添加：
```json
"diagnostics": {
  "globals": [
    "vim",
    "your_custom_global",
  ]
}
```

### **调整行长度限制**

在 `.luarc.json` 和 `.luacheckrc` 中修改：
```json
"format": {
  "defaultConfig": {
    "column_limit": 120  // 改为你需要的值
  }
}
```

```lua
-- .luacheckrc
max_line_length = 120  // 改为你需要的值
```

### **启用更多检查**

在 `.luarc.json` 中添加：
```json
"diagnostics": {
  "needed_checkers": [
    "await",
    "codestyle-check",
    "empty-block",
  ]
}
```

---

## 📝 使用建议

### **开发时**
1. **宽松模式** - 当前配置，适合开发
2. **实时检查** - 保存时自动检查

### **提交前**
1. **运行格式化** - `:lua vim.lsp.buf.format()`
2. **运行检查** - `:lua vim.diagnostic.setloclist()`

### **发布前**
1. **严格模式** - 临时启用更多检查
2. **修复所有警告** - 确保代码质量

---

## 🚀 快速命令

```vim
" 格式化当前文件
:lua vim.lsp.buf.format()

" 查看所有诊断
:lua vim.diagnostic.setloclist()

" 跳转到下一个问题
]d

" 跳转到上一个问题
[d

" 查看当前行的诊断
<leader>d
```

---

## ⚠️ 注意事项

1. **不要提交过于严格的配置** - 会影响其他开发者
2. **保持配置一致性** - 团队项目需要统一配置
3. **定期更新配置** - 根据项目需求调整

---

*最后更新：2026-03-18*
