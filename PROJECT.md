# pretty.nvim - AI Assistant Guide

> 开箱即用的 Neovim 预配置，包含 AI 编程助手功能

---

## 📋 项目概述

**pretty.nvim** 是一个精心调优的 Neovim 预配置项目，提供：
- 🤖 AI 编程助手（CodeCompanion）
- 🎨 Solarized8 主题
- 🔍 智能补全（nvim-cmp）
- ⚡ 快速导航（telescope）
- 📝 代码检查（ALE）
- 🔀 Git 集成（gitsigns + lazygit）

**目标**：5 分钟搭建专业开发环境

---

## 🏗️ 项目结构

```
pretty.nvim/
├── init.vim              # 主配置文件（入口）
├── init/                 # 初始化配置模块
│   ├── ai.vim            # AI 功能配置（VimScript）
│   ├── codecompanion.lua # CodeCompanion 配置
│   ├── gitsigns.lua      # gitsigns 配置
│   ├── markdown.lua      # render-markdown 配置
│   └── ...               # 其他功能模块
├── lua/                  # Lua 插件（第三方）
│   ├── codecompanion/    # CodeCompanion 插件
│   ├── gitsigns/         # gitsigns 插件
│   └── ...
├── plugin/               # Vim 插件（第三方）
├── autoload/             # 自动加载函数
├── scripts/              # 自有脚本
├── patches/              # 第三方插件补丁
└── README.md             # 项目文档
```

---

## 🎯 开发规范

### **核心原则**

1. **VimScript 优先** - 功能实现用 VimScript，Lua 仅用于插件配置
2. **配置和功能分离** - 配置在 `init/*.lua`，功能在 `init/*.vim`
3. **不修改第三方插件代码** - 使用 patch 方式修改（保存在 `patches/`）
4. **简洁至上** - 不必要的功能就删除

### **代码风格**

#### VimScript
```vim
" 函数命名：大驼峰 + 脚本前缀
function! s:AICodingInline() abort
    " 局部变量：l:前缀
    let l:prompt = input('Prompt: ', "")
    
    " 注释：使用双引号
    " 获取上下文
    let l:context = s:AICodingContext()
endfunction

" 快捷键映射
nnoremap <silent> <leader>ai :call <SID>AICodingInline()<CR>
xnoremap <silent> <leader>ai :<C-u>call <SID>AICodingInline()<CR>
```

#### Lua
```lua
-- 模块命名：小写 + 下划线
local ok, codecompanion = pcall(require, "codecompanion")
if not ok then
    vim.notify("plugin not found", vim.log.levels.WARN)
    return
end

-- 配置结构清晰
codecompanion.setup({
    adapters = {...},
    display = {...},
    interactions = {...},
})
```

### **提交规范**

使用 emoji + 描述：
```
✨ 新功能
🐛 Bug 修复
♻️ 代码重构
📝 文档更新
🧹 代码清理
```

**示例**：
```
✨ AIChatSubmit 支持双引擎
🐛 修正 Visual 模式重复调用
♻️ 清理 NeoAI 相关代码
```

---

## 📚 常用命令

### **启动和更新**
```bash
# 启动 Neovim
./run

# 更新配置
nvim --update

# 测试插件加载
nvim -c 'echo "Plugins loaded!"' -c 'quit'
```

### **Git 操作**
```bash
# 查看状态
git status

# 提交更改
git add <file>
git commit -m "✨ <description>"

# 推送（由用户决定）
git push
```

---

## 🤖 AI 助手指南

### **当前 AI 引擎**

**CodeCompanion**（唯一 AI 引擎）
- 位置：`lua/codecompanion/`
- 配置：`init/codecompanion.lua`
- 快捷键：
  - `<leader>ai` - Inline 模式（代码生成/修改）
  - `<F5>` - Chat 模式（对话窗口）

### **AI 功能实现**

**位置**：`init/ai.vim`

**关键函数**：
```vim
" 获取上下文（文件 + 行号）
function! s:AICodingContext() abort
    " 返回：📄 File: filename.lua:#line #{buffer}
endfunction

" Inline 模式
function! s:AICodingInline() abort
    " 1. 读取用户 prompt
    " 2. 获取上下文
    " 3. 执行 :AICodingInline
endfunction
```

