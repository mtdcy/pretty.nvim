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
--
-- 💡 为了获得性能与体验及行业标准统一，原则上：
--      外置工具 > treesitter > vim 内置
-- =============================================================================

-- ❌ nvim-treesitter 所提供的下载功能并不能覆盖其所带来的不稳定性
-- ⚠️ 启用 nvim-treesitter 需要安装 gcc
-- 💡 仅使用预编译的 parsers
-- ✅ 仅使用内置的 vim.treesitter 接口
--
-- 检查：
--  - 代码折叠  : zc
--  - 代码高亮  : InspectTree

-- 启用 autoread
vim.opt.autoread = true

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
-- 全局折叠配置 - Treesitter
-- =============================================================================
-- 默认折叠，手动开关

-- 全局折叠设置 - 💡 默认使用 Treesitter，更准确
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevelstart = 99 -- 默认不折叠
vim.opt.foldnestmax = 1
vim.opt.foldminlines = 3 -- 不折叠最小的 if-else 语句
vim.opt.fillchars = vim.opt.fillchars + { fold = " " } -- 隐藏 v:folddashes（注意：\ 后面有空格）

-- 设置 foldtext
_G.pretty_style_foldtext = function()
  local text = vim.fn.getline(vim.v.foldstart)
  local lines = vim.v.foldend - vim.v.foldstart
  return text .. " 󰍻 " .. lines .. " more lines "
end
vim.opt.foldtext = "v:lua.pretty_style_foldtext()"

-- vim.opt.foldcolumn = "1" -- 与 vim-signify 冲突时调整

-- 💡 markdown 折叠需要特殊设置 - ⚠️ 遇到代码块会停止折叠
vim.g.markdown_folding = 1

-- ⚠️ 禁用推荐样式，稍后在 style_filetypes 中设置
vim.g.go_recommended_style = 0

-- =============================================================================
-- 文件类型特定配置
-- 💡 .editorconfig 会覆盖这些设置
-- =============================================================================
-- 格式：filetype = { et=true, ts=2, sw=2, foldmethod='marker', foldlevel=n, formatter={} }
--
-- 全部使用命名参数，可扩展性强，易于阅读和维护
--
-- 可选项（任意顺序）:
--   et         : expandtab (布尔值) - 使用空格代替制表符
--   ts         : tabstop (数字)     - 制表符宽度
--   sw         : shiftwidth (数字)  - 缩进宽度
--   foldmethod : foldmethod (字符串，默认不设置)
--   foldlevel  : foldlevel (数字，默认 99)
--   foldtext   : foldtext (字符串或函数，默认不设置)
--   formatexpr : formatexpr (字符串或函数，默认不设置)
--   indentexpr : indentexpr (字符串或函数，默认不设置)
--   formatter  : 格式化配置（单一命令或命令数组）
--   exts       : 文件扩展名数组（如 {'lua'}，默认为 {filetype}）
--   ...        : 其他 vim.opt_local 支持的选项（如 textwidth, wrapmargin 等）
--
-- formatter 配置格式:
--
--   1. 单一命令（字典格式）:
--      formatter = { command = '...', files = {...}, opts = {...} }
--
--   2. 多个命令（数组格式，优先选择第一个可用的）:
--      formatter = {
--        { command = 'command1', files = {...}, opts = {...} },
--        { command = 'command2', files = {...}, opts = {...} },
--      }
--
--   字段说明:
--     command : 格式化命令（字符串，如 'stylua'）
--     files   : 配置文件数组（如 {'.stylua.toml'}，默认不设置）
--     opts    : 命令行参数数组（如 {'-i', '2'}，默认不设置）
--
--   最终命令组成：command opts %
--
-- 💡 如果定义 formatter => 保存时自动格式化
-- 💡 formatter 可以是字典（单一命令）或数组（多个命令备选）或 函数
--
-- 示例:
--   lua = { et=true, ts=2, sw=2, foldmethod='syntax', foldlevel=99, formatter = { command='stylua', files={'.stylua.toml'} } }
--   yaml = { et=true, ts=2, sw=2, formatter = { {command='yamlfix'}, {command='yq'} } } -- 备选
--   vim = { et=true, ts=4, sw=4, foldmethod='marker' }
--   make = { et=false, ts=4, sw=4 } -- 使用制表符
-- =============================================================================

-- 默认风格
local style_et_ts_4 = { et = true, ts = 4, sw = 4 }

-- 使用 Google/llvm 风格
local style_et_ts_2 = { et = true, ts = 2, sw = 2 }

-- 强制使用制表符
local style_noet_ts_4 = { et = false, ts = 4, sw = 4 }

local style_extend = function(base, opts)
  return vim.tbl_extend("force", base or {}, opts or {})
end

local style_c_cpp = style_extend(style_et_ts_2, {
  formatter = {
    -- 💡 默认使用 clang-format: 优先尊重 .clang-format 配置文件
    { command = "clang-format", files = { ".clang-format" }, opts = { "-style=file", "-i" } },
    { command = "clang-format", opts = { "-style=Google", "-i" } },
  },
})

