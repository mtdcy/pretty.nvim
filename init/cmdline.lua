-- =============================================================================
-- noice.nvim 配置：接管命令行、消息、通知展示
-- =============================================================================

local ok, noice = pcall(require, "noice")
if not ok then
  return
end

local set_cmdline_format = function(icon, hl, opts)
  local format = { icon = icon or "" }

  if hl and hl ~= "" then
    format.icon_hl_group = hl
    format.opts = {
      win_options = {
        winhighlight = {
          FloatTitle = hl,
          FloatBorder = hl,
        },
      },
    }
  end

  if opts then
    format = vim.tbl_extend("force", format, opts)
  end

  return format
end

local cmdline = {
  enabled = true,
  view = "cmdline_popup", -- default: cmdline cmdline_popup
  format = {
    input = set_cmdline_format("󰥻", "PrettyRed"), -- Used by vim.ui.input()
    cmdline = set_cmdline_format("", "PrettyBlue"),
    search_up = set_cmdline_format("", "PrettyOrange"),
    search_down = set_cmdline_format("", "PrettyOrange"),

    -- specials
    lua = set_cmdline_format("", "PrettyPurple"),
    help = set_cmdline_format("󰋖", "PrettyGreen"),
    echo = set_cmdline_format("󰙎", "PrettyCyan", { pattern = "^:echo%s+" }),
    edit = set_cmdline_format("", "PrettyViolet", { pattern = "^:ed?i?t?%s+" }),
    shell = set_cmdline_format("", "PrettyRed", { pattern = "^:!" }),
    range = set_cmdline_format("", "PrettyMagenta", { pattern = "^:'<,'>" }),

    -- disable defaults
    filter = false,
  },
}

local messages = {
  enabled = true,
  view = "notify", -- nvim-notify
  view_history = "messages", -- view for :messages
}

-- 捕获 vim.notify()
local notify = {
  enabled = true,
  view = "notify",
}

local popupmenu = {
  enabled = true,
  backend = "nui",
}

local views = {
  cmdline_popup = {
    position = { row = "95%", col = "50%" }, -- bottom center
    border = { style = "rounded" },
    -- 不要在这里定义窗口颜色，使用 cmdline.format
  },
  -- cmdline_input = {},
  -- cmdline_output = {},

  notify = {
    backend = "notify", -- force use nvim-notify
  },
}

-- 路由规则
local routes = {
  -- 忽略无用的系统提示
  { filter = { event = "msg_show", find = "Pattern not found" }, opts = { skip = true } },
  -- { filter = { event = "msg_show", kind = "", find = "written" }, opts = { skip = true } },
  { filter = { event = "msg_show", kind = "", find = "fewer lines" }, opts = { skip = true } },
  { filter = { event = "msg_show", kind = "search_count" }, opts = { skip = true } },

  -- 修复 shell 命令无输出的问题
  -- https://github.com/folke/noice.nvim/issues/1097
  {
    view = "notify",
    filter = { event = "msg_show", kind = { "shell_out", "shell_err" } },
    opts = { level = "info", skip = false, replace = false },
  },

  -- quickfix
  -- {
  --   view = "notify",
  --   filter = { event = "msg_show", kind = "quickfix" },
  --   opts = { title = "QuickFix", level = vim.log.levels.INFO },
  -- },
}

noice.setup({
  -- 禁用不需要的模块，保持稳定
  health = { checker = false },
  presets = {
    bottom_search = false, -- 底部搜索栏保持原生习惯
    command_palette = true, -- 命令行弹窗美化
    long_message_to_split = false, -- 长消息自动开分割窗口
    inc_rename = false,
    lsp_doc_border = true, -- LSP文档加统一圆角边框
    -- cmdline_output_to_split = false,
  },

  cmdline = cmdline,
  messages = messages,

  -- 捕获 vim.notify()
  notify = notify,

  popupmenu = popupmenu,

  views = views,

  routes = routes,

  -- 关闭不需要的LSP消息接管，避免和现有lsp配置冲突
  lsp = {
    progress = { enabled = false },
    message = { enabled = false },
    hover = { enabled = false },
    signature = { enabled = false },
  },
})

-- setup nvim-notify
require("notify").setup({ max_width = 80, timeout = 2000 })

-- 定义退出键行为
vim.api.nvim_create_autocmd("FileType", {
  pattern = "notify",
  callback = function()
    vim.fn.call("PrettyExitWith", {})
  end,
})
