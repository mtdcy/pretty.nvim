# pretty.nvim 项目规则

## 📋 项目概况

**名称**: pretty.nvim  
**作者**: Chen Fang (方哥)  
**位置**: `~/workspace/pretty.nvim/`  
**类型**: Neovim 个人配置  
**理念**: 简洁、高效、可维护

---

## 🏗️ 架构结构

```
pretty.nvim/
├── init.vim              # 主配置入口（VimScript）
├── init/
│   ├── aicoding.lua      # AI 功能入口
│   ├── codecompanion.lua # AI Adapter 配置
│   ├── telescope.lua     # Telescope 搜索配置
│   ├── finder.lua        # Finder 菜单入口
│   ├── style.lua         # 代码格式化配置
│   └── ...               # 其他模块
└── nvim/parser/          # Treesitter parsers
```

---

## 💻 编码规范

### **Lua 代码风格**

```lua
-- ✅ 函数命名：snake_case
local function get_aicoding_context()
  -- 局部函数用小写
end

-- ✅ 全局函数：PascalCase 或 动词开头
_G.AICodingReady = function()
  -- 全局函数需要明确标记
end

-- ✅ 注释：使用中文
-- 说明性注释用中文
local winid = vim.api.nvim_get_current_win()

-- ✅ 类型注释（LuaLS）
---@param index number 要选择的项（从 1 开始）
---@return boolean success 是否成功
```

### **VimScript 代码风格**

```vim
" ✅ 变量命名：小写 + 下划线
let g:aicoding_tips_ready = '...'

" ✅ 函数命名：PascalCase
function! AIChatReady() abort
  " 全局函数用大写开头
endfunction

" ✅ 局部函数：s: 前缀
function! s:aicoding_context() abort
  " 局部函数用小写
endfunction
```

---

## 🔧 核心模块

### **1. AI 功能 (aicoding.lua + codecompanion.lua)**

**职责分工**：
- `aicoding.lua` - 入口函数、快捷键、命令、Autocmd
- `codecompanion.lua` - Adapter、UI、System Prompts

**环境变量**：
```bash
AICODING_BASE_URL=https://dashscope.aliyuncs.com/compatible-mode/v1
AICODING_API_KEY=sk-xxx
AICODING_MODEL=qwen3.5-plus
```

**快捷键**：
| 快捷键 | 功能 |
|--------|------|
| `<leader>ai` | AI Inline（代码生成/修改） |
| `<F5>` | Toggle Chat（打开/关闭） |
| `<S-F5>` | Chat Actions（操作面板） |

---

### **2. Telescope (telescope.lua + finder.lua)**

**架构**：
- `finder.lua` - 菜单入口、全局按键
- `telescope.lua` - UI 配置、按键绑定

**布局配置**：
```lua
layout_strategy = "center"
prompt_position = "bottom"
height = { 0.5, max = 13 }
width = { 0.3, min = 72 }
```

**按键绑定**：
| 按键 | 功能 |
|------|------|
| `j/k` | 上下选择 |
| `<CR>/<Space>` | 确认选择 |
| `1-9` | 快速选择第 N 项 |
| `Q` | 关闭 |
| `<Enter>` | 打开主菜单 |

---

### **3. 代码格式化 (style.lua)**

**格式化器**：
| 文件类型 | 格式化器 | 配置 |
|---------|---------|------|
| Lua | StyLua | `.stylua.toml` |
| Shell | shfmt | `-w -kp -i 4 -ln bash` |
| YAML | yamlfix | `.yamlfix.toml` |
| JSON | fixjson | `-i 2 -w` |

**缩进规则**：
- Lua: 2 空格
- Shell: 4 空格
- YAML/JSON: 2 空格
- Makefile: 制表符

---

## 🎯 设计原则

### **1. 模块化**

每个功能独立文件，职责清晰：
- VimScript 入口（`.vim`）
- Lua 配置（`.lua`）

### **2. 命名空间**

- 全局函数：`Pretty*` 前缀 或 动词开头（`AICoding*`）
- 局部函数：`s:` 前缀（VimScript）或 `local`（Lua）
- 变量：`g:` 全局，`l:` 局部

### **3. 注释规范**

- 文件头：说明职责和使用方式
- 函数：`@param`、`@return` 类型注释
- 内联：中文说明关键逻辑

### **4. 加载顺序**

```
init.vim
 ↓
init/ui.vim
 ↓
aicoding.lua → AI 功能
 ↓
finder.lua → 搜索功能
```

---

## 🛠️ 开发流程

### **1. 添加新功能**

```
1. 在 init/ 创建新文件（如 feature.lua）
2. 在 init.vim 中加载
3. 定义命令和快捷键
4. 提交时 git commit -m "✨ feature: 描述"
```

### **2. 修改配置**

```
1. 修改对应模块文件
2. 测试：<leader>ss 重载配置
3. 验证功能正常
4. git commit -m "🔧 module: 描述"
```

### **3. 格式化代码**

```vim
:StyleFormat  " 手动格式化当前文件
```

---

## 📝 Git 规范

### **Commit 格式**

```
<emoji> <type>: <description>
```

**常用 Emoji**：
| Emoji | 含义 |
|-------|------|
| ✨ | 新功能 |
| 🐛 | Bug 修复 |
| 📝 | 文档变更 |
| ♻️ | 代码重构 |
| 💄 | 格式/样式 |
| ✅ | 测试相关 |
| 🔧 | 构建/工具 |

**示例**：
```
✨ ai: 添加 CodeCompanion 配置
🐛 telescope: 修复 mappings 配置
📝 README: 更新安装说明
```

---

## ⚠️ 注意事项

### **1. 不要修改的文件**

- 第三方插件代码

### **2. 敏感信息**

- API Key 使用环境变量
- 不要提交 `.env` 文件
- 使用 `dotenv.nvim` 加载

### **3. 兼容性**

- Neovim 0.11+
- bash 3.2+（Shell 脚本）

---

## 🚀 快速开始

### **安装依赖**

```bash
# 格式化器
brew install stylua shfmt
pip install yamlfix
npm install -g fixjson
```

### **启动 Neovim**

```bash
cd ~/workspace/pretty.nvim
nvim
```

### **常用命令**

```vim
<Enter>        " 打开 Finder 菜单
<leader>ss     " 重载配置
<leader>ai     " AI Inline
<F5>           " Toggle Chat
```

---

**最后更新**: 2026-03-21  
**维护者**: Chen Fang (方哥)