**格式说明**：
- `filename:#10` - 第 10 行附近（插入）
- `filename:<10,20>` - 第 10-20 行（替换）

### **当 AI 需要修改代码时**

1. **理解现有代码结构**
   - 读取 `init/ai.vim` 了解 AI 功能实现
   - 读取 `init/codecompanion.lua` 了解配置

2. **遵循代码风格**
   - VimScript 用于功能实现
   - Lua 仅用于插件配置
   - 不使用 `inputsave()/inputrestore()`

3. **添加必要的注释**
   - 函数上方说明功能
   - 关键步骤添加行内注释

4. **测试功能**
   - Inline 模式：选中代码 → `<leader>ai`
   - Chat 模式：`<F5>` 打开对话

### **当 AI 需要创建新文件时**

1. **放在正确的目录下**
   - 功能模块：`init/<name>.vim` 或 `init/<name>.lua`
   - 脚本文件：`scripts/<name>.sh`
   - 补丁文件：`patches/<plugin>-<fix>.patch`

2. **在 `init.vim` 中加载**
   ```vim
   " 加载新模块
   luafile <sfile>:h/<name>.lua
   " 或
   source <sfile>:h/<name>.vim
   ```

3. **遵循命名规范**
   - 文件名：小写 + 下划线
   - 函数名：大驼峰 + 脚本前缀 `s:`

---

## ⚠️ 重要注意事项

### **不要做的事情**

1. ❌ **不要修改第三方插件代码**
   - 位置：`lua/`, `plugin/`, `autoload/`
   - 如需修改：创建 patch 保存到 `patches/`

2. ❌ **不要使用 `inputsave()/inputrestore()`**
   - 会导致 Visual 模式下循环调用
   - 使用 `vim.ui.input()` 异步回调

3. ❌ **不要混合 VimScript 和 Lua**
   - 功能实现：VimScript
   - 插件配置：Lua

4. ❌ **不要自主推送 git push**
   - 由用户决定何时推送

### **推荐的做法**

1. ✅ **先读后改** - 修改前先读取文件，学习用户的编码习惯
2. ✅ **最小改动** - 只改必要内容，保持原有风格
3. ✅ **自动提交** - 每次修改后自动 commit（不推送）
4. ✅ **使用 patch** - 第三方插件修改用 patch 方式

---

## 🧪 测试方法

### **AI 功能测试**

```vim
" 1. Inline 模式（Normal）
" 光标放在某行，按 <leader>ai
" 输入：写一个函数 xxx()

" 2. Inline 模式（Visual）
" 选中代码，按 <leader>ai
" 输入：重构这个函数

" 3. Chat 模式
" 按 <F5> 打开聊天窗口
" 输入：解释这段代码
```

### **配置测试**

```vim
" 重新加载配置
:luafile ~/.openclaw/coding/init/ai.vim

" 检查插件状态
:CodeCompanionCheckHealth
```

---

## 📞 遇到问题时

### **排查步骤**

1. **检查错误信息**
   ```vim
   :messages
   ```

2. **查看日志**
   ```vim
   :lua print(vim.inspect(require('codecompanion').config))
   ```

3. **重新加载配置**
   ```vim
   :source ~/.openclaw/coding/init.vim
   ```

4. **重启 Neovim**
   ```bash
   :qa!
   ./run
   ```

### **常见问题**

| 问题 | 原因 | 解决 |
|------|------|------|
| Visual 模式循环调用 | `inputsave()/inputrestore()` | 使用 `:<C-u>` 清除范围 |
| AI 不回复 | API Key 未设置 | 检查环境变量 |
| 插件加载失败 | 缺少依赖 | 运行 `nvim --update` |

---

## 📝 待处理事项

详见 `TODO-completion.md`：
- 🔴 补全插件迁移（deoplete → nvim-cmp）
- 🟡 检查 denite 使用情况

---

*最后更新：2026-03-16*
