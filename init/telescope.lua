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
        prompt_title = '✨ Finder ' .. vim.g.finder_tips .. ')',
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
-- Finder 菜单功能
-- =============================================================================

-- 将 finder 函数保存到全局变量，供 finder.vim 调用
--- 显示主菜单
--- @param opts table 选项
vim.g.start_finder = function(opts)
    local builtin = require('telescope.builtin')
    local finders = require('telescope.finders')
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')
    local entry_display = require('telescope.pickers.entry_display')

    -- 从 VimL 全局变量获取菜单数据
    local finder_config = vim.g.finder
    if not finder_config then
        vim.notify('Finder config not found!', vim.log.levels.ERROR)
        return
    end

    local items = finder_config.items or {}

    -- 计算动态高度：菜单项数量 + 标题行 + 边框
    local min_height = #items + 4
    local max_height = 25

    -- 构建显示列表（3 部分：Text, Keymap, Command）
    local results = {}
    for _, item in ipairs(items) do
        local text = item[1]
        local keymap = item[2]
        local command = item[3]
        table.insert(results, {
            text = text,
            keymap = keymap,
            action = command,
        })
    end

    -- 创建显示配置：Text 靠左，Keymap 靠右
    local displayer = entry_display.create {
        separator = ' ',
        items = {
            {width = 0.7},  -- Text 占 70% 宽度（靠左）
            {remaining = true},  -- Keymap 占剩余宽度（靠右）
        },
    }

    -- 调用 builtin.find_files 显示菜单
    builtin.find_files({
        -- 覆盖 find_files 设置
        prompt_title = '✨ Finder ' .. vim.g.finder_tips,

        -- 动态布局配置
        layout_config = {
            height = math.min(min_height, max_height),
            -- 使用主题定义的 width
        },

        -- 自定义 finder（使用菜单数据）
        finder = finders.new_table({
            results = results,
            entry_maker = function(entry)
                -- 创建显示：| Text (靠左) Keymap (靠右) |
                local make_display = function()
                    return displayer {
                        {entry.text},
                        {entry.keymap},
                    }
                end

                return {
                    value = entry.action,
                    display = make_display,
                    ordinal = entry.text .. ' ' .. entry.keymap,
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
                    -- 好像这个 close 没必要，ls! 显示 telescope 的 buffers 会自动关闭。
                    -- actions.close(prompt_bufnr)
                    vim.schedule(function()
                        vim.cmd(selection.value)
                    end)
                end
            end)
            return true
        end,
    })
end
