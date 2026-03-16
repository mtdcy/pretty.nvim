-- Markdown: render-markdown.nvim - Render markdown for a better visual experience
-- This file is loaded by init.vim

local ok, render_markdown = pcall(require, "render-markdown")
if not ok then
    vim.notify("render-markdown.nvim not found", vim.log.levels.WARN)
    return
end

render_markdown.setup({
    -- 文件类型
    file_types = { 'markdown', 'codecompanion' },  -- 默认：{'markdown', 'norg', 'rmd', 'org'}

    -- 是否启用
    enabled = true,  -- 默认：true

    -- 是否只在当前 buffer 启用
    enabled_filetypes = nil,  -- 默认：nil

    -- 标题渲染
    heading = {
        enabled = true,   -- 启用标题渲染
        width = 'full',
    },

    -- 列表渲染
    bullet = {
        enabled = true,
    },

    -- 复选框渲染
    checkbox = {
        enabled = true,
    },

    -- 代码块渲染
    code = {
        enabled = true,
        sign = true,
    },

    -- 表格渲染
    table = {
        enabled = true,
    },

    -- 引用块渲染
    quote = {
        enabled = true,
    },

    -- 数学公式渲染
    math = {
        enabled = false,
    },

    -- 链接渲染
    link = {
        enabled = false,
    },

    -- 窗口选项
    window = {
        border = 'none',
    },
})
