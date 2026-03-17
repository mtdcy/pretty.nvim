--[[
-- =============================================================================
-- Telescope 配置文件
-- =============================================================================
-- 说明：
--   本文件负责 Telescope 的核心配置，包括：
--   1. UI 配置（布局、主题、提示符等）
--   2. 功能配置（排序器、文件忽略等）
--   3. Finder 菜单扩展（g:finder 处理）
--
-- 注意：
--   - 按键绑定全部在 finder.vim 中通过 autocmd 定义
--   - 使用 ui-select dropdown 主题实现菜单功能
-- =============================================================================
--]]

-- 引入 Telescope 模块
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local sorters = require('telescope.sorters')

-- =============================================================================
-- 功能配置
-- =============================================================================

--- 自定义排序器：使用 fzy 算法（类似 Denite 的 fruzzy）
--- @return table sorter
local function fzy_sorter()
    return sorters.fuzzy_with_index_bias()
end

-- =============================================================================
-- UI 配置
-- =============================================================================

require('telescope').setup({
    -- 默认配置（使用 dropdown 主题）
    defaults = require('telescope.themes').get_dropdown({
        -- 初始模式：normal = 不自动进入插入模式
        initial_mode = 'normal',

        -- 提示符配置
        prompt_title = '✨ Finder (按\'/\'开始搜索)',
        results_title = 'Result',
        prompt_prefix = '⌕ ',
        selection_caret = '➤ ',
        theme = "dropdown",

        -- 布局策略：居中显示
        layout_strategy = 'center',
        -- layout_config = {
        --     width = 0.5,
        --     preview_cutoff = 120,
        --     prompt_position = 'top',
        -- },

        -- 排序策略：从下往上
        sorting_strategy = 'ascending',

        -- 预览器配置
        previewer = true,
        preview = {
            hide_on_startup = true,  -- 启动时隐藏预览
            timeout = 60,             -- 预览超时时间（毫秒）
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
        -- 按键绑定：全部禁用（在 finder.vim 中使用 autocmd 定义）
        -- =============================================================
        mappings = {
            i = {},
            n = {},
        },

        -- =============================================================
        -- 自动补全：禁用
        -- =============================================================
        completion = {
            complete = false,
        },
    }),

    -- pickers 特定配置
    pickers = {
        -- 文件搜索
        find_files = {
            prompt_title = '📄 Finder (' .. vim.g.finder_tips .. ')',
            hidden = true,
            find_command = { "rg", "--files", "--glob", "!.git", "--hidden" },
            sorters = { fzy_sorter() },
        },

        -- 缓冲区列表
        buffers = {
            prompt_title = '📝 Buffers (' .. vim.g.finder_tips .. ')',
            sort_lastused = true,
            sort_mru = true,
        },

        -- 实时搜索
        live_grep = {
            prompt_title = '🔎 Search (' .. vim.g.finder_tips .. ')',
            additional_args = function()
                return { "--hidden", "--glob", "!.git" }
            end,
            sorters = { fzy_sorter() },
        },
    },

    -- 扩展配置
    extensions = {
        lazygit = {
            use_ssh_address = false,
        },
        codecompanion = {
            -- CodeCompanion 扩展配置
        },
    },
})

-- 加载扩展（如果可用）
pcall(require('telescope').load_extension, 'ui-select')
pcall(require('telescope').load_extension, 'lazygit')
pcall(require('telescope').load_extension, 'codecompanion')

-- =============================================================================
-- Finder 扩展（菜单功能 - 使用 ui-select dropdown 主题）
-- =============================================================================

local finder = {}
local themes = require('telescope.themes')

--- 显示主菜单（使用 ui-select dropdown 主题）
--- @return nil
finder.menu = function()
    local builtin = require('telescope.builtin')
    local finders = require('telescope.finders')
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')

    -- 从 VimL 全局变量获取菜单数据
    local finder_config = vim.g.finder
    if not finder_config then
        vim.notify('Finder config not found!', vim.log.levels.ERROR)
        return
    end

    local items = finder_config.items or {}

    -- 构建显示列表
    local results = {}
    for _, item in ipairs(items) do
        table.insert(results, {
            text = item[1],
            action = item[2],
        })
    end

    -- 计算动态高度：菜单项数量 + 标题行 + 边框
    -- 公式：items_count + 1 (prompt) + 3 (borders) = items_count + 3
    local min_height = #items + 4
    local max_height = 25  -- 最大高度限制

    -- 调用 builtin.find_files 显示菜单
    builtin.find_files({
        prompt_title = '✨ Finder (按\'/\'开始搜索)',

        -- 动态布局配置
        layout_config = {
            -- 高度根据菜单项数量动态计算
            height = math.min(min_height, max_height),
            -- 宽度固定 60 列或终端宽度的 50%
            width = function(_, max_columns, _)
                return math.min(60, math.floor(max_columns * 0.5))
            end,
        },

        -- 自定义 finder（使用菜单数据）
        finder = finders.new_table({
            results = results,
            entry_maker = function(entry)
                return {
                    value = entry.action,   -- 执行的命令
                    display = entry.text,   -- 显示文本
                    ordinal = entry.text,   -- 搜索关键词
                }
            end,
        }),

        -- 自定义按键映射
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                if selection and selection.value then
                    -- 先关闭 picker，再执行命令
                    actions.close(prompt_bufnr)
                    -- 使用 vim.schedule 确保在正确的上下文中执行
                    vim.schedule(function()
                        vim.cmd(selection.value)
                    end)
                end
            end)
            return true
        end,
    })
end

-- 注册扩展
require('telescope').register_extension({
    name = 'finder',
    exports = {
        menu = finder.menu,
    },
})

-- 返回配置模块
return {
    fzy_sorter = fzy_sorter,
    finder = finder,
}
