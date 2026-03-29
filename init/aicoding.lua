-- =============================================================================
-- AI: CodeCompanion.nvim - Lua 入口配置
-- =============================================================================
-- 说明：
--   本文件负责 CodeCompanion 的 VimScript 函数迁移，包括：
--   1. 全局变量设置（tips、filetype）
--   2. API Key 检查（无 Key 时不加载）
--   3. AI 函数（context、inline、chat 相关）
--   4. 命令定义（AICodingInline、AICodingToggle 等）
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

vim.g.aicoding_tips_ready = "🌹 AI Coding Ready ✨!  Enter: 发送消息，Shift-Enter: 换行 "
vim.g.aicoding_tips_thinking = "🤖 AI is thinking ..."
vim.g.aicoding_tips_inline = "🌹 AI Coding: "
vim.g.aicoding_tips_inline_done = "✨ AI Coding Finished"

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

  -- filetype: AI Coding 窗口的 filetype（用于判断是否在 Chat 中）
  filetype = "codecompanion",
}

-- =============================================================================
-- API Key 检查
-- =============================================================================

aicoding.checking = function()
  if not os.getenv("AICODING_BASE_URL") then
    vim.notify("⚠️ $AICODING_BASE_URL is empty")
  end

  if not os.getenv("AICODING_API_KEY") then
    vim.notify("❌ $AICODING_API_KEY is empty")
    return false
  end

  if not os.getenv("AICODING_MODEL") then
    vim.notify("❌ $AICODING_MODEL is empty")
    return false
  end

  return true
end

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
local function aicoding_context(opts)
  -- 获取正确的 winid 和 bufnr
  local winid = vim.api.nvim_get_current_win()

  -- 如果当前是 AI chat 窗口，使用上一个窗口（用户代码所在的窗口）
  if vim.bo.filetype == aicoding.filetype then
    winid = vim.fn.win_getid(vim.fn.winnr("#"))
  end

  local bufnr = vim.api.nvim_win_get_buf(winid)

  -- nvim_buf_get_name 输出为绝对路径
  local bufname = vim.fn.bufname(bufnr)

  if bufname == "" then
    return ""
  end

  -- 获取选区行号（vim.fn.line 支持 winid 参数）
  if opts and opts.range > 0 then
    lines = "<" .. opts.line1 .. "," .. opts.line2 .. ">" -- 选区格式
  else
    lines = "#" .. vim.fn.line(".", winid) -- 单行格式
  end

  -- 返回上下文：📄 File: filename:#line 或 📄 File: filename:<start,end>
  return "📄 File: " .. bufname .. ":" .. lines .. aicoding.engine.context.buffer()
end

--- Chat 编辑模式：清空提示并进入插入模式
--- 行为：清空 tips → 移动到最后一行 → 进入插入模式
_G.AICodingEdit = function() -- 全局函数（需要被 VimL 函数访问）
  vim.fn.call("PrettyTipsToggle", { "" }) -- 清空提示
  vim.cmd("normal! G") -- 移动到最后一行
  vim.cmd("startinsert") -- 进入插入模式
end

--- Chat 准备就绪：设置快捷键和提示
--- 行为：
---   1. 退出插入模式
---   2. 显示就绪提示
_G.AICodingReady = function()
  vim.cmd("stopinsert") -- 退出插入模式
  vim.fn.call("PrettyTipsToggle", { vim.g.aicoding_tips_ready }) -- 显示就绪提示
  vim.notify("✅ AI Coding Ready") -- 状态栏同步显示
end

