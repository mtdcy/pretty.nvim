-- =============================================================================
-- 文本输入配置：nvim-cmp + hints + 输入法切换
--
-- 稳定版，修复搜索补全Tab选择问题
--
-- 总是自动补全
--
-- 按键绑定（插入/命令行双模式生效）：
--  - <Tab>：有候选词时选择下一个，光标前有字符时触发补全，否则插入Tab
--  - <S-Tab>：有候选词时补全最长公共前缀，否则 fallback
--  - <Down>/<Up>：有候选词时上下选择，否则 fallback
--  - <CR>：有候选词时确认选择并填入，否则 fallback
--  - <BS>：有候选词时取消补全并关闭窗口，否则执行删除
--  - Esc：默认行为（无定制，关闭补全需按BS或点击外部）
--
-- =============================================================================

local ok, cmp = pcall(require, "cmp")
if not ok then
  vim.notify("nvim-cmp not found", vim.log.levels.WARN)
  return
end

-- ✨ 自定义 Trailing Edge Debounce
-- local debounce = { delay = 500 } -- => 关闭自动补全

local performance = {
  -- ❌ 这个 debounce 并不是防抖，而是延时执行相关指令
  debounce = 5, -- 💡 越小越好，否则导致所有函数调用都很慢
  throttle = 100, -- 两次请求间隔
  max_view_entries = 30, -- 最大显示条目
}

-- ==================================
-- 补全源配置
-- ==================================
local sources = cmp.config.sources({
  -- omni/ale 补全 - 💡 已经修正 omnifunc 为异步调用
  -- {
  --   name = "omni",
  --   keyword_length = 3,
  --   priority = 10, -- 💡 100% 正确 => 最高优先级
  --   option = {
  --     -- 强制指定ALE补全，无视LSP omnifunc
  --     omnifunc = "ale#completion#OmniFunc",
  --     disable_omnifuncs = { "v:lua.vim.lsp.omnifunc" },
  --   },
  -- },
  -- lsp 补全：直接复用 ale 的 lsp 服务
  {
    -- 💡 相比直接调用 omni/ale，多了函数信息和 snippet，但是速度也慢了一些
    name = "nvim_lsp",
    keyword_length = 3, -- 💡 > buffer source keyword_length
    priority = 10, -- 💡 100% 正确 => 最高优先级
    trigger_characters = {}, -- ⚠️ 使用 keyword_length 触发，避免补全太频繁
  },
  -- 缓冲区补全
  { name = "buffer", keyword_length = 2 },
  -- 路径补全
  { name = "path", max_item_count = 30 },
  -- Emoji - 使用方法: ':warning' => ⚠️
  --  💡 硬编码 keyword_length = 3
  { name = "emoji" },
}, {
  -- 跨文件补全，最低优先级
  { name = "rg" },
})

