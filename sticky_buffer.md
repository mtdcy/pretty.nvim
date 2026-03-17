# Sticky Buffer - 窗口管理文档

> **说明**：本文档描述 pretty.nvim 的 Sticky Buffer 机制，即特定类型的 Buffer 自动分配到固定窗口的行为。

---

## 📋 窗口布局

```
+----------+------------------+----------+
|          |                  |          |
| leftbar  |     main         | rightbar |
|   (1)    |      (0)         |    (4)   |
|          |                  |          |
+----------+------------------+----------+
| headbar (2) / footbar (3)              |
+----------------------------------------+
```

### 窗口 ID 映射

| wmid | 位置 | 用途 | Buffer 类型 |
|------|------|------|------------|
| 0 | main | 主窗口 | 普通文件 |
| 1 | leftbar | 左侧栏 | NERDTree |
| 2 | headbar | 顶部栏 | help/man 文档 |
| 3 | footbar | 底部栏 | quickfix/location list |
| 4 | rightbar | 右侧栏 | Tagbar 或 CodeCompanion（互斥） |

---

## 🎯 Sticky Buffer 机制

### **核心原理**

1. **Buffer 类型识别**：通过 `filetype` 判断 Buffer 类型
2. **窗口分配**：根据类型分配到对应的窗口（wmid）
3. **自动纠正**：Buffer 被错误分配时，自动移动到正确窗口

### **关键函数**

```vim
" Buffer 类型识别
s:wmtype(bufnr)        " 返回 Buffer 类型字符串
s:wmid_filetype(type)  " 根据类型返回 wmid

" 窗口操作
s:wm_move(buf)         " 移动 Buffer 到正确窗口
s:wm_settle(wmid)      " 安置窗口到正确位置
```

---

## 📊 测试用例

### **Opening Normal Buffers（普通 Buffer）**

| 用例 | 操作 | 预期行为 |
|------|------|---------|
| **SB00** | `:e a.txt` in main window | ✅ 在主窗口打开并聚焦 |
| **SB01** | `:sp b.txt` in main window | ✅ 在主窗口上方新建 split 窗口 |
| **SB02** | `:e c.txt` in splited window | ✅ 在当前 split 窗口打开 |

---

### **Opening Normal Buffers in Sidebar（在侧边栏打开普通 Buffer）**

**前置条件**：
```bash
nvim a.txt b.txt -c 'sp c.txt | e d.txt | NERDTree'
```

| 用例 | 操作 | 预期行为 | 后续操作 |
|------|------|---------|---------|
| **SB10** | `:e a.txt` in sidebar | ✅ 聚焦主窗口的 `a.txt` | `:wincmd h` |
| **SB11** | `:e b.txt` in sidebar | ✅ 聚焦主窗口的 `b.txt` | `:wincmd h` |
| **SB12** | `:e d.txt` in sidebar | ✅ 聚焦 split 窗口的 `d.txt` | `:wincmd h` |
| **SB13** | `:e c.txt` in sidebar | ✅ 聚焦主窗口的 `c.txt` | `:wincmd h` |
| **SB14** | `:e e.txt` in sidebar | ✅ 在主窗口打开新文件 `e.txt` | `:wincmd h` |

---

### **Opening Document Buffers（文档 Buffer）**

**前置条件**：
```bash
nvim a.txt -c sp 'NERDTree'
```

| 用例 | 操作 | 预期行为 | 后续操作 |
|------|------|---------|---------|
| **SB20** | `:h sp` in main window | ✅ 在新文档窗口打开 `:sp` 帮助 | `:wincmd p` |
| **SB21** | `:Man echo` in main window | ✅ 在现有文档窗口打开 `BUILTIN(1)` | `:wincmd h` |
| **SB22** | `:h wincmd` in sidebar | ✅ 在现有文档窗口打开 `:wincmd` 帮助 | `:wincmd h` |
| **SB23** | `:Man source` in sidebar | ✅ 在现有文档窗口打开 `BUILTIN(1)` | - |

---

## 🔧 关键修复

### **问题：bdelete 删除最后一个 Buffer 导致窗口关闭**