-- =============================================================================
-- Inline 模式：读取用户输入并执行
-- =============================================================================
--- Inline 模式：读取用户输入并执行
--- 行为：
---   1. 读取用户输入（input 对话框）
---   2. 检测是否以 / 开头（命令模式）
---   3. 命令模式：直接提交（如 /refactor）
---   4. 非命令模式：追加上下文 + 用户输入
local function aicoding_inline(args)
  local opts = args or {}

  -- 获取选区范围
  if vim.fn.visualmode() then
    if not opts.range or opts.range == 0 then
      opts.line1 = vim.fn.line("'<")
      opts.line2 = vim.fn.line("'>")
      opts.range = opts.line1 == opts.line2 and 1 or 2
    end
  end

  -- vim.notify(vim.inspect(opts), vim.log.levels.WARN)

  if #vim.trim(opts.args or "") == 0 then
    -- 读取用户输入
    vim.ui.input({ prompt = vim.g.aicoding_tips_inline }, function(input)
      opts.args = input
    end)
  end

  if not opts.args or opts.args == "" then
    vim.notify("⚠️ Empty input", vim.log.levels.WARN)
    return
  end

  -- 检测命令模式
  local command = opts.args:find("^%s*/") ~= nil

  -- 命令模式：直接提交（不追加上下文）
  if not command then
    local context = aicoding_context(opts)
    table.insert(opts.fargs, 1, context)
  end

  aicoding.engine.inline.submit(opts, function(callback_args)
    vim.notify(vim.g.aicoding_tips_inline_done)
  end)

  -- 显示提示
  vim.notify(vim.g.aicoding_tips_thinking)
end

-- =============================================================================
-- 命令定义
-- =============================================================================

vim.api.nvim_create_user_command("AICodingInline", function()
  if not aicoding.checking() then
    return
  end

  aicoding_inline()
end, {
  nargs = "*",
  range = true,
  desc = "AI Inline coding",
})

vim.api.nvim_create_user_command("AICodingLaunch", function(opts)
  if not aicoding.checking() then
    return
  end

  aicoding.engine.chat.launch(opts)
end, {
  nargs = "*",
  desc = "AI Coding Actions",
})

vim.api.nvim_create_user_command("AICodingToggle", function()
  if not aicoding.checking() then
    return
  end

  aicoding.engine.chat.toggle({}, function(args)
    -- vim.notify(vim.inspect(args))
    if args and args.opened then
      -- 设置退出快捷键行为
      vim.fn.call("PrettyExitWith", { ":AICodingToggle" })

      -- 设置插入模式进入快捷键行为
      vim.fn.call("PrettyInsertEnter", { "lua AICodingEdit()" })

      -- 设置插入模式离开快捷键行为
      vim.fn.call("PrettyInsertLeave", { "lua AICodingReady()" })

      -- Normal 模式：Enter 编辑
      vim.keymap.set("n", "<CR>", function()
        AICodingEdit()
      end, { buffer = true, silent = true, desc = "AI Coding: Edit" })

      -- Insert 模式：Enter 发送
      vim.keymap.set("i", "<CR>", function()
        vim.cmd("AICodingSubmit")
      end, { buffer = true, silent = true, desc = "AI Coding: Send" })

      -- 显示就绪提示
      vim.schedule(AICodingReady)
    end
  end)
end, { desc = "AI Coding Toggle" })

vim.api.nvim_create_user_command("AICodingSubmit", function()
  vim.cmd("stopinsert") -- 退出插入模式

  local prompt = vim.fn.getline(".")
  local command = prompt:match("^%s*(%S)") == "/" -- 检测命令模式

  -- 过滤掉命令（命令模式不追加上下文）
  if not command then
    -- 追加上下文到最后一行
    local context = aicoding_context()
    vim.api.nvim_buf_set_lines(0, -1, -1, false, { context, "" })

    vim.cmd("normal! G") -- 移动到最后一行
  end

  -- 显示思考提示
  vim.schedule(function()
    vim.fn.call("PrettyTipsToggle", { vim.g.aicoding_tips_thinking })
  end)

  -- 提交
  aicoding.engine.chat.submit({}, function(args)
    -- 完成
    vim.schedule(AICodingReady)
  end)
end, { desc = "AI Coding Submit" })

-- =============================================================================
-- 快捷键
-- =============================================================================

-- Inline 模式：Normal & Visual 模式 <leader>ai
vim.keymap.set({ "n", "v" }, "<leader>ai", function(opts)
  -- 使用命令方式调用，这样可以利用 range 参数
  local keys = vim.api.nvim_replace_termcodes("<Esc>:AICodingInline<CR>", true, true, true)
  vim.api.nvim_feedkeys(keys, "n", true)
end, { silent = true, desc = "AI Inline" })

-- 只定义 Inline 模式按键，其他交给 Finder
