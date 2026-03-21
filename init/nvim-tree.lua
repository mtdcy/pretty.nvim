-- File Tree: nvim-tree.lua - Basic configuration
-- This file is loaded by init.vim

local ok, nvim_tree = pcall(require, "nvim-tree")
if not ok then
  vim.notify("nvim-tree.lua not found", vim.log.levels.WARN)
  return
end

nvim_tree.setup({
  -- 基本设置
  disable_netrw = true,
  hijack_netrw = true,
  hijack_cursor = false,
  hijack_unnamed_buffer_when_opening = false,
  open_on_tab = false,

  -- 视图配置
  view = {
    width = 30,
    side = "left",
  },

  -- 渲染配置
  renderer = {
    group_empty = true,
  },

  -- 过滤配置
  filters = {
    dotfiles = true,
  },

  actions = {
    -- Popup 配置（show_info_popup）
    file_popup = {
      open_win_config = {
        relative = "cursor",
        border = "single",
        style = "minimal",
      },
    },
  },

  -- 快捷键配置（只保留基本功能）
  on_attach = function(bufnr)
    local api = require("nvim-tree.api")

    local function opts(desc)
      return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    -- 打开文件/文件夹
    vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
    vim.keymap.set("n", "<Space>", api.node.open.edit, opts("Open"))
    vim.keymap.set("n", "<2-LeftMouse>", api.node.open.edit, opts("Open"))
    vim.keymap.set("n", "p", api.node.show_info_popup, opts("Info"))

    -- 其他默认禁用（不设置任何额外快捷键）
  end,
})
