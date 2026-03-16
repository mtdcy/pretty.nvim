# 补全插件迁移计划

> 创建时间：2026-03-16  
> 优先级：🔴 高  
> 状态：待处理

---

## 🚨 需要迁移的废弃插件

### **1. deoplete.nvim** ❌ 已废弃

**当前状态**：
- 作者已停止维护
- 性能不如现代插件
- 社区支持差

**替代方案**：`nvim-cmp`

**迁移步骤**：
1. 安装 nvim-cmp 及相关源
2. 配置 nvim-cmp
3. 删除 deoplete 配置
4. 测试补全功能

**参考配置**：
```lua
-- 待添加
require('cmp').setup({
    -- ...
})
```

---

### **2. neosnippet.vim** ❌ 已废弃

**当前状态**：
- 与 deoplete 一起停止维护
- 功能单一

**替代方案**：`nvim-cmp + cmp-nvim-lsp`（内置 snippet 支持）

**迁移步骤**：
1. 配置 nvim-cmp 的 snippet 支持
2. 删除 neosnippet 配置
3. 测试代码片段

---

### **3. deoplete-jedi** ❌ Python 补全

**当前状态**：
- 依赖 deoplete
- 已废弃

**替代方案**：`nvim-cmp + cmp-nvim-lsp`

**迁移步骤**：
1. 配置 Python LSP
2. 测试 Python 补全

---

## ⚠️ 需要检查的插件

### **denite.nvim** ⚠️ 被替代

**当前状态**：
- 功能被 telescope 替代
- 可能未使用

**检查步骤**：
1. 搜索 denite 使用：`grep -r "denite" init/`
2. 如果未使用，删除相关配置
3. 如果已使用，迁移到 telescope

---

## ✅ 已使用的现代插件

| 插件 | 状态 | 说明 |
|------|------|------|
| **telescope.nvim** | ✅ 活跃 | 文件搜索 |
| **nvim-cmp** | ⏳ 待配置 | 代码补全 |
| **gitsigns.nvim** | ✅ 活跃 | Git 集成 |
| **nvim-treesitter** | ✅ 活跃 | 语法分析 |
| **CodeCompanion** | ✅ 活跃 | AI 助手 |

---

## 📋 迁移计划

### **阶段 1：准备**
- [ ] 备份当前配置
- [ ] 测试环境准备
- [ ] 阅读 nvim-cmp 文档

### **阶段 2：安装 nvim-cmp**
- [ ] 安装 nvim-cmp
- [ ] 安装 cmp-nvim-lsp
- [ ] 安装 cmp-buffer
- [ ] 安装 cmp-path
- [ ] 安装 friendly-snippets

### **阶段 3：配置 nvim-cmp**
- [ ] 基础配置
- [ ] LSP 集成
- [ ] Snippet 支持
- [ ] 自定义源

### **阶段 4：删除旧插件**
- [ ] 删除 deoplete 配置
- [ ] 删除 neosnippet 配置
- [ ] 检查 denite 使用情况

### **阶段 5：测试**
- [ ] 测试代码补全
- [ ] 测试代码片段
- [ ] 测试 Python 补全
- [ ] 测试文件搜索

---

## 📚 参考资料

- [nvim-cmp GitHub](https://github.com/hrsh7th/nvim-cmp)
- [nvim-cmp Wiki](https://github.com/hrsh7th/nvim-cmp/wiki)
- [Awesome nvim-cmp](https://github.com/hrsh7th/nvim-cmp/wiki/List-of-sources)

---

## 💡 备注

- 迁移前务必备份配置
- 逐步迁移，避免一次性改动太多
- 测试每个语言的补全功能
- 记录遇到的问题和解决方案

---

*最后更新：2026-03-16*
