-- =============================================================================
-- 自动补全配置：nvim-cmp + hints (ale)
-- =============================================================================

-- 总开关: 1 - 自动补全; 2 - Tab 手动补全; 0 - 禁用
local autocomplete = 1
if autocomplete == 0 then
  return
end

local ok, cmp = pcall(require, "cmp")
if not ok then
  vim.notify("nvim-cmp not found", vim.log.levels.WARN)
  return
end

-- ✨ 自定义 Trailing Edge Debounce
-- ❌ nvim-cmp 自动触发补全时会阻塞按键
local debounce = {
  delay = 500,
  timer = vim.loop.new_timer(),
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
    max_item_count = 30,
    -- trigger_characters = {}, -- ⚠️ 使用 keyword_length 触发，避免补全太频繁
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

-- ==================================
-- 快捷键映射
-- ==================================
-- ⚠️ fallback 不可靠，使用 nvim_feedkeys
local feedkeys = function(keycode)
  vim.api.nvim_feedkeys(vim.keycode(keycode), "n", true)
end

local modes = { "i", "c" }
local mapping = {
  -- 💡 超级 Tab 键: 补全 > 跳转 > Tab
  ["<Tab>"] = cmp.mapping(function(fallback)
    if cmp.visible() then
      -- 选择下一个候选词
      cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
    elseif vim.snippet.active({ direction = 1 }) then
      -- 💡 总是尝试跳转，在 snippet 完成之后还可以跳转最后一次
      vim.snippet.jump(1)

      -- 🐛 完成最后一跳 vim.snippet.active 仍然返回 true
      --  => 使用 vim.schedule 延缓 vim.snippet.active 判断
      vim.schedule(function()
        if not vim.snippet.active({ direction = 1 }) then
          vim.snippet.stop()
        end
      end)
    elseif autocomplete < 2 or vim.fn.PrettyLineIsNewWord() then
      feedkeys("<Tab>")
    else
      -- 手动补全
      cmp.complete({ reason = cmp.ContextReason.Auto })
    end
  end, modes),

  -- 上下选择候选词, 不插入候选词
  --- 仅当候选词被选中时，解决 cmdline 中翻看历史的问题
  ["<Down>"] = cmp.mapping(function(fallback)
    if cmp.get_selected_index() then
      cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
    else
      feedkeys("<Down>")
    end
  end, modes),

  ["<Up>"] = cmp.mapping(function(fallback)
    if cmp.get_selected_index() then
      cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
    else
      feedkeys("<Up>")
    end
  end, modes),

  -- 确认选择候选词
  ["<CR>"] = cmp.mapping(function(fallback)
    -- 如果没有选择，则直接 Enter
    if cmp.get_selected_index() then
      cmp.confirm()

      -- 💡 snippet 尝试下一跳
      if vim.snippet.active({ direction = 1 }) then
        vim.schedule(function()
          vim.snippet.jump(1)
        end)
      end

      -- 💡 避免再次提示补全
      if debounce then
        vim.schedule(function()
          debounce.timer:stop()
        end)
      end
    else
      feedkeys("<CR>")
    end
  end, modes),

  -- 选择候选词并插入空格 => 有助于连续输入
  ["<Space>"] = cmp.mapping(function(fallback)
    if cmp.get_selected_index() then
      -- 💡 一定要confirm，否则补全操作不完整，比如 snippet emoji 等
      cmp.confirm()

      -- 💡 snippet 尝试下一跳
      if vim.snippet.active({ direction = 1 }) then
        vim.schedule(function()
          vim.snippet.jump(1)
        end)
      end
    elseif cmp.visible() then
      cmp.close()
    end
    feedkeys("<Space>")
  end, modes),

  -- 取消补全
  ["<BS>"] = cmp.mapping(function(fallback)
    if cmp.get_selected_index() then
      cmp.abort()
    elseif cmp.visible() then
      cmp.close()
      feedkeys("<BS>") -- 💡 保证连续输入
    else
      feedkeys("<BS>")
    end
  end, modes),

  -- 关闭窗口
  ["<Esc>"] = cmp.mapping(function(fallback)
    -- 💡 严格控制 cmp.close() 的条件，否则需要按两次 Esc 才能退出插入模式
    if cmp.visible() then
      cmp.close()
    end
    feedkeys("<Esc>")
  end, { "i" }), -- ❌ 不要绑定命令模式，nvim-cmp 的 bug 会导致 Esc 变成 CR
}

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

local supported_filetypes = function()
  return not vim.list_contains({
    "nerdtree",
    "NvimTree",
    "tagbar",
    "Outline",
    "ale",
    "TelescopePrompt",
    "dashboard",
    "lazy",
    "mason",
  }, vim.bo.filetype)
end

-- ==================================
-- 全局配置
-- ==================================
cmp.setup({
  enabled = supported_filetypes,
  sources = sources,
  mapping = mapping,
  view = view,
  window = window,

  completion = {
    -- autocomplete = { cmp.TriggerEvent.TextChanged },
    autocomplete = false,
  },

  snippet = {
    expand = function(args)
      vim.snippet.expand(args.body) -- 💡 使用 vim.snippet 展开 lsp 返回的 snippets
    end,
  },

  formatting = {
    expandable_indicator = true,
    fields = { "menu", "abbr", "icon" }, -- kind => icon
    format = function(entry, item)
      -- 💡 最大宽度
      local max_width = 40
      if string.len(item.abbr) > max_width then
        item.abbr = string.sub(item.abbr, 1, max_width) .. "..."
      end
      -- 💡 显示图标
      item.menu = icons[entry.source.name] or "󰄱"
      return item
    end,
  },

  -- ❌ nvim-cmp debounce 是指令延时，导致某些指令执行很慢, 比如 cmp.visible()
  performance = {
    debounce = 0, -- 💡 越小越好，否则导致所有函数调用都很慢
    throttle = 200, -- 两次请求间隔
  },
  experimental = { ghost_text = false },
})

-- ==================================
-- 命令行模式补全（区分搜索/命令行场景）
-- ==================================

-- 1. 搜索模式（/ ?）
cmp.setup.cmdline({ "/", "?" }, {
  enabled = supported_filetypes,
  sources = {
    { name = "buffer", keyword_length = 2 },
  },
  completion = {
    autocomplete = { cmp.TriggerEvent.TextChanged }, -- 总是自动补全
  },
})

-- 2. 命令行模式（:）
cmp.setup.cmdline(":", {
  enabled = supported_filetypes,
  sources = cmp.config.sources({
    -- 💡 keyword_length = 3，这样 ':qa' 就不会提示补全
    { name = "cmdline", keyword_length = 3 },
    { name = "path", max_item_count = 30 },
  }),
  completion = {
    autocomplete = { cmp.TriggerEvent.TextChanged }, -- 总是自动补全
  },
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
if autocomplete == 1 and debounce then
  vim.api.nvim_create_autocmd("TextChangedI", {
    callback = function()
      if not supported_filetypes() then
        return
      end

      -- 每次都重置计时器
      debounce.timer:stop()
      debounce.timer:start(
        debounce.delay, -- 延迟时间
        0, -- 不重复
        function()
          vim.schedule(function()
            if cmp.visible() then
              return
            end
            -- 触发自动补全
            cmp.complete({ reason = cmp.ContextReason.Auto })
          end)
        end
      )
    end,
  })

  vim.api.nvim_create_autocmd("InsertLeave", {
    callback = function()
      debounce.timer:stop()
    end,
  })
end