local style_json_json5 = style_extend(style_et_ts_2, {
  formatter = { command = "fixjson", opts = { "-i", "2", "-w" } },
})

local style_eslint = style_extend(style_et_ts_2, {
  -- ⚠️ eslint 需要提前安装好依赖，否则会报错。
  formatter = {
    command = "eslint",
    files = { "eslint.config.js", "eslint.config.mjs", "eslint.config.cjs" },
    opts = { "--fix" },
  },
})

local style_filetypes = {
  -- c,cpp
  c = style_c_cpp,
  cpp = style_c_cpp,

  -- Makefile：4 空格，使用制表符
  -- 💡 tree-sitter-make 没有折叠功能
  make = style_extend(style_noet_ts_4, { foldmethod = "indent" }),

  -- shell script (注释示例)
  -- sh = { et = true, ts = 4, sw = 4, formatter = { command = "shfmt", opts = { "-w", "-kp", "-i", "4", "-ln", "bash", "-sr" } } },

  -- VimL：4 空格缩进，标记折叠
  vim = style_extend(style_et_ts_4, { foldmethod = "marker", foldlevel = 0 }),

  -- Lua：2 空格缩进，语法折叠，自动格式化
  lua = style_extend(style_et_ts_2, {
    exts = { "lua" },
    formatter = {
      command = "stylua",
      files = { ".stylua.toml", ".styluaignore" },
      opts = {},
    },
  }),

  -- YAML：2 空格缩进，缩进折叠
  yaml = style_extend(style_et_ts_2, {
    exts = { "yaml", "yml" },
    formatter = {
      -- 优先使用项目的配置文件
      { command = "yamlfix", files = { ".yamlfix.toml" } },
      -- 默认使用我们提供的配置文件
      { command = "yamlfix", opts = { "-c", vim.g.pretty_home .. "/lintrc/yamlfix.toml" } },
    },
  }),

  -- JSON：2 空格缩进，忽略顶层括号
  json = style_json_json5,
  json5 = style_json_json5,

  -- Markdown：2 空格缩进, H2 折叠 - ⚠️ @see g:markdown_folding
  markdown = style_extend(style_et_ts_2, { foldlevel = 1 }),

  -- HTML/CSS：2 空格缩进
  html = style_et_ts_2,
  css = style_et_ts_2,

  -- JavaScript|TypeScript
  javascript = style_eslint,
  typescript = style_eslint,

  -- Rust：4 空格缩进，自动格式化
  rust = style_extend(style_et_ts_4, { formatter = { command = "rustfmt" } }),

  -- Go: goimports > gofmt
  --- 💡 Go 语言官方强制使用 Tab 缩进
  go = style_extend(style_noet_ts_4, {
    formatter = {
      { command = "goimports", opts = { "-w" } },
      { command = "gofmt", opts = { "-w" } },
    },
  }),

  -- Python：4 空格缩进，缩进折叠
  python = style_extend(style_et_ts_4, {
    foldmethod = "indent",
    formatter = {
      -- 优先级：ruff > yapf > autopep8
      { command = "ruff", files = { "ruff.toml", ".ruff.toml" } },
      { command = "yapf", files = { ".style.yapf" } },
      { command = "autopep8", opts = { "--max-line-length=120", "--in-place" } },
    },
  }),
}

-- =============================================================================
-- 自动格式化工具
-- =============================================================================

-- 默认格式化函数：优先 LSP，fallback 到内置 =
-- 💡 这对 editorConfig 同样有效
---@param opts? table
local style_default_formatter = function(opts)
  -- 尝试使用 LSP 格式化
  local clients = vim.lsp.get_clients({ bufnr = 0 })

  -- ⚠️ lsp 可能不支持 formatting 或者没有开启
  if clients and #clients > 0 then
    -- 记录格式化前的 changedtick
    local before = vim.b.changedtick

    -- 调用 LSP 格式化（同步等待）
    vim.lsp.buf.format({ timeout_ms = 2000 })

    -- 检查 changedtick 是否变化（判断是否真的格式化了）
    if vim.b.changedtick ~= before then
      if opts and opts.verbose then
        vim.notify("✅ Format with vim.lsp", vim.log.levels.INFO)
      end
      return
    end
  end

  -- Fallback: 使用内置 = 格式化
  vim.cmd("normal! gg=G")
  vim.cmd("normal! ``")

  if opts and opts.verbose then
    vim.notify("✅ Format done (builtin)", vim.log.levels.INFO)
  end
end

