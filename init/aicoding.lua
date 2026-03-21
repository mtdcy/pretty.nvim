-- =============================================================================
-- AI: CodeCompanion.nvim - Lua 入口配置
-- =============================================================================
-- 说明：
--   本文件负责 CodeCompanion 的 VimScript 函数迁移，包括：
--   1. 全局变量设置（tips、filetype）
--   2. API Key 检查（无 Key 时不加载）
--   3. AI 函数（context、inline、chat 相关）
--   4. 命令定义（AICodingInline、AIChatToggle 等）
--   5. Autocmd 设置（监听 Chat 创建/完成事件）
--   6. 快捷键绑定（<leader>ai、<F5> 等）
--
-- 设计理念：
--   - 纯 Lua 实现，与 codecompanion.lua 共存（分工明确）
--   - codecompanion.lua 负责 adapter/setup/rules 配置
--   - aicoding.lua 负责入口函数、命令、快捷键
--
-- 架构：
--   aicoding.lua (入口) → codecompanion.lua (配置) → codecompanion.nvim (插件)
--
-- 使用方式：
--   init.vim 中：luafile init/aicoding.lua
-- =============================================================================

-- =============================================================================
-- 全局变量（与 openai.vim 保持一致）
-- =============================================================================

vim.g.aicoding_tips_ready = "🌹 AI Chat Ready ✨!  Enter: 发送消息，Shift-Enter: 换行 "
vim.g.aicoding_tips_thinking = "🤖 AI is thinking ..."

-- =============================================================================
-- API Key 检查
-- =============================================================================

local api_key = os.getenv("OPENAI_API_KEY")
if not api_key or api_key == "" then
  -- 无 API Key 时不加载
  return
end

local aicoding = {
  -- engine: 加载 codecompanion.lua 返回的接口表
  --   - inline.submit(prompt): 提交 inline 请求
  --   - chat.toggle(): 切换 Chat 窗口
  --   - chat.launch(): 打开 Actions 面板
  --   - chat.submit(): 提交 Chat 消息
  --   - context.buffer(): 返回上下文标识符
  engine = loadfile(vim.fn.expand("<sfile>:h") .. "/codecompanion.lua")(),

  -- augroup: Autocmd 组（监听 Chat 事件）
  augroup = vim.api.nvim_create_augroup("AICodingChat", { clear = true }),

  -- filetype: AI Chat 窗口的 filetype（用于判断是否在 Chat 中）
  filetype = "codecompanion",
}

-- =============================================================================
-- AI 函数（从 openai.vim 迁移）
-- =============================================================================

--- 获取 AI 编码上下文（当前文件 + 光标位置/选区）
---@return string 上下文信息（格式：📄 File: filename:#line 或 📄 File: filename:<start,end>）
---
-- 示例输出：
--   📄 File: /path/to/file.lua:#42              ← 单行（光标所在行）
--   📄 File: /path/to/file.lua:<10,20>          ← 选区（可视模式）
---
-- 注意：vim.fn.line() 的 winid 参数已验证有效（Neovim 0.11+）
local function aicoding_context()
  -- 获取正确的 winid 和 bufnr
  local winid = vim.api.nvim_get_current_win()

  -- 如果当前是 AI chat 窗口，使用上一个窗口（用户代码所在的窗口）
  if vim.bo.filetype == aicoding.filetype then
    winid = vim.fn.win_getid(vim.fn.winnr("#"))
  end

  local bufnr = vim.api.nvim_win_get_buf(winid)

  -- 获取选区行号（vim.fn.line 支持 winid 参数）
  local start_line = vim.fn.line("'<", winid)
  local end_line = vim.fn.line("'>", winid)

  -- 判断是否是可视模式选区
  local mode = vim.fn.visualmode()
  local lines
  if start_line ~= end_line and (mode == "v" or mode == "V" or mode == "\22") then
    lines = "<" .. start_line .. "," .. end_line .. ">"  -- 选区格式
  else
    lines = "#" .. vim.fn.line(".", winid)  -- 单行格式
  end

  -- 返回上下文：📄 File: filename:#line 或 📄 File: filename:<start,end>
  return "📄 File: " .. vim.api.nvim_buf_get_name(bufnr) .. ":" .. lines .. aicoding.engine.context.buffer()
end

--- Chat 编辑模式：清空提示并进入插入模式
--- 行为：清空 tips → 移动到最后一行 → 进入插入模式
_G.AICodingEdit = function()  -- 全局函数（需要被 VimL 函数访问）
  vim.fn.call("PrettyTipsToggle", { "" })  -- 清空提示
  vim.cmd("normal! G")                      -- 移动到最后一行
  vim.cmd("startinsert")                    -- 进入插入模式
end