-- ==================================
-- 快捷键映射（完全匹配头部说明）
-- ==================================
local modes = { "i", "c" }
local mapping = {
  -- 超级 Tab 键
  ["<Tab>"] = cmp.mapping(function(fallback)
    -- 💡 补全 > 跳转 > Tab
    if cmp.visible() then
      -- 选择下一个候选词
      cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
    elseif vim.b.cmp_snippet_expanded then
      if vim.snippet.active({ direction = 1 }) then
        vim.snippet.jump(1)
      else
        vim.snippet.stop()
        vim.b.cmp_snippet_expanded = false
      end
    elseif vim.fn.PrettyLineIsNewLine() or vim.fn.PrettyLineIsNewWord() then
      fallback()
    else
      cmp.complete() -- 手动补全
    end
  end, modes),

  -- 特殊补全键
  --- complete_common_string 想要合理融入 Tab 键不太容易
  ["<S-Tab>"] = cmp.mapping(function(fallback)
    if not cmp.complete_common_string() then
      fallback()
    end
  end, modes),

  -- 上下选择候选词, 不插入候选词
  --- 仅当候选词被选中时，解决 cmdline 中翻看历史的问题
  ["<Down>"] = cmp.mapping(function(fallback)
    if cmp.get_selected_index() then
      cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
    else
      fallback()
    end
  end, modes),

  ["<Up>"] = cmp.mapping(function(fallback)
    if cmp.get_selected_index() then
      cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
    else
      fallback()
    end
  end, modes),

  -- 确认选择候选词
  ["<CR>"] = cmp.mapping(function(fallback)
    -- 如果没有选择，则直接 Enter
    if cmp.get_selected_index() then
      cmp.confirm()
    else
      fallback()
    end
  end, modes),

  -- 选择候选词并插入空格
  ["<Space>"] = cmp.mapping(function(fallback)
    if cmp.get_selected_index() then
      -- 💡 一定要confirm，否则补全操作不完整，比如 snippet emoji 等
      cmp.confirm()
      -- 💡 解决 fallback() 不会插入 Space 的问题
      vim.schedule(function()
        vim.api.nvim_feedkeys(vim.keycode("<Space>"), "n", true)
      end)
    end
    fallback()
  end, modes),

  -- 关闭窗口
  ["<Esc>"] = cmp.mapping(function(fallback)
    -- 💡 严格控制 cmp.close() 的条件，否则需要按两次 Esc 才能退出插入模式
    if vim.b.cmp_snippet_expanded and cmp.visible() then
      cmp.close()
    else
      fallback()
    end
  end, modes),

  -- 取消补全 (目前 cmp.abort 实现存在问题，会关闭窗口，然后又触发自动补全)
  ["<BS>"] = cmp.mapping(function(fallback)
    if cmp.get_selected_index() then
      cmp.abort()
    else
      fallback()
    end
  end, modes),
}

-- return true if filetype is supported
local check_filetypes = function()
  return not vim.tbl_contains({
    "nerdtree",
    "NvimTree",
    "tagbar",
    "Outline",
    "ale",
    "TelescopePrompt",
    "help",
    "dashboard",
    "lazy",
    "mason",
  }, vim.bo.filetype)
end

-- 候选框样式
local view = {
  -- entries = "native"
  entries = {
    name = "custom",
    vertical_positioning = "below", -- 优先向下，不要挡住刚才输入的内容
    --- ⚠️ 由于 nvim-cmp 没有提供方向判断接口，这里必须是 'top_down'，否则向上弹出候选框时 Up/Down 行为异常
    selection_order = "top_down",
    follow_cursor = false, -- 候选框随光标位置变化 - 很卡很慢
  },
}

local window = {
  completion = cmp.config.window.bordered({
    border = "rounded",
    winhighlight = "Normal:Normal,FloatBorder:PrettyCyan,CursorLine:Visual,Search:None",
    max_height = 10,
    col_offset = 2,
  }),
  documentation = cmp.config.window.bordered({
    border = "rounded",
    winhighlight = "Normal:Normal,FloatBorder:PrettyYellow,CursorLine:Visual,Search:None",
  }),
}

-- ==================================
-- 补全项显示样式
-- ==================================

-- icons for sources
local icons = {
  omni = "",
  nvim_lsp = "",
  buffer = "󰢨",
  path = "",
  cmdline = "",
  emoji = "󰞅",
  rg = "",
}

local formatting = {
  expandable_indicator = true,
  fields = { "menu", "abbr", "icon" }, -- kind => icon
  format = function(entry, item)
    item.menu = icons[entry.source.name] or "󰄱"
    return item
  end,
}

