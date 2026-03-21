-- =============================================================================
-- AI: CodeCompanion.nvim - Lua 配置（仅 openai.vim 转换）
-- =============================================================================
-- 说明：
--   本文件是 init/openai.vim 的 Lua 版本，包括：
--   1. 全局变量设置
--   2. API Key 检查
--   3. AI 函数（context、inline、chat 相关）
--   4. 命令定义
--   5. Autocmd 设置
--   6. 快捷键绑定
--
-- 设计理念：
--   - 纯 Lua 实现 openai.vim 的功能
--   - 与 codecompanion.lua 共存（分工明确）
--   - codecompanion.lua 负责 adapter/setup 配置
--   - openai.lua 负责 VimScript 函数迁移
--
-- 使用方式：
--   init.vim 中：luafile init/openai.lua
--   （或者保留 openai.vim，两者选其一）
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
  -- 加载 Telescope 功能模块
  engine = loadfile(vim.fn.expand("<sfile>:h") .. "/codecompanion.lua")(),

  augroup = vim.api.nvim_create_augroup("AICodingChat", { clear = true }),

  filetype = "codecompanion",
}

-- =============================================================================
-- AI 函数（从 openai.vim 迁移）
-- =============================================================================

--- 获取 AI 编码上下文
---@return string 上下文信息（文件格式：file:#line 或 file:<start,end>）
local function aicoding_context()
  -- 获取正确的 winid 和 bufnr
  local winid = vim.api.nvim_get_current_win()

  -- 如果当前是 AI chat 窗口，使用上一个窗口
  if vim.bo.filetype == aicoding.filetype then
    -- 好像vim.api没有获取上一个窗口的接品
    winid = vim.fn.win_getid(vim.fn.winnr("#"))
  end

  local bufnr = vim.api.nvim_win_get_buf(winid)

  -- 获取选区行号
  local start_line = vim.fn.line("'<", winid)
  local end_line = vim.fn.line("'>", winid)

  -- 判断是否是可视模式选区
  local mode = vim.fn.visualmode()
  local lines
  if start_line ~= end_line and (mode == "v" or mode == "V" or mode == "\22") then
    lines = "<" .. start_line .. "," .. end_line .. ">"
  else
    lines = "#" .. vim.fn.line(".", winid)
  end

  -- 返回上下文：📄 File: filename:#line 或 📄 File: filename:<start,end>
  return "📄 File: " .. vim.api.nvim_buf_get_name(bufnr) .. ":" .. lines .. aicoding.engine.context.buffer()
end

--- Chat 编辑模式：清空提示并进入插入模式
_G.AICodingEdit = function() -- 全局 （需要被 VimL 函数访问）
  -- 清空提示
  vim.fn.call("PrettyTipsToggle", { "" })

  -- 移动到最后一行
  vim.cmd("normal! G")

  -- 进入插入模式
  vim.cmd("startinsert")
end

--- Chat 发送模式：追加上下文并提交
_G.AICodingSend = function()
  -- 退出插入模式
  vim.cmd("stopinsert")

  local prompt = vim.fn.getline(".")

  local command = prompt:match("^%s*(%S)") == "/"

  -- 过滤掉命令
  if not command then
    -- 追加上下文到最后一行
    local context = aicoding_context()
    vim.api.nvim_buf_set_lines(0, -1, -1, false, { context, "" })

    -- 移动到最后一行
    vim.cmd("normal! G")

    -- 显示思考提示
    vim.fn.call("PrettyTipsToggle", { vim.g.aicoding_tips_thinking })
  end

  -- 提交
  aicoding.engine.chat.submit()
end

--- Chat 准备就绪：设置快捷键和提示
_G.AICodingReady = function()
  -- 退出插入模式
  vim.cmd("stopinsert")

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
local function aicoding_inline()
  -- 读取用户输入
  local prompt = vim.fn.input("🌹 AI Coding: ", "")

  if prompt == "" then
    vim.notify("⚠️ Empty input", vim.log.levels.WARN)
    return
  end

  local command = prompt:match("^%s*(%S)") == "/"

  if command then
    aicoding.engine.inline.submit(prompt)
  else
    local context = aicoding_context()

    -- 执行 inline 命令
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

-- 只定义Inline模式按键，其他交给 Finder
