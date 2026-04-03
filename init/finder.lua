-- =============================================================================
-- Telescope Finder 配置
-- =============================================================================
-- 说明：
--   本文件负责 Telescope 的菜单和全局按键绑定，包括：
--   1. finder.bindings - 扁平化菜单配置（所有功能在同一层级）
--   2. finder.launchers - 智能启动器（根据状态决定行为）
--   3. Telescope 窗口设置（autocmd 进入时配置）
--   4. 全局快捷键绑定（基于 finder.bindings 自动生成）
--
-- 设计理念：
--   - 保持与 Denite 一致的功能和按键绑定
--   - 所有菜单项在同一层级，无需多级导航
--   - 按键绑定在 finder.bindings 中统一定义，自动注册到全局
--
-- 架构：
--   finder.lua (前端/入口) → telescope.lua (后端/配置)
--   - finder.bindings 定义菜单 → attach_mappings 执行
--   - finder.launchers 调用 → telescope 返回的启动函数
-- =============================================================================

-- =============================================================================
-- 全局设置
-- =============================================================================

-- Finder 提示信息（显示在 Telescope prompt 上方）
vim.g.finder_tips = "⌨️ /: 开始搜索，j/k: 选择，Enter: 打开，Q: 退出 ⌨️"

local finder = {
  -- 加载 Telescope 功能模块
  engine = loadfile(vim.fn.expand("<sfile>:h") .. "/telescope.lua")(),

  -- augroup: Autocmd 组（监听 Chat 事件）
  augroup = vim.api.nvim_create_augroup("Finder", { clear = true }),

  -- Telescope Prompt 窗口的 bufnr（用于 close 操作）
  bufnr = -1, -- ⚠️ 虽然 bufnr > 0，但 nvim api 却认为 bufnr = 0 为当前 buffer

  -- 恢复状态
  resumed = false,
}

-- Telescope 是否处于活动状态
-- true = 正在 Telescope 窗口中（子菜单）
-- false = 不在 Telescope 窗口中（主菜单/其他）
finder.active = function()
  return vim.fn.bufwinid(finder.bufnr) > 0
end

-- 关闭 Telescope, 之后可恢复
_G.FinderHide = function()
  -- 关闭当前窗口
  if finder.active() then
    finder.engine.close(finder.bufnr)
  end

  -- 这里不清除窗口状态
end

-- 关闭 Telescope 并重置状态
_G.FinderClose = function() -- _G: 需要被 VimL 函数访问
  FinderHide()

  -- 清除窗口状态
  finder.bufnr = -1

  -- 这是一个恢复的窗口 => 打开主窗口
  if finder.resumed then
    finder.launchers.main()
  end

  -- 恢复默认值
  finder.resumed = false
end

-- =============================================================================
-- 功能启动器（Launchers）
-- =============================================================================
-- 说明：
--   封装了常用的 Telescope 功能，支持智能判断当前状态
--   例如：grep 会根据是否已在 Telescope 中决定是否使用 default_text

finder.launchers = {
  -- 文件搜索
  find = finder.engine.find,

  -- 缓冲区列表
  buffers = finder.engine.buffers,

  -- Messages
  messages = finder.engine.messages,

  -- Quickfix
  quickfix = finder.engine.quickfix,

  -- 项目搜索（智能 grep）
  -- 如果在 Telescope 中：直接打开 grep
  -- 如果不在：使用当前单词作为默认搜索词
  grep = function()
    if finder.active() then
      return finder.engine.grep()
    else
      return finder.engine.grep({ default_text = vim.fn.expand("<cword>") })
    end
  end,

  -- Chat（智能切换）
  -- 如果在 Telescope 中：打开 codecompanion
  -- 如果不在：切换 AI Chat 窗口
  codecompanion = function()
    if finder.active() then
      return finder.engine.codecompanion()
    else
      return vim.cmd("AICodingToggle")
    end
  end,

  -- LazyGit（智能切换）
  -- 如果在 Telescope 中：打开 lazygit
  -- 如果不在：执行 GitExplorer 命令
  lazygit = function()
    if finder.active() then
      return finder.engine.lazygit()
    else
      return vim.cmd("GitExplorer")
    end
  end,

  -- Nerdy 图标搜索
  nerdy = finder.engine.nerdy,

  -- Emoji 表情搜索
  emoji = finder.engine.emoji,
}

-- =============================================================================
-- 菜单绑定配置（Bindings）
-- =============================================================================
-- 格式说明：
--   name    : 显示文本（靠左）
--   key     : 快捷键显示（靠右，空字符串表示无快捷键）
--   close   : 执行前是否关闭菜单（默认 true）
--   command : 执行的命令 (string) 或 Lua 函数 (function)
--
-- 注意：使用数组格式保证菜单顺序（按定义顺序显示）