-- ==================================
-- 全局配置
-- ==================================
cmp.setup({
  enabled = check_filetypes,
  completion = {
    autocomplete = not debounce and { cmp.TriggerEvent.TextChanged } or false,
    completeopt = "menu,menuone,noselect",
    keyword_pattern = [[\%(-\?\d\+\%(\.\d\+\)\?\|\h\w*\%(-\w*\)*\)]], -- 默认值
    keyword_length = 1,
  },
  snippet = {
    expand = function(args)
      -- 💡 使用 vim.snippet 展开 lsp 返回的 snippets
      vim.snippet.expand(args.body)
      vim.b.cmp_snippet_expanded = true
    end,
  },
  sources = sources,
  mapping = mapping,
  formatting = formatting,

  view = view,
  window = window,

  performance = performance,
  experimental = { ghost_text = false },
})

-- ==================================
-- 命令行模式补全（区分搜索/命令行场景）
-- ==================================

-- 1. 搜索模式（/ ?）：
cmp.setup.cmdline({ "/", "?" }, {
  sources = {
    { name = "buffer", keyword_length = 2 },
  },
})

-- 2. 命令行模式（:）：keyword_length = 3，这样 ':qa' 就不会提示补全
cmp.setup.cmdline(":", {
  sources = cmp.config.sources({
    { name = "path" },
  }, {
    { name = "cmdline", keyword_length = 3 },
  }),
  matching = { disallow_symbol_nonprefix_matching = false },
})

-- ==================================
-- 自动补全 emojis
-- ==================================

-- 启用 emoji 补全
require("emoji").setup({ enable_cmp_integration = true })

-- ==================================
-- 自动显示符号 hints
-- ==================================
cmp.event:on("complete_done", function(event)
  if not event or not event.entry then
    return
  end

  -- 只处理来自 ale 的补全
  -- vim.notify(vim.inspect(event.entry))
  if event.entry.source.name == "omni" then
    -- 通过 omnifunc 调用 ALE，kind 字段没有正确设置
    vim.cmd("PrettyFindSymbols hints")
  else
    local item = event.entry:get_completion_item()
    if item.kind == cmp.lsp.CompletionItemKind.Function then
      vim.cmd("PrettyFindSymbols hints")
    end
  end
end)

-- ==================================
-- 实现 Trailing Edge Debounce
-- ==================================
if debounce then
  vim.api.nvim_create_autocmd("TextChangedI", {
    callback = function()
      -- 每次按键都重置计时器
      if debounce.timer then
        vim.loop.timer_stop(debounce.timer)
      end

      debounce.timer = vim.loop.new_timer()
      debounce.timer:start(
        debounce.delay, -- 延迟时间
        0, -- 不重复
        vim.schedule_wrap(function()
          -- if vim.fn.PrettyLineIsNewLine or vim.fn.PrettyLineIsNewWord then
          --   return
          -- end
          cmp.complete() -- 触发补全
        end)
      )
    end,
  })

  vim.api.nvim_create_autocmd("InsertLeave", {
    callback = function()
      if not debounce.timer then
        return
      end
      vim.loop.timer_stop(debounce.timer)
    end,
  })
end

-- ==================================
-- 自动切换输入法
-- ==================================
local IM = {
  selector = vim.fn.PrettyFindExecutable("im-select"),
  default = "com.apple.keylayout.ABC",
}

if IM.selector ~= "" then
  vim.api.nvim_create_augroup("PrettyIMSettings", { clear = true })

  vim.api.nvim_create_autocmd("InsertLeave", {
    group = "PrettyIMSettings",
    callback = function()
      vim.b.pretty_input_method = vim.trim(vim.system({ IM.selector }, { text = true }):wait().stdout)
      if vim.b.pretty_input_method ~= IM.default then
        -- vim.notify("💡 IM switch off " .. vim.b.pretty_input_method)
        vim.system({ IM.selector, IM.default })
      end
    end,
  })

  vim.api.nvim_create_autocmd("InsertEnter", {
    group = "PrettyIMSettings",
    callback = function()
      if vim.b.pretty_input_method and vim.b.pretty_input_method ~= IM.default then
        -- vim.notify("💡 IM switch on" .. vim.b.pretty_input_method)
        vim.system({ IM.selector, vim.b.pretty_input_method })
      end
    end,
  })
end
