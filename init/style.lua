-- =============================================================================
-- 代码质量工具配置
-- =============================================================================
-- 说明：
--   本文件负责代码风格和质量工具的配置，包括：
--   1. EditorConfig 支持
--   2. 文件编码和格式设置
--   3. 缩进和制表符配置
--   4. 文件类型特定配置
--   5. 自动格式化（StyLua 等）
--   6. 文件自动重载（autoread）
--   7. 折叠配置（fold）
--   8. filetype 和 indent 配置
--
-- 设计理念：
--   - 优先使用 EditorConfig 统一风格
--   - 自动化工具格式化代码
--   - 减少手动配置
-- =============================================================================

vim.g.style_format_on_save = false

-- =============================================================================
-- Filetype 和 Indent 配置
-- =============================================================================
-- 启用 filetype 插件和缩进

-- 启用 filetype 检测、插件和缩进
vim.cmd("filetype plugin indent on")

-- 全局缩进设置
vim.opt.autoindent = true -- 自动缩进
vim.opt.smartindent = true -- 智能缩进
vim.opt.cindent = true -- C 语言缩进

-- 禁用 backspace 的某些行为（使用默认）
vim.opt.backspace = { "indent", "eol", "start" }

-- =============================================================================
-- 全局文件设置
-- =============================================================================

-- 行尾格式：Unix (LF)
-- editorconfig.end_of_line = lf
vim.opt.fileformat = "unix"
vim.opt.fileformats = { "unix", "dos" }

-- 文件编码：UTF-8
-- editorconfig.charset = utf-8
vim.opt.fileencoding = "utf-8"
vim.opt.fileencodings = { "utf-8", "gb18030", "gbk", "latin1" }

-- 缩进配置
-- editorconfig.indent_size = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 0 -- disable sts
-- editorconfig.tab_width = 4
vim.opt.tabstop = 4

-- 使用空格代替制表符
-- editorconfig.indent_style = space
vim.opt.expandtab = true

-- 最大行宽
-- editorconfig.max_line_length
vim.opt.textwidth = 0 -- 不自动换行

-- 禁用自动换行（使用 textwidth）
vim.opt.formatoptions:remove("t")

-- =============================================================================
-- 折叠配置（Fold）
-- =============================================================================
-- 默认折叠，手动开关

-- 全局折叠设置
vim.opt.foldmethod = "manual"
vim.opt.foldlevel = 0
vim.opt.foldnestmax = 1
vim.opt.foldminlines = 3 -- 不折叠最小的 if-else 语句
vim.opt.foldcolumn = "1" -- 与 vim-signify 冲突时调整
vim.opt.fillchars = vim.opt.fillchars + { fold = " " } -- 隐藏 v:folddashes（注意：\ 后面有空格）

-- =============================================================================
-- FoldText 函数
-- =============================================================================
-- 注意：必须使用 _G 定义全局函数

-- 设置 foldtext
_G.pretty_style_foldtext = function()
  local text = vim.fn.getline(vim.v.foldstart)
  local lines = vim.v.foldend - vim.v.foldstart
  return text .. " 󰍻 " .. lines .. " more lines "
end
vim.opt.foldtext = "v:lua.pretty_style_foldtext()"

-- =============================================================================
-- 文件类型特定配置
-- =============================================================================
-- 注意：.editorconfig 会覆盖这些设置

-- style 模块
local style = {
  -- 创建自动命令组
  augroup = vim.api.nvim_create_augroup("StyleGroup", { clear = true }),
}

