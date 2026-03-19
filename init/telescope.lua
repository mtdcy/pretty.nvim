--[[
-- =============================================================================
-- Telescope 配置文件
-- =============================================================================
-- 说明：
--   本文件负责 Telescope 的核心配置，包括：
--   1. UI 配置（布局、主题、提示符等）
--   2. 功能配置（排序器、文件忽略等）
--   3. 返回扩展启动函数（find/grep/buffers/nerdy/emoji/lazygit/codecompanion）
--
-- 使用方式：
--   local telescope = require('init.telescope')
--   telescope.find()           -- 文件搜索
--   telescope.grep({opts})     -- 项目搜索
--   telescope.buffers()        -- 缓冲区列表
--   telescope.nerdy()          -- Nerdy 图标搜索
--   telescope.emoji()          -- Emoji 表情搜索
--   telescope.lazygit()        -- LazyGit
--   telescope.codecompanion()  -- CodeCompanion
--   telescope.active()         -- 检查 Telescope 是否打开
-- =============================================================================
--]]

-- =============================================================================
-- UI 配置
-- =============================================================================

-- Popup 布局配置
local popup_layout_config = {
  prompt_position = "bottom", -- prompt 在底部

  anchor = "S", -- 底部锚点
  anchor_padding = 1, -- 距离底部 1 行

  -- 高度配置：50% 屏幕高度，最大 13 行（9 行内容 + 4 行边框/标题）
  height = { 0.5, max = 9 + 4 },

  -- 宽度配置：30% 屏幕宽度，最小 72 列
  width = { 0.3, min = 72 },
}

-- Popup 主题（基于 dropdown）
local popup = require("telescope.themes").get_dropdown({
  -- 初始模式：normal = 不自动进入插入模式
  initial_mode = "normal",

  -- 提示符配置
  prompt_title = vim.g.finder_tips,
  results_title = "✨ Finder ✨",
  prompt_prefix = " ",
  selection_caret = "➤ ",
  color_devicons = true,

  -- 排序策略：从下往上（ascending = 结果从底部开始）
  sorting_strategy = "ascending",

  -- 布局策略：center（居中显示）
  layout_strategy = "center",
  layout_config = popup_layout_config,

  -- 预览器配置
  previewer = true,
  dynamic_preview_title = true, -- 显示文件名作为标题
  preview = {
    hide_on_startup = true, -- 启动时隐藏预览
    timeout = 60, -- 预览超时时间（毫秒）
  },

  -- 文件忽略模式（不搜索这些文件/目录）
  file_ignore_patterns = {
    "node_modules",
    "%.git/",
    "%.hg/",
    "%.bzr/",
    "%.svn/",
    "%.ccache/",
    "tags",
    "tags%-.*",
    "*~",
    "*.o",
    "*.exe",
    "*.bak",
    "*.a",
    "*.so",
    "*.so.*",
    ".DS_Store",
    "*.pyc",
    "*.sw[po]",
    "*.class",
  },

  -- 路径显示方式：截断长路径
  path_display = { "truncate" },

  -- 历史记录配置
  history = {
    path = vim.fn.stdpath("data") .. "/telescope_history",
    limit = 100,
  },

  -- =============================================================
  -- 按键绑定：全部禁用（在 finder.lua 中使用 autocmd 定义）
  -- =============================================================
  mappings = {
    i = {}, -- Insert 模式
    n = {}, -- Normal 模式
  },

  -- =============================================================
  -- 自动补全：禁用
  -- =============================================================
  completion = {
    complete = false,
  },
})

-- Telescope 初始化配置
require("telescope").setup({
  -- 默认配置
  defaults = popup,

  -- pickers 特定配置
  pickers = {
    -- 文件搜索
    find_files = {
      results_title = "📄 Files 📄",
      prompt_title = vim.g.finder_tips,
      hidden = true, -- 搜索隐藏文件
      find_command = { "rg", "--files", "--glob", "!.git", "--hidden" },
    },

    -- 缓冲区列表
    buffers = {
      results_title = "📝 Buffers 📝",
      prompt_title = vim.g.finder_tips,
      sort_lastused = true, -- 按最后使用时间排序
      sort_mru = true, -- 最近使用的在前
    },

    -- 实时搜索
    live_grep = {
      results_title = "🔎 Search 🔎",
      prompt_title = vim.g.finder_tips,
      additional_args = function()
        return { "--hidden", "--glob", "!.git" }
      end,
    },
  },

  -- 扩展配置
  extensions = {
    -- LazyGit 配置
    lazygit = {
      use_ssh_address = false,
    },

    -- CodeCompanion 配置
    codecompanion = {
      -- 使用默认配置
    },

    -- FZY 原生排序器（覆盖默认排序器）
    fzy_native = {
      override_generic_sorter = true,
      override_file_sorter = true,
    },
  },
})