**原因**：
```vim
" ❌ 旧逻辑
if len(li) > 0
    exe 'bprev | bdelete ' . bufnr
else
    " 没有处理，g:winids[0] 保持原值
endif

" 结果：
" 1. bdelete 删除最后一个 buffer
" 2. Neovim 自动关闭窗口
" 3. g:winids[0] 还是指向已关闭的窗口 ID
" 4. 后续 WinEnter 触发 quit，关闭所有窗口
```

**修复方案**：
```vim
" ✅ 新逻辑：不删除最后一个 buffer
if len(li) > 0
    exe 'bprev | bdelete ' . bufnr
else
    " 提示用户使用 :qa
    echo "Last buffer, close it with :qa"
endif

" 配合 BufDelete 事件自动恢复 main 窗口：
autocmd BufDelete * call s:wm_main()
```

---

### **问题：WinClosed 事件清理逻辑不完整**

**原因**：
- 使用 `WinClosed` 检测窗口关闭
- 清理逻辑只检查当前 tab 的其他窗口
- 没有找到时，`g:winids[0]` 保持负数

**修复方案**：
```vim
" ✅ 使用 BufDelete 而非 WinClosed
autocmd BufDelete * call s:wm_main()

" s:wm_main() 自动恢复 main 窗口：
function! s:wm_main() abort
    " 检查 main 窗口是否存在
    if s:wm_winnr(0) > 0 | return | endif
    
    " 清除旧的 winid 记录
    call s:wm_winid_set(s:wmid(winid), 0)
    " 将当前窗口设为新的 main 窗口
    call s:wm_winid_set(0, winid)
    " 创建空 buffer（关键）
    enew
endfunction
```

---

## 📝 Buffer 类型识别规则

| filetype | wmid | 说明 |
|----------|------|------|
| `''` (空) | 0 | 普通文件（主窗口） |
| `'nerdtree'` | 1 | NERDTree 文件树 |
| `'help'/'man'/'doc'/'ale-info'` | 2 | 帮助文档 |
| `'qf'` (quickfix) | 3 | 快速修复列表 |
| `'tagbar'` | 4 | Tagbar 符号列表 |
| `'codecompanion'` | 4 | CodeCompanion AI 助手 |

**注意**：
- Tagbar 和 CodeCompanion 互斥（共用 rightbar）
- 帮助文档每个新窗口打开（多文档支持）

---

## 🎯 自动命令

```vim
augroup WM
    autocmd!
    
    " 主窗口管理：检测 main 窗口关闭并恢复
    autocmd BufDelete   * call s:wm_main()
    
    " 窗口更新：检查 Buffer 分配
    autocmd BufEnter    * call s:wm_update()
    
    " 特殊处理：NERDTree/Tagbar/CodeCompanion 创建时设置 eventignore
    autocmd FileType    nerdtree,tagbar,codecompanion call s:wm_update()

    " Terminal 自动进入插入模式
    autocmd BufEnter    term://* startinsert
    autocmd BufLeave    term://* stopinsert
augroup END
```

---

## 🧪 调试方法

### **启用调试模式**

```vim
let g:wm_debug = 1
```

### **查看窗口信息**

```vim
" 调试快捷键（启用 g:wm_debug 后）
<C-Y>  " 显示当前窗口和 Buffer 的详细信息
```

### **手动检查**

```vim
" 查看窗口 ID 映射
echo g:winids

" 查看当前 wmid
echo index(g:winids, win_getid())

" 查看 Buffer 类型
echo getbufvar('%', '&ft')
```

---

## 📚 相关命令

| 命令 | 功能 |
|------|------|
| `:BufferClose` | 关闭当前 Buffer（智能处理） |
| `:BufferNext` | 切换到下一个 Buffer |
| `:BufferPrev` | 切换到上一个 Buffer |

---

## ⚠️ 注意事项

1. **不要手动删除最后一个 Buffer**
   - 使用 `:BufferClose` 而非 `:bdelete`
   - 最后一个 Buffer 会提示使用 `:qa`

2. **侧边栏窗口不要编辑普通文件**
   - 会自动移动到主窗口
   - 可能导致窗口布局混乱

3. **Tagbar 和 CodeCompanion 互斥**
   - 同时打开时，后打开的会关闭先打开的
   - 共用 rightbar 窗口位置

---

**最后更新**：2026-03-17  
**作者**：Chan Fang