--- 查找格式化工具
---@param opts {} filetype 对应的配置
---@return string|function 工具命令 or style_default_formatter
local function style_find_formatter(opts)
  if not opts then
    return style_default_formatter
  end

  if type(opts) == "function" then
    return opts()
  end

  local formatters = #opts > 0 and opts or { opts }
  for _, formatter in ipairs(formatters) do
    if not formatter.command then
      goto next
    end

    -- 检查配置文件是否存在（如果有指定）
    if formatter.files then
      local found = false
      for _, file in ipairs(formatter.files) do
        if vim.fn.findfile(file, ".;") ~= "" then
          found = true
          break
        end
      end

      -- 如果配置文件没找到，跳过当前 formatter
      if not found then
        goto next
      end
    end

    -- 使用 PrettyFindExecutable 获取完整路径（VimL 函数）
    local executable = vim.fn.PrettyFindExecutable(formatter.command)
    if executable and executable ~= "" then
      -- 组建完整命令
      if formatter.opts then
        return executable .. " " .. table.concat(formatter.opts, " ")
      else
        return executable
      end
    end

    ::next::
  end
  return style_default_formatter
end

--- 执行命令（支持 string 和 function 两种类型）
---@param opts? table : { verbose = false }
local function style_do_format(opts)
  local config = style_extend(opts or {}, style_filetypes[vim.bo.filetype] or {})
  local formatter = style_find_formatter(config.formatter)

  if type(formatter) == "function" then
    -- Lua 函数：直接调用
    formatter(opts)
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

  vim.cmd("checktime")
end

--- 为文件类型应用配置
---@param ft string 文件类型
---@param config table 配置表 @see style_filetypes
local function style_do_filetype(ft, config)
  vim.api.nvim_create_autocmd("FileType", {
    group = "PrettyStyleGroup",
    pattern = ft,
    callback = function()
      -- 动态遍历所有命名参数（排除 formatter exts）
      -- 支持 foldmethod, foldlevel, formatexpr, indentexpr 等所有 vim.opt_local 选项
      local skip_keys = { formatter = true, exts = true }
      for key, value in pairs(config) do
        if key ~= "formatter" and key ~= "exts" then
          vim.opt_local[key] = value
        end
      end
    end,
  })

  local formatter = style_find_formatter(config.formatter)

  if formatter ~= style_default_formatter then
    -- 使用 exts 或 filetype 注册 autocmd
    if config.exts and #config.exts > 0 then
      -- 有 exts：使用扩展名匹配
      local exts = {}
      for i, ext in ipairs(config.exts) do
        exts[i] = "*." .. ext
      end
      vim.api.nvim_create_autocmd("BufWritePost", {
        group = "PrettyStyleGroup",
        pattern = exts,
        callback = function()
          style_do_format()
        end,
      })
    else
      -- 无 exts：使用 filetype 匹配 (BufWritePost 无法匹配 filetype)
      vim.api.nvim_create_autocmd("BufWritePost", {
        group = "PrettyStyleGroup",
        pattern = "*",
        callback = function()
          if vim.bo.filetype ~= ft then
            return
          end
          style_do_format()
        end,
      })
    end
  end
end

-- 为每个文件类型注册自动命令
local style_main = function()
  vim.api.nvim_create_augroup("PrettyStyleGroup", { clear = true })

  for ft, config in pairs(style_filetypes) do
    style_do_filetype(ft, config)
  end
end

style_main()

-- =============================================================================
-- 实用功能
-- =============================================================================

-- 自动跳转到上一次打开的位置
vim.api.nvim_create_autocmd("BufReadPost", {
  group = "PrettyStyleGroup",
  pattern = "*",
  callback = function()
    -- 检查是否有效且不是 commit 文件
    local mark_pos = vim.fn.getpos("''")
    if mark_pos[2] >= 1 and mark_pos[2] <= vim.fn.line("$") and vim.bo.filetype ~= "commit" then
      vim.cmd("normal! g'\"")
    end
  end,
})

-- 自动创建父目录（保存文件时）
vim.api.nvim_create_autocmd({ "BufWritePre", "FileWritePre" }, {
  group = "PrettyStyleGroup",
  pattern = "*",
  callback = function(event)
    -- vim.notify(vim.inspect(event))
    if vim.fn.filereadable(event.file) > 0 then
      return
    end

    -- 排除 URL
    if not string.match(event.file, "^[a-z]+://") then
      vim.fn.mkdir(vim.fn.fnamemodify(event.file, ":p:h"), "p")
    end
  end,
})

-- 进入插入模式时禁用忽略大小写
vim.api.nvim_create_autocmd("InsertEnter", {
  group = "PrettyStyleGroup",
  pattern = "*",
  callback = function()
    vim.opt.ignorecase = false
  end,
})

-- 离开插入模式时启用忽略大小写
vim.api.nvim_create_autocmd("InsertLeave", {
  group = "PrettyStyleGroup",
  pattern = "*",
  callback = function()
    vim.opt.ignorecase = true
  end,
})

-- =============================================================================
-- 用户命令
-- =============================================================================

-- 手动格式化当前文件
vim.api.nvim_create_user_command("StyleFormat", function()
  style_do_format({ verbose = true })
end, { desc = "Format current file using configured formatter" })

-- =============================================================================
-- EditorConfig 配置
-- =============================================================================

-- 启用 EditorConfig（Neovim 0.11+ 内置支持）
-- https://neovim.io/doc/user/editorconfig.html
vim.g.editorconfig = true
-- 💡 .editorconfig 会覆盖上面的默认设置 💡
