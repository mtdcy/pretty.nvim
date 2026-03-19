-- =============================================================================
-- Telescope Finder 配置
-- =============================================================================
-- 说明：
--   本文件负责 Telescope 的按键绑定和菜单功能，包括：
--   1. finder.bindings 菜单配置（扁平化设计）
--   2. Telescope 窗口设置（通过 autocmd）
--   3. 全局快捷键绑定（Finder/Buffer/Search 等）
--
-- 设计理念：
--   - 保持与 Denite 一致的功能和按键绑定
--   - 所有菜单项在同一层级，无需多级导航
--   - 按键绑定在 finder 中统一定义
-- =============================================================================

-- =============================================================================
-- 全局设置
-- =============================================================================

-- Finder 提示信息（显示在 Telescope prompt 上方）
vim.g.finder_tips = "⌨️ /: 开始搜索，j/k: 选择，Enter: 打开，Q: 退出 ⌨️"

-- 全局 finder 对象（需要被 VimL 函数访问）
finder = {
  -- 加载 Telescope 功能模块
  telescope = loadfile(vim.fn.expand("<sfile>:h") .. "/init/telescope.lua")(),

  -- Telescope 是否处于活动状态（用于判断是否从子菜单返回）
  active = false,
}

-- 关闭 Telescope 并重置状态
finder.close = function()
  finder.active = false
  finder.telescope.close()
end

-- =============================================================================
-- 功能启动器（Launchers）
-- =============================================================================
-- 说明：
--   封装了常用的 Telescope 功能，支持智能判断当前状态
--   例如：grep 会根据是否已在 Telescope 中决定是否使用 default_text

finder.launchers = {
  -- 文件搜索
  find = finder.telescope.find,

  -- 缓冲区列表
  buffers = finder.telescope.buffers,

  -- 项目搜索（智能 grep）
  -- 如果在 Telescope 中：直接打开 grep
  -- 如果不在：使用当前单词作为默认搜索词
  grep = function()
    if finder.active then
      finder.telescope.grep()
    else
      finder.telescope.grep({ default_text = vim.fn.expand("<cword>") })
    end
  end,

  -- Chat（智能切换）
  -- 如果在 Telescope 中：打开 codecompanion
  -- 如果不在：切换 AI Chat 窗口
  codecompanion = function()
    if finder.active then
      finder.telescope.codecompanion()
    else
      vim.cmd("AIChatToggle")
    end
  end,

  -- LazyGit（智能切换）
  -- 如果在 Telescope 中：打开 lazygit
  -- 如果不在：执行 GitOpen 命令
  lazygit = function()
    if finder.active then
      finder.telescope.lazygit()
    else
      vim.cmd("GitOpen")
    end
  end,

  -- Nerdy 图标搜索
  nerdy = finder.telescope.nerdy,

  -- Emoji 表情搜索
  emoji = finder.telescope.emoji,
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

  -- 打开 Chat
  {
    name = "4. Chat",
    key = "<F5>",
    close = false,
    command = finder.launchers.codecompanion,
  },

  -- 格式化
  {
    name = "5. Format",
    key = "<F8>",
    close = true,
    command = "ALEFix",
  },

  -- 打开资源管理器
  {
    name = "6. Explorer",
    key = "<F9>",
    close = true,
    command = "ExplorerFocus",
  },

  -- 打开标签列表
  {
    name = "7. Taglist",
    key = "<F10>",
    close = true,
    command = "TaglistFocus",
  },

  -- 打开 LazyGit
  {
    name = "8. LazyGit",
    key = "<F12>",
    close = true,
    command = finder.launchers.lazygit,
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

  -- 设置活动状态标志
  finder.active = true

  -- 构建显示列表（3 部分：Text, Keymap, Command）
  local results = {}
  for _, item in ipairs(bindings) do
    table.insert(results, {
      text = item.name,
      keymap = item.key or "",
      action = item.command,
      close = item.close or true,
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
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        if selection and selection.value then
          local entry = selection.value

          -- 关闭菜单（如果配置了 close = true）
          if entry.close ~= false then
            actions.close(prompt_bufnr)
          end

          -- 执行命令（不使用 vim.schedule，避免 active 判断不准）
          finder_execute_command(entry.action)

          -- 重置活动状态标志
          finder.active = false
        end
      end)
      return true
    end,
  })
end

-- =============================================================================
-- Telescope 窗口设置（通过 autocmd 实现）
-- =============================================================================

-- Telescope 窗口内的按键绑定配置
finder.buffers = {
  mappings = {
    -- --- 预览 ---
    -- Normal 模式：按 p 切换预览
    {
      key = "p",
      command = finder.telescope.preview,
    },

    -- --- 缓冲区 ---
    -- Normal 模式：按 w 删除选中的缓冲区
    {
      key = "w",
      command = finder.telescope.delete,
    },

    -- --- 选择 ---
    -- Normal 模式：按 Space 或 Enter 打开选中的项
    {
      key = "<Space>",
      command = finder.telescope.select,
    },
    {
      key = "<Enter>",
      command = finder.telescope.select,
    },
  },
}

-- 创建 augroup
local finder_augroup = vim.api.nvim_create_augroup("FinderKeymaps", { clear = true })

-- 当进入 Telescope 窗口时调用设置函数
vim.api.nvim_create_autocmd("FileType", {
  group = finder_augroup,
  pattern = "TelescopePrompt",
  callback = function()
    -- Prompt 窗口 bufnr（telescope 很多操作都需要此 bufnr）
    vim.g.finder_bufnr = vim.api.nvim_get_current_buf()

    -- HideCursor() - 调用 VimL 函数
    vim.fn.call("HideCursor", {})

    -- CloseWith('FinderExit') - 调用 VimL 函数
    vim.fn.call("CloseWith", { "lua finder.close()" })

    -- Normal 模式：按 / 进入插入模式（总是在最后插入）
    vim.fn.call("StartInsertWith", { "call ShowTips('')<CR>:startinsert!" })

    -- Esc: 停止插入模式 (Insert Mode)
    vim.fn.call("StopInsertWith", { "stopinsert" })

    -- Insert 模式：按 Enter 停止插入
    vim.keymap.set("i", "<CR>", "<C-o>:stopinsert<CR>", { buffer = true, silent = true })

    -- 注册 Telescope 窗口内的按键绑定
    for _, item in ipairs(finder.buffers.mappings) do
      vim.keymap.set("n", item.key, function()
        finder_execute_command(item.command)
      end, { buffer = true, silent = true })
    end

    -- 注册数字键 1-9（快速选择第 n 项）
    for i = 1, 9 do
      vim.keymap.set("n", tostring(i), function()
        finder.telescope.select(i)
      end, { buffer = true, silent = true, desc = "Select item " .. i })
    end
  end,
})

-- =============================================================================
-- Telescope 窗口按键绑定（全局）
-- =============================================================================

-- --- 自动注册快捷键 ---
-- 根据 finder.bindings 中定义的 key 自动设置（Normal 模式）
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
vim.keymap.set({ "n" }, "<Enter>", finder.launchers.main, { silent = true })
