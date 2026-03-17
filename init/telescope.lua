-- Telescope 配置文件
-- 只保留：UI 配置、功能配置、g:finder 处理

local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local sorters = require('telescope.sorters')

-- =============================================================================
-- 功能配置
-- =============================================================================

-- 自定义排序器：使用 fzy 算法（类似 Denite 的 fruzzy）
local function fzy_sorter()
    return sorters.fuzzy_with_index_bias()
end

-- =============================================================================
-- UI 配置
-- =============================================================================

require('telescope').setup({
    defaults = require('telescope.themes').get_dropdown({
        initial_mode    = 'normal',

        prompt_title = '✨ Finder (按\'/\'开始搜索)',
        results_title   = 'Result',
        prompt_prefix   = '⌕ ',
        selection_caret = '➤ ',
        theme           = "dropdown",

        -- 布局设置：底部布局（输入框在底部）
        layout_strategy = 'center',
        --layout_config = {
        --    width = 0.5,
        --    preview_cutoff = 120,
        --    prompt_position = 'top',
        --},

        -- 排序器
        sorting_strategy = 'ascending',

        -- 预览设置
        previewer = true,
        preview = {
            hide_on_startup = true,
            timeout = 60,
        },

        -- 文件忽略模式
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

        -- 路径显示
        path_display = { "truncate" },

        -- 历史记录
        history = {
            path = vim.fn.stdpath("data") .. "/telescope_history",
            limit = 100,
        },

        -- =============================================================
        -- 按键绑定：全部禁用（在 finder.vim 中使用 autocmd 定义）
        -- =============================================================
        mappings = {
            i = { },
            n = { },
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
            find_command = {"rg", "--files", "--glob", "!.git", "--hidden"},
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
            additional_args = function() return {"--hidden", "--glob", "!.git"} end,
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

-- 显示主菜单（使用 ui-select dropdown 主题）
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

    builtin.find_files({
        prompt_title = '✨ Finder (按\'/\'开始搜索)',

        finder = finders.new_table({
            results = results,
            entry_maker = function(entry)
                return {
                    value = entry.action,
                    display = entry.text,
                    ordinal = entry.text,
                }
            end,
        }),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                if selection and selection.value then
                    -- 先关闭 picker，再执行命令
                    actions.close(prompt_bufnr)
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
