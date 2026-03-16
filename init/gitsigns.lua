-- Git: gitsigns.nvim - Git signs and hunk operations
-- This file is loaded by init.vim

local ok, gitsigns = pcall(require, "gitsigns")
if not ok then
    vim.notify("gitsigns.nvim not found", vim.log.levels.WARN)
    return
end

gitsigns.setup({
    -- 符号配置
    signs = {
        -- 不同改动有不同颜色
        add = { text = '│' },          -- 默认：'│'
        change = { text = '│' },       -- 默认：'│'
        delete = { text = '-' },       -- 默认：'-'
        topdelete = { text = '-' },    -- 默认：'-'
        changedelete = { text = '~' }, -- 默认：'~'
    },

    -- 是否显示符号
    signcolumn = true,  -- 默认：true

    -- 是否在行号栏显示
    numhl = false,      -- 默认：false

    -- 是否高亮整行
    linehl = true,     -- 默认：false

    -- 是否启用 word diff
    word_diff = true,  -- 默认：false

    -- 自动命令配置
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        -- 快捷键配置（默认值，已注释）
        -- vim.keymap.set('n', ']h', gs.next_hunk, { buffer = bufnr, desc = 'Next Hunk' })
        -- vim.keymap.set('n', '[h', gs.prev_hunk, { buffer = bufnr, desc = 'Previous Hunk' })
        -- vim.keymap.set('n', '<leader>hs', gs.stage_hunk, { buffer = bufnr, desc = 'Stage Hunk' })
        -- vim.keymap.set('n', '<leader>hr', gs.reset_hunk, { buffer = bufnr, desc = 'Reset Hunk' })
        -- vim.keymap.set('v', '<leader>hs', function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, { buffer = bufnr, desc = 'Stage Hunk' })
        -- vim.keymap.set('v', '<leader>hr', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, { buffer = bufnr, desc = 'Reset Hunk' })
        -- vim.keymap.set('n', '<leader>hS', gs.stage_buffer, { buffer = bufnr, desc = 'Stage Buffer' })
        -- vim.keymap.set('n', '<leader>hu', gs.undo_stage_hunk, { buffer = bufnr, desc = 'Undo Stage Hunk' })
        -- vim.keymap.set('n', '<leader>hR', gs.reset_buffer, { buffer = bufnr, desc = 'Reset Buffer' })
        -- vim.keymap.set('n', '<leader>hp', gs.preview_hunk, { buffer = bufnr, desc = 'Preview Hunk' })
        -- vim.keymap.set('n', '<leader>hb', function() gs.blame_line({ full = true }) end, { buffer = bufnr, desc = 'Blame Line' })
    end,
})
