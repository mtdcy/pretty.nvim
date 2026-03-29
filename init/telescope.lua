--[[
-- =============================================================================
-- Telescope 配置文件
-- =============================================================================
-- 说明：
--   本文件负责 Telescope 的核心配置，包括：
--   1. UI 配置（布局、主题、提示符等）
--   2. 按键绑定（清空默认映射，自定义必要映射）
--   3. 扩展启动函数（find/grep/buffers/nerdy/emoji/lazygit/codecompanion）
--
-- 设计理念：
--   - default_mappings = { i = {}, n = {} } 清空所有默认映射
--   - 只保留必要的按键（j/k/Enter/Space/数字键/鼠标）
--   - 所有扩展使用统一的 popup_defaults 配置
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
-- =============================================================================
--]]

local actions = require("telescope.actions")
local state = require("telescope.actions.state")
local layout = require("telescope.actions.layout")
local sorters = require("telescope.sorters")

-- =============================================================================
-- UI 配置
-- =============================================================================

-- 这里我们有自己的搜索设置，所以使用 cmdline 的搜索颜色很合理
vim.api.nvim_set_hl(0, "TelescopePromptBorder", { link = "PrettyOrange" })
vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { link = "PrettyOrange" })
vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { link = "PrettyYellow" })

-- Popup 布局配置
local popup_layout = {
  -- 布局策略：center（居中显示）
  layout_strategy = "center",

  layout_config = {
    prompt_position = "bottom", -- prompt 在底部

    anchor = "S", -- 底部锚点
    anchor_padding = 5, -- 距离底部 1 行

    -- 高度配置：50% 屏幕高度，最大 13 行（9 行内容 + 4 行边框/标题）
    height = { 0.5, max = 9 + 4 },

    -- 宽度配置：30% 屏幕宽度，最小 72 列
    width = { 0.4, min = 72 },
  },
}

-- =============================================================
-- 自定义按键绑定
-- =============================================================
-- 说明：
-- 1. default_mappings = { i = {}, n = {} } 清空所有默认映射
-- 2. mappings 设置自定义映射

