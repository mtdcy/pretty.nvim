-- =============================================================================
-- Finder 配置
-- =============================================================================

-- Finder 提示信息
vim.g.finder_tips = " /: 搜索，j/k: 选择，q: 返回，Enter: 打开，Esc: 关闭 "

Finder = {
  -- 加载 Telescope 功能模块
  engine = dofile(vim.fn.expand("<sfile>:h") .. "/telescope.lua"),

  -- Finder 当前窗口
  bufnr = -1, -- TelescopePrompt 的 bufnr（用于 close 操作）
  main = false, -- 主窗口?

  -- Finder 是否处于活动状态
  active = function()
    return vim.fn.bufwinid(Finder.bufnr) > 0
  end,
}

--- 功能启动器（Launchers）---
Finder.launchers = {
  -- 文件搜索
  files = Finder.engine.files,

  -- 缓冲区列表
  buffers = Finder.engine.buffers,

  -- Messages
  messages = Finder.engine.messages,

  -- Quickfix
  quickfix = Finder.engine.quickfix,

  -- 项目搜索
  ---@param opts table|nil 可选参数
  grep = function(opts)
    opts = opts or {}
    if Finder.active() then
      return Finder.engine.grep()
    else
      local text = opts.text or vim.fn.expand("<cword>")
      return Finder.engine.grep({ default_text = text })
    end
  end,

  -- LazyGit
  lazygit = function()
    if Finder.active() then
      return Finder.engine.lazygit()
    else
      return vim.cmd("GitExplorer")
    end
  end,

  -- Nerdy 图标搜索
  nerdy = Finder.engine.nerdy,

  -- Emoji 表情搜索
  emoji = Finder.engine.emoji,
}

-- 菜单绑定配置（Bindings）
-- 格式说明：
--   name   : 显示文本（靠左）
--   keymap : 快捷键显示（靠右，空字符串表示无快捷键）
--   action : 执行的命令 (string) 或 Lua 函数 (function)

Finder.bindings = {
  -- 文件搜索
  {
    name = "1. Finder",
    keymap = "<C-o>",
    action = Finder.launchers.files,
  },

  -- 缓冲区列表
  {
    name = "2. Buffers",
    keymap = "<C-e>",
    action = Finder.launchers.buffers,
  },

  -- 项目搜索（grep）
  {
    name = "3. Search",
    keymap = "<C-g>",
    action = Finder.launchers.grep,
  },

  -- 格式化
  {
    name = "4. Format",
    keymap = "<F8>",
    action = "StyleFormat",
  },

  {
    name = "5. Explorer",
    keymap = "<F9>",
    action = "FileExplorer",
  },

  -- 打开标签列表
  {
    name = "6. Taglist",
    keymap = "<F10>",
    action = "TagsExplorer",
  },

  -- Messages
  {
    name = "7. Messages",
    keymap = "",
    action = Finder.launchers.messages,
  },

  -- Quickfix
  {
    name = "8. Quickfix",
    keymap = "",
    action = Finder.launchers.quickfix,
  },

  -- 打开帮助
  {
    name = "?. Help",
    keymap = "",
    action = function()
      vim.cmd("edit " .. vim.env.NVIM_HOME .. "/README.md")
    end,
  },

  -- 打开 LazyGit
  {
    name = ".. LazyGit",
    keymap = "<F12>",
    action = Finder.launchers.lazygit,
  },

  -- Nerdy 搜索
  {
    name = ".. Nerdy",
    keymap = "",
    action = Finder.launchers.nerdy,
  },

  -- Emoji 搜索
  {
    name = ".. Emoji",
    keymap = "",
    action = Finder.launchers.emoji,
  },

  -- 退出确认
  {
    name = ".. Quit",
    keymap = "",
    action = "confirm quit",
  },
}

--- 执行命令（支持 string 和 function 两种类型）
---@param cmd string|function 要执行的命令或函数
local function do_action(cmd)
  if type(cmd) == "function" then
    cmd()
  else
    vim.cmd(cmd)
  end
end

--- 激活窗口
Finder.activate = function(opts)
  opts = opts or {}
  if opts.resume and Finder.bufnr >= 0 then
    -- 恢复窗口
    Finder.engine.resume()
  else
    local args = {}
    -- 打开主窗口 或 子窗口
    if opts.type and Finder.launchers[opts.type] then
      if opts.type == "quickfix" then
        args.nr = "$" -- 直接打开最后一个 quickfix 窗口
      end
      Finder.launchers[opts.type](args)
    else
      Finder.launch(args)
    end
    -- set bufnr in autocmd
  end
end

--- 隐藏窗口
Finder.deactivate = function(opts)
  opts = opts or {}
  if Finder.bufnr < 0 then return end

  Finder.engine.close(Finder.bufnr)
  if opts.close then
    -- 返回上层窗口?
    if not Finder.main then
      vim.schedule(function()
        Finder.activate() -- 打开主窗口
      end)
    end

    -- 清除窗口状态
    Finder.bufnr = -1
  end
