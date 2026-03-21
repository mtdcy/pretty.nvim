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

local actions = require("telescope.actions")
local state = require("telescope.actions.state")
local layout = require("telescope.actions.layout")

-- Popup 布局配置
local popup_layout = {
  -- 布局策略：center（居中显示）
  layout_strategy = "center",

  layout_config = {
    prompt_position = "bottom", -- prompt 在底部

    anchor = "S", -- 底部锚点
    anchor_padding = 1, -- 距离底部 1 行

    -- 高度配置：50% 屏幕高度，最大 13 行（9 行内容 + 4 行边框/标题）
    height = { 0.5, max = 9 + 4 },

    -- 宽度配置：30% 屏幕宽度，最小 72 列
    width = { 0.3, min = 72 },
  },
}

-- =============================================================
-- 自定义按键绑定
-- =============================================================
-- 说明：
-- 1. default_mappings = { i = {}, n = {} } 清空所有默认映射
-- 2. mappings 设置自定义映射

local function select_by_index(index)
  return function(prompt_bufnr)
    local picker = state.get_current_picker(prompt_bufnr)
    -- 设置选中
    vim.schedule(function()
      picker:set_selection(index - 1)
      actions.select_default(prompt_bufnr)
    end)
    return ""
  end
end

-- 参考：https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/mappings.lua
local popup_mappings = {
  -- Insert 模式
  i = {
    ["<LeftMouse>"] = {
      actions.mouse_click,
      type = "action",
      opts = { expr = true },
    },
    ["<2-LeftMouse>"] = {
      actions.double_mouse_click,
      type = "action",
      opts = { expr = true },
    },
  },
  -- Normal 模式
  n = {
    -- 使用 Finder 的 close 逻辑
    -- ["Q"] = actions.close,

    ["<CR>"] = actions.select_default,
    ["<Space>"] = actions.select_default,

    ["j"] = actions.move_selection_next,
    ["k"] = actions.move_selection_previous,

    ["p"] = layout.toggle_preview,

    ["1"] = select_by_index(1),
    ["2"] = select_by_index(2),
    ["3"] = select_by_index(3),
    ["4"] = select_by_index(4),
    ["5"] = select_by_index(5),
    ["6"] = select_by_index(6),
    ["7"] = select_by_index(7),
    ["8"] = select_by_index(8),
    ["9"] = select_by_index(9),

    ["<LeftMouse>"] = {
      actions.mouse_click,
      type = "action",
      opts = { expr = true },
    },
    ["<2-LeftMouse>"] = {
      actions.double_mouse_click,
      type = "action",
      opts = { expr = true },
    },
  },
}

local popup_buffers_mappings = vim.tbl_extend("force", popup_mappings, {
  -- Normal 模式
  n = {
    ["w"] = actions.delete_buffer,
  },
})

-- Popup 主题（基于 dropdown）
local popup_defaults = vim.tbl_extend("force", require("telescope.themes").get_dropdown(popup_layout), {
  -- 初始模式：normal = 不自动进入插入模式
  initial_mode = "normal",

  -- 提示符配置
  prompt_title = vim.g.finder_tips,
  results_title = "✨ Finder ✨",
  prompt_prefix = " ",
  selection_caret = "➤ ",
  color_devicons = true,

  -- 清空默认映射（关键！不能是 nil）
  default_mappings = { i = {}, n = {} },
  -- 自定义映射
  mappings = popup_mappings,

  -- 预览器配置
  previewer = true,
  dynamic_preview_title = true, -- 显示文件名作为标题
  preview = {
    hide_on_startup = true, -- 启动时隐藏预览
    timeout = 60, -- 预览超时时间（毫秒）
  },

  -- =============================================================
  -- 自动补全：禁用
  -- =============================================================
  completion = {
    complete = false,
  },

  -- for live_grep and grep_string
  vimgrep_arguments = vim.list_extend({ vim.g.pretty_rg_executable }, vim.deepcopy(vim.g.pretty_rg_options)),

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
})

-- Telescope 初始化配置
require("telescope.config").clear_defaults()
require("telescope").setup({
  -- 默认配置
  defaults = popup_defaults,

  -- pickers 特定配置
  pickers = {
    -- 文件搜索
    find_files = {
      results_title = "📄 Files 📄",
      prompt_title = vim.g.finder_tips,
      hidden = true, -- 搜索隐藏文件
      find_command = {
        unpack(popup_defaults.vimgrep_arguments),
        "--files",
      },
    },

    -- 缓冲区列表
    buffers = {
      results_title = "📝 Buffers 📝",
      prompt_title = vim.g.finder_tips,
      sort_lastused = true, -- 按最后使用时间排序
      sort_mru = true, -- 最近使用的在前
      mappings = popup_buffers_mappings,
    },

    -- 实时搜索
    live_grep = {
      results_title = "🔎 Search 🔎",
      prompt_title = vim.g.finder_tips,
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

actions.delete_buffer = function(prompt_bufnr)
  local current_picker = state.get_current_picker(prompt_bufnr)

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
    require("telescope").extensions.nerdy.nerdy(popup_defaults)
  end,

  -- Emoji 表情搜索
  emoji = function()
    require("telescope").extensions.emoji.emoji(popup_defaults)
  end,

  -- LazyGit
  lazygit = function()
    require("telescope").extensions.lazygit.lazygit(popup_defaults)
  end,

  -- CodeCompanion
  codecompanion = function()
    require("telescope").extensions.codecompanion.codecompanion(popup_defaults)
  end,

  close = actions.close
}