-- =============================================================================
-- 文件类型配置数据结构
-- =============================================================================
-- 格式：filetype = { et, ts, sw, foldmethod='xxx', foldlevel=n, command='xxx', files={}, exts={} }
--
-- 必需项（位置参数）:
--   [1] et        : expandtab (布尔值)
--   [2] ts        : tabstop (数字)
--   [3] sw        : shiftwidth (数字)
--
-- 可选项（命名参数，不必按顺序）:
--   exts        : 文件扩展名数组（如 {'lua'}，默认为 {filetype}）
--   foldmethod  : foldmethod (字符串，默认不设置)
--   foldlevel   : foldlevel (数字，默认 99)
--   command     : 格式化命令（字符串，如 'stylua'，默认不设置）
--   opts        : 命令行参数 (如 {'-c'}, 默认为空）
--   files       : 配置文件数组（如 {'.stylua.toml'}，默认不设置）
--
-- 最终命令组成: command opts files %
--
-- 示例：
--   lua = { true, 2, 2, foldmethod='syntax', foldlevel=99, command='stylua', files={'.stylua.toml'} }
--   vim = { true, 4, 4, foldmethod='marker' }
--   make = { false, 4, 4 }                        -- 使用制表符
-- =============================================================================

style.filetypes = {

  -- Makefile：4 空格，使用制表符
  make = { false, 4, 4 },

  -- shell script
  sh = { true, 4, 4, command = "shfmt", opts = { "-w", "-kp", "-i", "4", "-ln", "bash", "-sr" } },

  -- VimL：4 空格缩进，标记折叠
  vim = { true, 4, 4, foldmethod = "marker" },

  -- Lua：2 空格缩进，语法折叠，自动格式化
  lua = {
    true,
    2,
    2,
    command = "stylua",
    files = { ".stylua.toml", ".styluaignore" },
    foldmethod = "syntax",
    foldlevel = 99,
    exts = { "lua" },
  },

  -- YAML：2 空格缩进，缩进折叠
  yaml = {
    true,
    2,
    2,
    -- yamlfix 自动检测 pyproject.toml or .yamlfix.toml
    command = "yamlfix",
    exts = { "yaml", "yml" },
    foldmethod = "indent",
    foldlevel = 99,
  },

  -- JSON：2 空格缩进，忽略顶层括号
  json = { true, 2, 2, command = "fixjson", opts = { "-i", "2", "-w" }, foldlevel = 1 },
  json5 = { true, 2, 2, command = "fixjson", opts = { "-i", "2", "-w" }, foldlevel = 1 },

  -- Markdown：2 空格缩进
  markdown = { true, 2, 2, foldlevel = 99 },

  -- Python：4 空格缩进，缩进折叠
  python = { true, 4, 4, foldmethod = "indent" },

  -- HTML/CSS：2 空格缩进，语法折叠
  html = { true, 2, 2, foldmethod = "syntax" },
  css = { true, 2, 2, foldmethod = "syntax" },

  -- JavaScript：2 空格缩进
  javascript = { true, 2, 2 },

  -- TypeScript：2 空格缩进
  typescript = { true, 2, 2 },
}

-- =============================================================================
-- 自动格式化工具
-- =============================================================================

local style_default_formatter = function()
  vim.cmd("normal! gg=G") -- use vim formatter
end

--- 查找格式化工具
---@param config {} filetype 对应的配置
---@return string|function 工具路径，找不到返回 style_default_formatter
local function style_find_formatter(config)
  if not config or not config.command then
    return style_default_formatter
  end

  -- 检查配置文件是否存在（如果有指定）
  if config.files then
    local found = false
    for _, file in ipairs(config.files) do
      if vim.fn.findfile(file, ".;") ~= "" then
        found = true
        break
      end
    end
    -- 如果配置文件没找到，不格式化
    if not found then
      return style_default_formatter
    end
  end

  -- 使用 PrettyFindExecutable 获取完整路径（VimL 函数）
  local executable = vim.fn.call("PrettyFindExecutable", { config.command })

  -- 检查返回值
  if executable and executable ~= "" then
    if config.opts then
      return executable .. " " .. table.concat(config.opts, " ")
    else
      return executable
    end
  else
    return style_default_formatter
  end
end

--- 执行命令（支持 string 和 function 两种类型）
---@param formatter string|function 要执行的命令或函数
local function style_format(formatter, opts)
  if type(formatter) == "function" then
    -- Lua 函数：直接调用
    formatter()

    if opts and opts.verbose then
      vim.notify("✅ Format done", vim.log.levels.INFO)
    end
  elseif type(formatter) == "string" then
    -- 执行格式化（使用 system() 捕获输出）
    local bufname = vim.api.nvim_buf_get_name(0)
    local cmd = formatter .. " " .. vim.fn.fnameescape(bufname)
    local output = vim.fn.system(cmd)

    -- 检查错误
    if vim.v.shell_error ~= 0 then
      vim.notify("❌ Style Format: " .. output, vim.log.levels.ERROR)
      return
    end

    if opts and opts.verbose then
      vim.notify("✅ Format with " .. formatter, vim.log.levels.INFO)
    end
  end
end

--- 为文件类型应用配置
---@param ft string 文件类型
---@param config table 配置表 { et, ts, sw, foldmethod='xxx', foldlevel=n, command='xxx', files={}, ext={} }
local function style_filetype(ft, config)
  vim.api.nvim_create_autocmd("FileType", {
    group = style.augroup,
    pattern = ft,
    callback = function()
      -- 必需项：et, ts, sw
      vim.opt_local.expandtab = config[1]
      vim.opt_local.tabstop = config[2]
      vim.opt_local.shiftwidth = config[3]

      -- 可选项：foldmethod (foldmethod)
      if config.foldmethod then
        vim.opt_local.foldmethod = config.foldmethod
      end

      -- 可选项：foldlevel (默认 99)
      if config.foldlevel then
        vim.opt_local.foldlevel = config.foldlevel
      end
    end,
  })

  local formatter = style_find_formatter(config)

  if vim.g.style_format_on_save then
    -- 使用 exts 或 filetype 注册 autocmd
    if config.exts and #config.exts > 0 then
      -- 有 exts：使用扩展名匹配
      local exts = {}
      for i, ext in ipairs(config.exts) do
        exts[i] = "*." .. ext
      end
      vim.api.nvim_create_autocmd("BufWritePost", {
        group = style.augroup,
        pattern = exts,
        callback = function()
          style_format(formatter)
        end,
      })
    else
      -- 无 exts：使用 filetype 匹配 (BufWritePost 无法匹配 filetype)
      vim.api.nvim_create_autocmd("BufWritePost", {
        group = style.augroup,
        pattern = "*",
        callback = function()
          if vim.bo.filetype ~= ft then
            return
          end
          style_format(formatter)
        end,
      })
    end
  end
end

-- 为每个文件类型注册自动命令
for ft, config in pairs(style.filetypes) do
  style_filetype(ft, config)
end

-- =============================================================================
-- 实用功能
-- =============================================================================

-- 启用 autoread
vim.opt.autoread = true

-- 创建自动命令组
-- 触发 checktime 当文件变化时
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = style.augroup,
  pattern = "*",
  command = 'checktime',
})