end

--- 显示主菜单
Finder.launch = function(opts)
  opts = opts or {}
  Finder.main = true

  local builtin = require("telescope.builtin")
  local finders = require("telescope.finders")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local entry_display = require("telescope.pickers.entry_display")

  -- 从 bindings 构建菜单数据: （3 部分：text, keymap, action）
  local results = {}
  for _, item in ipairs(Finder.bindings) do
    table.insert(results, {
      text = item.name,
      keymap = item.keymap or "",
      action = item.action,
    })
  end

  -- 创建显示配置：Text 靠左，Keymap 靠右
  local displayer = entry_display.create({
    separator = " ",
    -- 左侧：Text (90% 宽度)  右侧：Keymap (剩余宽度)
    items = { { width = 0.9 }, { remaining = true } },
  })

  -- 调用 builtin.find_files 显示菜单
  builtin.find_files({
    -- 覆盖 find_files 设置
    results_title = "✨ Commands ✨",
    prompt_title = vim.g.finder_tips,

    -- 自定义 finder（使用菜单数据）
    finder = finders.new_table({
      results = results,
      ---@param entry {text: string, keymap: string, action: function|string}
      entry_maker = function(entry)
        -- 创建显示：| Text (靠左) Keymap (靠右) |
        local make_display = function()
          return displayer({ { entry.text }, { entry.keymap } })
        end

        return {
          value = entry, -- 传递整个 entry 对象
          display = make_display,
          -- 不匹配快捷键（只匹配 text）
          ordinal = entry.text,
          text = entry.text,
          keymap = entry.keymap,
        }
      end,
    }),

    -- 自定义按键映射
    attach_mappings = function(prompt_bufnr, map)
      -- 替换默认选择行为：执行菜单项的 action
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        if selection and selection.value then
          local entry = selection.value

          -- 执行命令
          vim.schedule(function()
            Finder.main = false
            do_action(entry.action)
          end)
        end
      end)
      -- 返回 true：保留 popup_defaults 中定义的默认映射
      -- 返回 false：清空所有默认映射（只保留上面 map() 定义的）
      return true
    end,
  })
end

--- Finder 窗口开启逻辑 ---
local function finder_create_commands()
  vim.api.nvim_create_user_command("FinderOpen", function(opts)
    -- vim.notify("⚡️ " .. vim.inspect(opts))

    local args = {}
    if opts and opts.args and opts.args ~= "" then
      local bufnr = tonumber(opts.args)
      if bufnr then
        vim.notify("⚡️ Load bufnr " .. bufnr .. " to quickfix")
        vim.fn.PrettyQuickfixLoad(bufnr, " " .. (vim.fn.bufname(bufnr) or bufnr))
        -- 不要在这关闭窗口，可能造成不可控的结果
        -- 需要关闭窗口就主动调用 PrettyQuickfixLoad 然后关闭窗口

        args.type = "quickfix"
      else
        args.type = opts.args
      end
    else
      args.resume = true -- 恢复上次打开的窗口（如果存在）
    end

    vim.schedule(function()
      Finder.activate(args)
    end)
  end, {
    nargs = "*",
    desc = "Finder Open",
  })
end

--- Finder 窗口设置 ---
local function finder_create_autocmds()
  vim.api.nvim_create_augroup("FinderGroup", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = "FinderGroup",
    pattern = "TelescopePrompt",
    callback = function()
      -- TelescopePrompt bufnr（telescope 很多操作都需要此 bufnr）
      Finder.bufnr = vim.api.nvim_get_current_buf()

      -- PrettyCursorToggle() - 调用 VimL 函数
      vim.fn.call("PrettyCursorToggle", {})

      -- 设置退出快捷键行为
      vim.keymap.set("n", "<Esc>", function()
        Finder.deactivate()
      end, { buffer = true, silent = true })

      -- 设置返回上一级快捷键行为
      vim.keymap.set("n", "q", function()
        Finder.deactivate({ close = true })
      end, { buffer = true, silent = true })

      -- Normal 模式：'/' 编辑
      vim.keymap.set("n", "/", function()
        vim.cmd("startinsert!")
      end, { buffer = true, silent = true })

      -- Insert 模式：按 Enter 停止插入
      vim.keymap.set("i", "<CR>", function()
        vim.cmd("stopinsert")
      end, { buffer = true, silent = true })
    end,
  })
end

--- Finder 窗口按键绑定（全局）---
local function finder_create_bindings()
  for i, item in ipairs(Finder.bindings) do
    -- 检查是否定义了快捷键和命令
    if item.keymap and item.keymap ~= "" and item.action then
      -- Normal 模式 only
      vim.keymap.set("n", item.keymap, function()
        do_action(item.action)
      end, { silent = true, desc = "Finder. " .. item.name })
    end
  end
end

finder_create_commands()
finder_create_autocmds()
finder_create_bindings()

-- Enter 打开主菜单
vim.keymap.set({ "n" }, "<Enter>", ":FinderOpen<CR>", { silent = true })

--
