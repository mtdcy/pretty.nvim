--[[
-- =============================================================================
-- Solarized.nvim 主题配置
-- =============================================================================
-- 插件：https://github.com/maxmx03/solarized.nvim
--
-- Solarized 经典配色方案：
--   - 低对比度，护眼
--   - 精心挑选的颜色组合
--   - 支持亮色/暗色模式
-- =============================================================================
--]]

-- 引入模块
local solarized = require('solarized')

-- =============================================================================
-- 主题配置
-- =============================================================================

solarized.setup({
    palette = 'solarized', -- solarized (default) | selenized

    -- "spring" | "summer" | "autumn" | "winter" (default)
    variant = 'autumn',

    -- 是否启用透明背景
    transparent = {
        enabled = true,         -- Master switch to enable transparency
        pmenu = true,           -- Popup menu (e.g., autocomplete suggestions)
        normal = true,          -- Main editor window background
        normalfloat = true,     -- Floating windows
        neotree = true,         -- Neo-tree file explorer
        nvimtree = true,        -- Nvim-tree file explorer
        whichkey = true,        -- Which-key popup
        telescope = true,       -- Telescope fuzzy finder
        lazy = true,            -- Lazy plugin manager UI
        mason = true,           -- Mason manage external tooling
    },

    styles = {
        enabled = true,
        comments = { italic = true, bold = false, underline = false },
        -- comments keywords functions strings variables
    },

    -- 覆盖默认高亮组
    override = {
        -- 示例：自定义注释颜色
        -- Comment = { fg = '#586e75' },
    },

    -- 插件集成
    plugins = {
        -- Telescope 集成
        telescope = {
            enabled = true,
            style = 'default', -- 'default' | 'nvchad'
        },

        -- LSP 集成
        lsp = {
            enabled = true,
            virtual_text = true,
        },

        -- Treesitter 集成
        treesitter = {
            enabled = true,
        },

        -- 其他插件
        indent_blankline = { enabled = false },
        which_key = { enabled = false },
        native_lsp = { enabled = true },
    },
})

-- =============================================================================
-- 应用主题
-- =============================================================================

-- 设置 colorscheme
vim.cmd.colorscheme 'solarized'

-- =============================================================================
-- 自定义高亮（在 colorscheme 之后设置，防止被覆盖）
-- =============================================================================

-- Telescope 标题 取消高亮
vim.api.nvim_set_hl(0, 'TelescopeTitle', { link = "FloatNormal" })
vim.api.nvim_set_hl(0, 'TelescopePromptTitle', { link = "TelescopeTitle" })
vim.api.nvim_set_hl(0, 'TelescopeResultsTitle', { link = "TelescopeTitle" })