-- 文件变化后的通知
-- vim.api.nvim_create_autocmd("FileChangedShellPost", {
--   group = style.augroup,
--   pattern = "*",
--   callback = function()
--     vim.notify("✅️ File changed on disk. Buffer reloaded.", vim.log.levels.INFO)
--   end,
-- })

-- 自动跳转到上一次打开的位置
vim.api.nvim_create_autocmd("BufReadPost", {
  group = style.augroup,
  pattern = "*",
  callback = function()
    -- 检查是否有效且不是 commit 文件
    local mark_pos = vim.fn.getpos("''")
    if mark_pos[2] >= 1 and mark_pos[2] <= vim.fn.line("$") and vim.bo.filetype ~= "commit" then
      vim.cmd('normal! g`"')
    end
  end,
})

-- 自动创建父目录（保存文件时）
vim.api.nvim_create_autocmd({ "BufWritePre", "FileWritePre" }, {
  group = style.augroup,
  pattern = "*",
  callback = function(ev)
    local fname = vim.api.nvim_buf_get_name(ev.buf)
    -- 排除 URI（包含 ://）
    if fname:find("://") == nil then
      local parent_dir = vim.fn.fnamemodify(fname, ":p:h")
      vim.fn.mkdir(parent_dir, "p")
    end
  end,
})

-- 进入插入模式时禁用忽略大小写
vim.api.nvim_create_autocmd("InsertEnter", {
  group = style.augroup,
  pattern = "*",
  callback = function()
    vim.opt.ignorecase = false
  end,
})

-- 离开插入模式时启用忽略大小写
vim.api.nvim_create_autocmd("InsertLeave", {
  group = style.augroup,
  pattern = "*",
  callback = function()
    vim.opt.ignorecase = true
  end,
})

-- =============================================================================
-- 用户命令
-- =============================================================================

--- 手动格式化当前文件
---@param ftype string|nil 文件类型，nil 表示使用当前 buffer 的 filetype
function style_format_toggle(ftype)
  ftype = ftype or vim.bo.filetype
  local config = style.filetypes[ftype]

  -- 先保存文件
  vim.cmd("silent! write")

  -- 如果 style_format_on_save = true，保存时已经自动格式化，不需要额外工作
  if vim.g.style_format_on_save then
    return
  end

  -- style_format_on_save = false，手动格式化
  local formatter = style_find_formatter(config)

  -- 执行格式化
  style_format(formatter, { verbose = true })
end

-- 手动格式化当前文件
vim.api.nvim_create_user_command("StyleFormat", function()
  style_format_toggle()
end, { desc = "Format current file using configured formatter" })

-- =============================================================================
-- EditorConfig 配置
-- =============================================================================

-- 启用 EditorConfig（Neovim 0.11+ 内置支持）
-- https://neovim.io/doc/user/editorconfig.html
vim.g.editorconfig = true
-- => EditorConfig 在 ftplugins 和 FileType autocmds 之后应用
