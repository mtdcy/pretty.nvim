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

-- =============================================================================
-- UI 配置
-- =============================================================================

-- popup 主题 (基于dropdown)
local popup = require('telescope.themes').get_dropdown({
    -- 初始模式：normal = 不自动进入插入模式
    initial_mode = 'normal',

    -- 提示符配置
    --prompt_title = '✨ Finder ' .. vim.g.finder_tips .. ')',
    prompt_title = vim.g.finder_tips,
    results_title = '✨ Finder ✨',
    prompt_prefix = ' ',
    selection_caret = '➤ ',
    color_devicons = true,

    -- 排序策略：从下往上
    sorting_strategy = 'ascending',

    -- 布局策略：center vertical horizontal bottom_pane
    layout_strategy = 'center',
    layout_config = {
        prompt_position = 'bottom',

        anchor = 'S',           -- 底部锚点
        anchor_padding = 1,     -- 距离底部 n 行
    },

    -- borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },

    -- 预览器配置
    previewer = true,
    preview = {
        hide_on_startup = true, -- 启动时隐藏预览
        timeout = 60,           -- 预览超时时间（毫秒）
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
})

require('telescope').setup({
    -- 默认配置
    defaults = popup,

    -- pickers 特定配置
    pickers = {
        -- 文件搜索
        find_files = {
            results_title = '📄 Files 📄',
            prompt_title = vim.g.finder_tips,
            hidden = true,
            find_command = { "rg", "--files", "--glob", "!.git", "--hidden" },
        },

        -- 缓冲区列表
        buffers = {
            results_title = '📝 Buffers 📝',
            prompt_title = vim.g.finder_tips,
            sort_lastused = true,
            sort_mru = true,
        },

        -- 实时搜索
        live_grep = {
            results_title = '🔎 Search 🔎',
            prompt_title = vim.g.finder_tips,
            additional_args = function()
                return { "--hidden", "--glob", "!.git" }
            end,
        },
    },

    -- 扩展配置
    -- 这个些配置会被传递给插件的 setup 函数
    extensions = {
        lazygit = {
            use_ssh_address = false,
        },
        codecompanion = {
            -- CodeCompanion 扩展配置
            opts = {
                window_opts = { layout = "float" },
            },
        },
    },
})

-- 明确开启已经安装的插件 => :Telescope lazygit
require('telescope').load_extension('ui-select')
require('telescope').load_extension('nerdy')
require('telescope').load_extension('emoji')
require('telescope').load_extension('lazygit')

-- =============================================================================
-- 安全删除 Buffer（覆盖 Telescope 默认行为）
-- =============================================================================
-- 问题：Telescope 默认使用 vim.api.nvim_buf_delete() 会关闭分割窗口
-- 解决：检测最后一个 buffer 时提示用 ':qa'，不执行删除操作
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

actions.delete_buffer = function(prompt_bufnr)
    local current_picker = action_state.get_current_picker(prompt_bufnr)

    current_picker:delete_selection(function(selection)
        -- 检查是否是最后一个 listed buffer
        local listed_count = 0
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_get_option(buf, 'buflisted') then
                listed_count = listed_count + 1
            end
        end

        -- 如果是最后一个 buffer，提示但不删除
        if listed_count <= 1 then
            vim.notify('最后一个 buffer，请使用 :qa 退出', vim.log.levels.WARN, { title = 'Telescope' })
            return false
        end

        -- 不是最后一个 buffer，执行删除
        vim.cmd('bdelete ' .. selection.bufnr)
        return true
    end)
end
require('telescope').load_extension('codecompanion')

-- 使用 Telescope 启动 nerdy，保持统一的 UI
-- extensions 暂时无法配置主题
vim.g.start_nerdy = function()
    require('telescope').extensions.nerdy.nerdy( popup )
end

vim.g.start_emoji = function()
    require('telescope').extensions.emoji.emoji( popup )
end

vim.g.start_codecompanion = function()
    require('telescope').extensions.codecompanion.codecompanion(vim.tbl_extend("force", popup, {
        -- extend theme with CodeCompanion opts
        opts = {
            window_opts = { layout = "float" },
        },
    }))
end

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
    local min_height = math.min(#items, 9) + 4
    local max_height = 32

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
            {width = 0.8},  -- Text 占 80% 宽度（靠左）
            {remaining = true},  -- Keymap 占剩余宽度（靠右）
        },
    }

    -- 调用 builtin.find_files 显示菜单
    builtin.find_files({
        -- 覆盖 find_files 设置
        results_title = '✨ Commands ✨',
        prompt_title = vim.g.finder_tips,

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
                    -- 不匹配快捷键
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
