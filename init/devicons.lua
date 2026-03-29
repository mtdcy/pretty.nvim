-- =============================================================================
-- nvim-web-devicons 配置文件
-- =============================================================================
-- 说明：
--   本文件负责 nvim-web-devicons 的基本配置
--   包括图标设置、颜色配置等
-- =============================================================================

local ok, devicons = pcall(require, "nvim-web-devicons")
if not ok then
    vim.notify("nvim-web-devicons not found", vim.log.levels.WARN)
    return
end

-- =============================================================================
-- 基本配置
-- =============================================================================

-- 启用图标
devicons.setup({
    -- 默认启用
    default = true,

    -- 严格匹配图标名称
    strict = true,

    color_icons = true,

    variant = vim.background,

    -- 自定义图标（可选，后续扩展）
    -- override = {
    --     default_icon = {icon = "󰈙"},
    --     lua = {icon = "", color = "#51a0cf", name = "Lua"},
    -- },
})