finder.bindings = {
  -- 文件搜索
  {
    name = "1. Finder",
    key = "<C-o>",
    close = false,
    command = finder.launchers.find,
  },

  -- 缓冲区列表
  {
    name = "2. Buffers",
    key = "<C-e>",
    close = false,
    command = finder.launchers.buffers,
  },

  -- 项目搜索（grep）
  {
    name = "3. Search",
    key = "<C-g>",
    close = false,
    command = finder.launchers.grep,
  },

  -- 格式化
  {
    name = "4. Format",
    key = "<F8>",
    close = true,
    command = "StyleFormat",
  },

  -- 打开 Chat
  {
    name = "5. Chat",
    key = "<F5>",
    close = true,
    command = finder.launchers.codecompanion,
  },

  -- 打开资源管理器
  {
    name = "6. Explorer",
    key = "<F9>",
    close = true,
    command = "FileExplorer",
  },

  -- 打开标签列表
  {
    name = "7. Taglist",
    key = "<F10>",
    close = true,
    command = "TagsExplorer",
  },

  -- Messages
  {
    name = "8. Messages",
    key = "",
    close = true,
    command = finder.launchers.messages,
  },

  -- Quickfix
  {
    name = "9. Quickfix",
    key = "",
    close = false,
    command = finder.launchers.quickfix,
  },

  -- 打开帮助
  {
    name = "?. Help",
    key = "",
    close = true,
    command = function()
      vim.cmd("edit " .. vim.g.pretty_home .. "/README.md")
    end,
  },

  -- 打开 LazyGit
  {
    name = ".. LazyGit",
    key = "<F12>",
    close = true,
    command = finder.launchers.lazygit,
  },

  -- Nerdy 搜索
  {
    name = ".. Nerdy",
    key = "",
    close = false,
    command = finder.launchers.nerdy,
  },

  -- Emoji 搜索
  {
    name = ".. Emoji",
    key = "",
    close = false,
    command = finder.launchers.emoji,
  },

  -- 退出确认
  {
    name = ".. Quit",
    key = "",
    close = true,
    command = "confirm quit",
  },
}

-- =============================================================================
-- Finder 菜单功能
-- =============================================================================

--- 执行命令（支持 string 和 function 两种类型）
---@param cmd string|function 要执行的命令或函数
---@return nil
local function finder_execute_command(cmd)
  if type(cmd) == "function" then
    -- Lua 函数：直接调用
    cmd()
  elseif type(cmd) == "string" then
    -- Vim 命令：执行
    vim.cmd(cmd)
  end
end

--- 显示主菜单
finder.launchers.main = function()
  local builtin = require("telescope.builtin")
  local finders = require("telescope.finders")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local entry_display = require("telescope.pickers.entry_display")

  -- 从 finder.bindings 构建菜单数据
  local bindings = finder.bindings

  -- 构建显示列表（3 部分：Text, Keymap, Command）
  local results = {}
  for _, item in ipairs(bindings) do
    table.insert(results, {
      text = item.name,
      keymap = item.key or "",
      action = item.command,
      close = item.close or false,
    })
  end

  -- 创建显示配置：Text 靠左，Keymap 靠右
  local displayer = entry_display.create({
    separator = " ",
    -- 左侧：Text (80% 宽度)  右侧：Keymap (剩余宽度)
    items = { { width = 0.8 }, { remaining = true } },
  })

  -- 调用 builtin.find_files 显示菜单
  builtin.find_files({
    -- 覆盖 find_files 设置
    results_title = "✨ Commands ✨",
    prompt_title = vim.g.finder_tips,

    -- 自定义 finder（使用菜单数据）
    finder = finders.new_table({
      results = results,
      ---@param entry {text: string, keymap: string, action: function|string, close: boolean}
      entry_maker = function(entry)
        -- 创建显示：| Text (靠左) Keymap (靠右) |
        local make_display = function()
          return displayer({ { entry.text }, { entry.keymap } })
        end

        return {
          value = entry, -- 传递整个 entry 对象
          display = make_display,
          -- 不匹配快捷键（只匹配 text）
          ordinal = entry.text,
          text = entry.text,
          keymap = entry.keymap,
        }
      end,
    }),

    -- 自定义按键映射
    attach_mappings = function(prompt_bufnr, map)
      -- 替换默认选择行为：执行菜单项的 command
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        if selection and selection.value then
          local entry = selection.value

          -- 关闭菜单（如果配置了 close = true）
          if entry.close ~= false then
            vim.schedule(FinderClose)
          end

          -- 执行命令
          vim.schedule(function()
            finder_execute_command(entry.action)
          end)
        end
      end)
      -- 返回 true：保留 popup_defaults 中定义的默认映射
      -- 返回 false：清空所有默认映射（只保留上面 map() 定义的）
      return true
    end,
  })