-- 明确开启已经安装的扩展（按加载顺序）
require("telescope").load_extension("fzy_native")
require("telescope").load_extension("ui-select")
require("telescope").load_extension("nerdy")
require("telescope").load_extension("emoji")
require("telescope").load_extension("lazygit")
require("telescope").load_extension("codecompanion")

-- =============================================================================
-- 安全删除 Buffer（覆盖 Telescope 默认行为）
-- =============================================================================
-- 问题：Telescope 默认使用 vim.api.nvim_buf_delete() 会关闭分割窗口
-- 解决：检测最后一个 buffer 时提示用 ':qa'，不执行删除操作

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

actions.delete_buffer = function(prompt_bufnr)
  local current_picker = action_state.get_current_picker(prompt_bufnr)

  current_picker:delete_selection(function(selection)
    -- 检查是否是最后一个 listed buffer
    local listed_count = 0
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_get_option(buf, "buflisted") then
        listed_count = listed_count + 1
      end
    end

    -- 如果是最后一个 buffer，提示但不删除
    if listed_count <= 1 then
      vim.notify("最后一个 buffer，请使用 :qa 退出", vim.log.levels.WARN, { title = "Telescope" })
      return false
    end

    -- 不是最后一个 buffer，执行删除
    vim.cmd("bdelete " .. selection.bufnr)
    return true
  end)
end

-- =============================================================================
-- 返回扩展启动函数
-- =============================================================================
-- 说明：
--   使用 ':Telescope nerdy' 不会应用默认主题设置（某些参数会被覆盖）
--   为了保持统一的 UI，自定义启动函数并返回模块

return {
  -- 文件搜索
  find = function(opts)
    require("telescope.builtin").find_files(opts)
  end,

  -- 项目搜索（grep）
  grep = function(opts)
    require("telescope.builtin").live_grep(opts)
  end,

  -- 缓冲区列表
  buffers = function(opts)
    require("telescope.builtin").buffers(opts)
  end,

  -- Nerdy 图标搜索
  nerdy = function()
    require("telescope").extensions.nerdy.nerdy(popup)
  end,

  -- Emoji 表情搜索
  emoji = function()
    require("telescope").extensions.emoji.emoji(popup)
  end,

  -- LazyGit
  lazygit = function()
    require("telescope").extensions.lazygit.lazygit(popup)
  end,

  -- CodeCompanion
  codecompanion = function()
    require("telescope").extensions.codecompanion.codecompanion(popup)
  end,

  -- 检查 Telescope 是否处于活动状态
  -- 返回值：true = 已打开，false = 未打开
  active = function()
    -- 方法 1：检查当前 buffer 的 filetype
    local bufnr = vim.api.nvim_get_current_buf()
    local filetype = vim.bo[bufnr].filetype

    if filetype == "TelescopePrompt" then
      return true
    end

    -- 方法 2：检查所有窗口是否有 TelescopePrompt
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
      bufnr = vim.api.nvim_win_get_buf(winid)
      filetype = vim.bo[bufnr].filetype

      if filetype == "TelescopePrompt" then
        return true
      end
    end

    return false
  end,

  -- =============================================================================
  -- Buffer 相关操作
  -- =============================================================================

  -- 选择第 index 项并打开
  -- @param index number 要选择的项（从 1 开始）
  select = function(index)
    if index and index > 0 then
      local picker = require("telescope.actions.state").get_current_picker(vim.g.finder_bufnr)

      -- 获取对应行号（index → row）
      local row = picker:get_row(index)
      if row then
        -- 设置选中
        picker:set_selection(row)
      end
    end

    -- 执行默认操作（打开）
    require("telescope.actions").select_default(vim.g.finder_bufnr)
  end,

  -- 关闭 Telescope
  close = function(opts)
    require("telescope.actions").close(vim.g.finder_bufnr)
  end,

  -- 切换预览
  preview = function(opts)
    require("telescope.actions.layout").toggle_preview(vim.g.finder_bufnr)
  end,

  -- 删除选中的 buffer
  delete = function(opts)
    require("telescope.actions").delete_buffer(vim.g.finder_bufnr)
  end,
}
