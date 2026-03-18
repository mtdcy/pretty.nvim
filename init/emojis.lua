-- =============================================================================
-- emoji.nvim 配置文件
-- =============================================================================
-- 说明：
--   本文件负责 emoji.nvim 的基本配置
--   提供 emoji 补全和渲染功能
-- =============================================================================

local ok, emoji = pcall(require, "emoji")
if not ok then
    vim.notify("emoji.nvim not found", vim.log.levels.WARN)
    return
end

-- =============================================================================
-- 基本配置
-- =============================================================================

vim.g.emoji_opts = {
    -- 启用 emoji 补全
    complete = true,

    -- 启用 emoji 渲染
    render = true,

    -- 补全触发字符（默认：冒号）
    trigger = ":",

    -- 最小匹配长度
    min_len = 2,

    -- 是否区分大小写
    case_sensitive = false,

    -- 是否显示预览
    preview = true,

    -- default is false, also needed for blink.cmp integration!
    --enable_cmp_integration = true,

    -- optional if your plugin installation directory
    -- is not vim.fn.stdpath("data") .. "/lazy/
    plugin_path = vim.g.pretty_home
}

emoji.setup( vim.g.emoji_opts )
