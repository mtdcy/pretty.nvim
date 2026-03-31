-- =============================================================================
-- Rainbow Delimiters + Indent Blankline 集成配置
-- =============================================================================
-- 说明：
--   本文件实现 rainbow-delimiters.nvim 与 indent-blankline.nvim 的集成
--   使缩进引导线的颜色与括号高亮颜色保持一致
--
-- 参考：
--   https://github.com/lukas-reineke/indent-blankline.nvim#rainbow-delimitersnvim-integration
-- =============================================================================

-- =============================================================================
-- 定义彩虹颜色（与括号高亮一致）
-- =============================================================================

local highlight = {
  "RainbowRed",
  "RainbowYellow",
  "RainbowBlue",
  "RainbowOrange",
  "RainbowGreen",
  "RainbowViolet",
  "RainbowCyan",

  --
  "CursorColumn",
  "Whitespace",
}

-- 高亮匹配的括号
vim.api.nvim_set_hl(0, "MatchParen", { fg = "#ffffff", bg = "#aa3300" })

-- =============================================================================
-- 配置 ibl hooks
-- =============================================================================

local hooks = require("ibl.hooks")

-- 在 highlight setup hook 中创建高亮组，这样每次 colorscheme 变化时会自动重置
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
  -- Rainbow delimiter colors（Solarized 风格）
  vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
  vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
  vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
  vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
  vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
  vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
  vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
end)

vim.g.rainbow_delimiters = {
  highlight = highlight,
  blacklist = {
    "ale-info",
    "ale-preview-selection",
  },
}

require("ibl").setup({
  -- indent without colors by default
  indent = {
    -- default char is two thick
    char = "┆", -- U+2508
  },
  -- highlight scope with colors
  scope = {
    -- char = "│", -- U+2502
    char = "┆", -- U+2508
    highlight = highlight,
  },
  exclude = {
    buftypes = {
      "terminal",
      "nofile",
      "quickfix",
      "prompt",
      "ale-info",
    },
  },
})

hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