end

-- =============================================================================
-- Telescope 窗口设置
-- =============================================================================
-- 当进入 Telescope 窗口时调用设置函数
vim.api.nvim_create_autocmd("FileType", {
  group = finder.augroup,
  pattern = "TelescopePrompt",
  callback = function()
    -- Prompt 窗口 bufnr（telescope 很多操作都需要此 bufnr）
    finder.bufnr = vim.api.nvim_get_current_buf()

    -- PrettyCursorToggle() - 调用 VimL 函数
    vim.fn.call("PrettyCursorToggle", {})

    -- 设置退出快捷键行为
    vim.fn.call("PrettyExitWith", { "lua FinderClose()", "lua FinderHide()" })

    -- 设置插入模式进入快捷键行为
    vim.fn.call("PrettyInsertEnter", { "lua FinderReady()" })

    -- 设置插入模式离开快捷键行为
    vim.fn.call("PrettyInsertLeave", { "stopinsert" })

    -- Normal 模式：'/' 编辑
    vim.keymap.set("n", "/", FinderReady, { buffer = true, silent = true })

    -- Insert 模式：按 Enter 停止插入
    vim.keymap.set("i", "<CR>", function()
      vim.cmd("stopinsert")
    end, { buffer = true, silent = true })
  end,
})

_G.FinderReady = function()
  -- 清除提示
  vim.fn.call("PrettyTipsToggle", { "" })

  -- 进入插入模式 （总在最后插入)
  vim.cmd("startinsert!")
end

-- =============================================================================
-- FinderOpen 窗口开启逻辑
-- =============================================================================
vim.api.nvim_create_user_command("FinderOpen", function(opts)
  -- vim.notify("⚡️ " .. vim.inspect(opts))

  if not opts or not opts.args or opts.args == "" then
    -- 恢复逻辑
    if finder.bufnr > 0 then
      finder.engine.resume()

      if finder.active() then
        vim.notify("✨ Finder resumed")

        finder.resumed = true
        return
      end
    end

    -- 打开主窗口
    finder.launchers.main()

    vim.notify("✨ Finder ready")
    return
  end

  local command = opts.args
  local bufnr = tonumber(command)
  if bufnr then
    vim.notify("⚡️ Load bufnr " .. bufnr .. " to quickfix")

    vim.fn.PrettyQuickfixLoad(bufnr, " " .. (vim.fn.bufname(bufnr) or bufnr))

    local winid = vim.fn.bufwinid(bufnr)

    -- vim.notify("⚡️ " .. vim.inspect(vim.fn.getwininfo(winid)[1]))

    -- 不要在这关闭窗口，可能造成不可控的结果
    -- 需要关闭窗口就主动调用 PrettyQuickfixLoad 然后关闭窗口

    command = "quickfix"
  end

  local launcher = finder.launchers[command]
  if not launcher or type(launcher) ~= "function" then
    vim.notify("❌ bad command " .. command, vim.log.levels.ERROR)
    return
  end

  local settings = {}
  if command == "quickfix" then
    -- 根据参数执行不同的 quickfix 逻辑
    settings.nr = "$" -- FIXME: find out the right qf nr or id
  end

  -- 关闭存在的窗口
  if finder.active() then
    finder.engine.close()
  end

  local ok = launcher(settings)
  if not ok or ok ~= false then
    vim.notify("✨ Finder " .. command .. " success")
  end
end, {
  nargs = "*",
  desc = "Finder Open",
})

vim.api.nvim_create_user_command("FinderInspect", function()
  vim.notify(vim.inspect(finder))
end, { desc = "Finder Inspect" })

-- =============================================================================
-- Telescope 窗口按键绑定（全局）
-- =============================================================================

-- --- 自动注册快捷键 ---
-- 根据 finder.bindings 中定义的 key 自动设置（Normal 模式）
-- 只在 bindings 中定义了 key 且 key 不为空时注册
for i, item in ipairs(finder.bindings) do
  -- 检查是否定义了快捷键和命令
  if item.key and item.key ~= "" and item.command then
    -- Normal 模式 only
    vim.keymap.set("n", item.key, function()
      finder_execute_command(item.command)
    end, { silent = true, desc = "Finder: " .. item.name })
  end
end

-- --- 主菜单 ---
-- Normal 模式：按 Enter 打开主菜单
vim.keymap.set({ "n" }, "<Enter>", ":FinderOpen<CR>", { silent = true })

--