--- Chat 发送模式：追加上下文并提交
--- 行为：
---   1. 退出插入模式
---   2. 检测是否以 / 开头（命令模式）
---   3. 非命令模式：追加上下文 + 显示思考提示
---   4. 提交消息
_G.AICodingSend = function()
  vim.cmd("stopinsert")  -- 退出插入模式

  local prompt = vim.fn.getline(".")
  local command = prompt:match("^%s*(%S)") == "/"  -- 检测命令模式

  -- 过滤掉命令（命令模式不追加上下文）
  if not command then
    -- 追加上下文到最后一行
    local context = aicoding_context()
    vim.api.nvim_buf_set_lines(0, -1, -1, false, { context, "" })

    vim.cmd("normal! G")  -- 移动到最后一行

    -- 显示思考提示
    vim.fn.call("PrettyTipsToggle", { vim.g.aicoding_tips_thinking })
  end

  -- 提交
  aicoding.engine.chat.submit()
end

--- Chat 准备就绪：设置快捷键和提示
--- 行为：
---   1. 退出插入模式
---   2. 显示就绪提示
---   3. 设置退出/插入行为（Pretty* 函数）
---   4. 设置 buffer-local 快捷键（Normal: Enter 编辑，Insert: Enter 发送）
_G.AICodingReady = function()
  vim.cmd("stopinsert")  -- 退出插入模式

  -- 显示就绪提示
  vim.fn.call("PrettyTipsToggle", { vim.g.aicoding_tips_ready })

  -- 设置退出快捷键行为
  vim.fn.call("PrettyExitWith", { "lua AICodingToggle()" })

  -- 设置插入模式进入快捷键行为
  vim.fn.call("PrettyInsertEnter", { "lua AICodingEdit()" })

  -- 设置插入模式离开快捷键行为
  vim.fn.call("PrettyInsertLeave", { "lua AICodingReady()" })

  -- Normal 模式：Enter 编辑
  vim.keymap.set("n", "<CR>", function()
    AICodingEdit()
  end, { buffer = true, silent = true, desc = "AI Chat: Edit" })

  -- Insert 模式：Enter 发送
  vim.keymap.set("i", "<CR>", function()
    vim.cmd("stopinsert")
    AICodingSend()
  end, { buffer = true, silent = true, desc = "AI Chat: Send" })

  vim.notify("✅ AI Chat Ready")
end

--- Chat 切换：打开/关闭 Chat 窗口
_G.AICodingToggle = function()
  aicoding.engine.chat.toggle()
end

-- =============================================================================
-- Autocmd：监听 Chat 创建/完成事件
-- =============================================================================

vim.api.nvim_create_autocmd("User", {
  group = aicoding.augroup,
  pattern = { "CodeCompanionChatCreated", "CodeCompanionChatDone" },
  callback = function()
    if vim.bo.filetype == aicoding.filetype then
      AICodingReady()
    end
  end,
  desc = "AI Chat Ready",
})

-- =============================================================================
-- Inline 模式：读取用户输入并执行
-- =============================================================================
--- Inline 模式：读取用户输入并执行
--- 行为：
---   1. 读取用户输入（input 对话框）
---   2. 检测是否以 / 开头（命令模式）
---   3. 命令模式：直接提交（如 /refactor）
---   4. 非命令模式：追加上下文 + 用户输入
local function aicoding_inline()
  -- 读取用户输入
  local prompt = vim.fn.input("🌹 AI Coding: ", "")

  if prompt == "" then
    vim.notify("⚠️ Empty input", vim.log.levels.WARN)
    return
  end

  local command = prompt:match("^%s*(%S)") == "/"  -- 检测命令模式

  if command then
    -- 命令模式：直接提交（不追加上下文）
    aicoding.engine.inline.submit(prompt)
  else
    -- 非命令模式：追加上下文
    -- 注意：使用 \\n 而不是 \n，因为 vim.cmd() 会解析换行
    local context = aicoding_context()
    aicoding.engine.inline.submit(context .. "\\n🙋 User:" .. prompt)
  end
end

-- =============================================================================
-- 命令定义
-- =============================================================================

vim.api.nvim_create_user_command("AICodingInline", aicoding_inline, { nargs = "*", desc = "AI Inline coding" })

vim.api.nvim_create_user_command("AIChatLaunch", aicoding.engine.chat.launch, { desc = "AI Chat Actions" })

vim.api.nvim_create_user_command("AIChatToggle", aicoding.engine.chat.toggle, { desc = "AI Chat Toggle" })

vim.api.nvim_create_user_command("AIChatSubmit", aicoding.engine.chat.submit, { desc = "AI Chat Submit" })

-- =============================================================================
-- 快捷键
-- =============================================================================

-- Inline 模式：Normal & Visual 模式 <leader>ai
vim.keymap.set({ "n", "v" }, "<leader>ai", function()
  aicoding_inline()
end, { silent = true, desc = "AI Inline" })

-- 只定义 Inline 模式按键，其他交给 Finder