--- 按数字键选择对应项（1-9）
---@param index number 要选择的项（从 1 开始）
---@return function 返回一个函数，接收 prompt_bufnr 参数
---
-- 使用 vim.schedule 延迟执行，避免与 Telescope 的事件循环冲突
-- 返回空字符串防止按键输入到 prompt
local function select_by_index(index)
  return function(prompt_bufnr)
    local picker = state.get_current_picker(prompt_bufnr)
    -- 设置选中
    vim.schedule(function()
      picker:set_selection(index - 1) -- index 从 1 开始，row 从 0 开始
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

    ["<Down>"] = actions.move_selection_next,
    ["<Up>"] = actions.move_selection_previous,
  },
  -- Normal 模式
  n = {
    -- 使用 Finder 的 close 逻辑
    -- ["Q"] = actions.close,

    ["<CR>"] = actions.select_default,

    ["<Space>"] = actions.toggle_selection,

    ["j"] = actions.move_selection_next,
    ["k"] = actions.move_selection_previous,

    ["<Down>"] = actions.move_selection_next,
    ["<Up>"] = actions.move_selection_previous,

    ["p"] = layout.toggle_preview,

    -- save to quickfix: Ctrl+Shift+s
    ["<CS-s>"] = function(prompt_bufnr)
      -- 使用 FinderOpen 逻辑 <= send_to_qflist 总是替换当前内容。

      local picker = state.get_current_picker(prompt_bufnr)

      -- vim.notify(vim.inspect(picker))

      local title = vim.api.nvim_buf_get_lines(prompt_bufnr, 0, 1, false)[1]

      -- 将当前结果加载到 quickfix
      vim.fn.PrettyQuickfixLoad(picker.layout.results.bufnr, title)

      vim.notify("💡 Saved `" .. title .. "` to quickfix")
    end,

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

-- buffers picker 的专属映射（继承 popup_mappings 并添加额外映射）
local popup_buffers_mappings = vim.tbl_extend("force", popup_mappings, {
  -- Normal 模式
  n = {
    -- 安全删除 Buffer（覆盖 Telescope 默认行为）
    ["w"] = function(prompt_bufnr)
      local picker = state.get_current_picker(prompt_bufnr)

      picker:delete_selection(function(selection)
        -- 检查是否是最后一个 listed buffer
        local listed_count = 0
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_get_option(buf, "buflisted") then
            listed_count = listed_count + 1
          end
        end

        -- 如果是最后一个 buffer，提示但不删除
        if listed_count <= 1 then
          vim.notify("⚠️ 最后一个 buffer，请使用 :qa 退出", vim.log.levels.WARN, { title = "Telescope" })
          return false
        end

        -- 不是最后一个 buffer，执行删除
        vim.api.nvim_buf_delete(selection.bufnr, { force = false })
        return true
      end)
    end,
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
  -- default_mappings = { i = {}, n = {} } 清空 Telescope 内置默认映射
  -- mappings 使用 popup_mappings 中定义的自定义映射
  default_mappings = { i = {}, n = {} },
  mappings = popup_mappings,

  -- borderchars = vim.fn.PrettyBorders("#ef4444", "#eab308", “Telescope"),

  -- 预览器配置
  dynamic_preview_title = true, -- 显示文件名作为标题
  preview = {
    hide_on_startup = true, -- 启动时隐藏预览
    timeout = 60, -- 预览超时时间（毫秒）
  },

  -- for live_grep and grep_string pickers
  vimgrep_arguments = vim.list_extend({ vim.g.pretty_rg_executable }, vim.deepcopy(vim.g.pretty_rg_options)),

  -- 全局默认用正则搜索器，所有picker都生效
  --  仅支持常规模糊匹配，不支持正则表达式
  --  速度：mini > fzy > generic_sorter
  generic_sorter = function(opts)
    local ok, mini = pcall(require, "mini.fuzzy")
    if ok then
      vim.notify("💡 create mini fuzzy sorter")
      return mini.get_telescope_sorter(opts)
    end
    return sorters.get_fzy_sorter(opts)
    -- override by override_generic_sorter by fzy-native
  end,

  -- =============================================================
  -- 自动补全：禁用
  -- =============================================================
  completion = {
    complete = false,
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
})

-- clear_defaults() 清除内置默认配置，确保我们的配置完全生效
require("telescope.config").clear_defaults()

-- Telescope 初始化配置
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

    grep_string = {},
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
    -- fzy_native = {
    --   override_generic_sorter = false, -- 日常使用 mini fuzzy 更快一些
    --   override_file_sorter = true,
    -- },
  },
})

-- 明确开启已经安装的扩展（按加载顺序）
-- require("telescope").load_extension("fzy_native")
require("telescope").load_extension("ui-select")
require("telescope").load_extension("nerdy")
require("telescope").load_extension("emoji")
require("telescope").load_extension("lazygit")
require("telescope").load_extension("codecompanion")
require("telescope").load_extension("notify")

-- =============================================================================
-- 返回扩展启动函数
-- =============================================================================
-- 说明：
--   使用 ':Telescope nerdy' 不会应用默认主题设置（某些参数会被覆盖）
--   为了保持统一的 UI，插件启动函数必须手动应用默认主题设置

-- 默认是关闭 preview，但某些场景是需要直接打开 preview
local popup_preview = {
  preview = { hide_on_startup = false },
}

return {
  --- 关闭 Telescope
  close = actions.close,

  resume = function(opts)
    return require("telescope.builtin").resume(opts)
  end,

  --- 内置功能 ---

  --- 文件搜索
  ---@param opts table|nil 可选参数
  find = function(opts)
    return require("telescope.builtin").find_files(opts)
  end,

  --- 项目搜索（grep）
  ---@param opts table|nil 可选参数
  grep = function(opts)
    -- always enable preview for live_grep
    opts = vim.tbl_extend("force", opts or {}, popup_preview)

    return require("telescope.builtin").live_grep(opts)
  end,

  --- 缓冲区列表
  ---@param opts table|nil 可选参数
  buffers = function(opts)
    return require("telescope.builtin").buffers(opts)
  end,

  -- Quickfix
  quickfix = function(opts)
    opts = vim.tbl_extend("force", opts or {}, popup_defaults, popup_preview)
    if opts.id or opts.nr then
      return require("telescope.builtin").quickfix(opts)
    else
      return require("telescope.builtin").quickfixhistory(opts)
    end
  end,

  --- 插件功能 ---

  --- Nerdy 图标搜索
  nerdy = function(opts)
    opts = vim.tbl_extend("force", opts or {}, popup_defaults)
    return require("telescope").extensions.nerdy.nerdy(opts)
  end,

  --- Emoji 表情搜索
  emoji = function(opts)
    opts = vim.tbl_extend("force", opts or {}, popup_defaults)
    return require("telescope").extensions.emoji.emoji(opts)
  end,

  --- LazyGit
  lazygit = function(opts)
    opts = vim.tbl_extend("force", opts or {}, popup_defaults)
    return require("telescope").extensions.lazygit.lazygit(opts)
  end,

  --- CodeCompanion
  codecompanion = function(opts)
    opts = vim.tbl_extend("force", opts or {}, popup_defaults)
    return require("telescope").extensions.codecompanion.codecompanion(opts)
  end,

  -- notify
  messages = function(opts)
    opts = vim.tbl_extend("force", opts or {}, popup_defaults, popup_preview)
    return require("telescope").extensions.notify.notify(opts)
  end,
}
