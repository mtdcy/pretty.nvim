-- =============================================================================
-- outline.nvim - 代码大纲/符号树插件
-- =============================================================================

local ok, outline = pcall(require, "outline")
if not ok then
  vim.notify("outline.nvim not found", vim.log.levels.WARN)
  return
end

-- Provider 配置（优先级：lsp > treesitter > ctags）
local providers = {
  priority = { "lsp", "markdown", "norg", "man", "ctags" },
}

-- 语法：action = "key"
local keymaps = {
  -- 跳转（Enter 和鼠标双击）
  goto_location = { "<CR>", "<2-LeftMouse>" },

  -- 折叠 
  fold_toggle = "<Space>", -- 空格切换折叠

  -- 其他 
  show_help = "?", -- 显示帮助
  search = "/", -- 搜索符号
  close = { "Q", "q" },

  -- 清除不需要的按键绑定
  peek_location = {},
  goto_and_close = {},
  restore_location = {},
  hover_symbol = {},
  toggle_preview = {},
  rename_symbol = {},
  code_actions = {},
  fold = {},
  fold_toggle_all = {},
  unfold = {},
  fold_all = {},
  unfold_all = {},
  fold_reset = {},
  down_and_jump = {},
  up_and_jump = {},
}

outline.setup({
  providers = providers,

  ctags = {
    program = vim.fn.PrettyFindExecutable("ctags"),
  },

  -- 窗口配置 
  outline_window = {
    position = "right", -- 窗口位置：right/left
    width = 30,
    relative_width = false, -- 💡 没有这个, width 不起作用
    focus_on_open = true,
  },

  -- 按键绑定 
  keymaps = keymaps,

  -- 行为配置 
  preview_window = { auto_preview = false },

  -- 符号图标配置 
  symbol_blacklist = {}, -- 黑名单：不显示的符号类型
  symbol_hicons = true, -- 使用 nerd-font 图标

  outline_items = {
    show_symbol_details = true,
  },

  guides = {
    enabled = true,
    markers = {
      bottom = "└",
      middle = "├",
      vertical = "│",
    },
  },
})
