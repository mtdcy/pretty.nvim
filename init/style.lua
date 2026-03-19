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
--
-- 设计理念：
--   - 优先使用 EditorConfig 统一风格
--   - 自动化工具格式化代码
--   - 减少手动配置
-- =============================================================================

vim.g.style_format_on_save = false

-- =============================================================================
-- EditorConfig 配置
-- =============================================================================

-- 启用 EditorConfig（Neovim 0.11+ 内置支持）
-- https://neovim.io/doc/user/editorconfig.html
vim.g.editorconfig = true
-- => EditorConfig 在 ftplugins 和 FileType autocmds 之后应用

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

-- 折叠方法：手动
vim.opt.foldmethod = "manual"

-- =============================================================================
-- 文件类型特定配置
-- =============================================================================
-- 注意：.editorconfig 会覆盖这些设置

-- style 模块
local style = {}

-- =============================================================================
-- 文件类型配置数据结构
-- =============================================================================
-- 格式：filetype = { et, ts, sw, foldmethod='xxx', foldlevel=n, command='xxx', files={}, ext={} }
--
-- 必需项（位置参数）:
--   [1] et        : expandtab (布尔值)
--   [2] ts        : tabstop (数字)
--   [3] sw        : shiftwidth (数字)
--
-- 可选项（命名参数，不必按顺序）:
--   foldmethod  : foldmethod (字符串，默认不设置)
--   foldlevel   : foldlevel (数字，默认 99)
--   command     : 格式化命令（字符串，如 'stylua'，默认不设置）
--   files       : 配置文件数组（如 {'.stylua.toml'}，默认不设置）
--   ext         : 文件扩展名数组（如 {'lua'}，默认为 {filetype}）
--
-- 示例：
--   lua = { true, 2, 2, foldmethod='syntax', foldlevel=99, command='stylua', files={'.stylua.toml'} }
--   vim = { true, 4, 4, foldmethod='marker' }
--   make = { false, 4, 4 }                        -- 使用制表符
-- =============================================================================

style.filetypes = {

  -- Makefile：4 空格，使用制表符
  make = { false, 4, 4 },

  -- VimL：4 空格缩进，标记折叠
  vim = { true, 4, 4, foldmethod = "marker" },

  -- Lua：2 空格缩进，语法折叠，自动格式化
  lua = {
    true,
    2,
    2,
    command = "stylua",
    files = { ".stylua.toml", ".styluaignore" },
    ext = { "lua" },
    foldmethod = "syntax",
    foldlevel = 99,
  },

  -- YAML：2 空格缩进，缩进折叠
  yaml = {
    true,
    2,
    2,
    command = "yamlfix",
    ext = { "yaml", "yml" },
    foldmethod = "indent",
    foldlevel = 99,
  },

  -- Markdown：2 空格缩进
  markdown = { true, 2, 2, foldlevel = 99 },

  -- Python：4 空格缩进，缩进折叠
  python = { true, 4, 4, foldmethod = "indent" },

  -- HTML/CSS：2 空格缩进，语法折叠
  html = { true, 2, 2, foldmethod = "syntax" },
  css = { true, 2, 2, foldmethod = "syntax" },

  -- JSON：2 空格缩进，忽略顶层括号
  json = { true, 2, 2, foldlevel = 1 },
  jsonc = { true, 2, 2, foldlevel = 1 },

  -- JavaScript：2 空格缩进
  javascript = { true, 2, 2 },

  -- TypeScript：2 空格缩进
  typescript = { true, 2, 2 },
}

-- =============================================================================
-- 自动格式化工具
-- =============================================================================

-- 创建自动命令组
style.augroup = vim.api.nvim_create_augroup("StyleGroup", { clear = true })

--- 查找格式化工具
---@param command string 命令名称
---@param files table|nil 配置文件数组
---@return string|nil 工具路径，找不到返回 nil
local function style_find_executable(command, files)
  -- 检查配置文件是否存在（如果有指定）
  if files then
    local config_found = false
    for _, file in ipairs(files) do
      if vim.fn.findfile(file, ".;") ~= "" then
        config_found = true
        break
      end
    end
    -- 如果配置文件没找到，不格式化
    if not config_found then
      return nil
    end
  end

  -- 使用 FindExecutable 获取完整路径（VimL 函数）
  local executable = vim.fn.call("FindExecutable", { command })

  -- 检查返回值
  if executable and executable ~= "" then
    return executable
  end

  return nil
end

--- 启用格式化工具
---@param exts table 文件扩展名数组
---@param command string 命令名称
---@param files table|nil 配置文件数组
local function style_enable_formatter(exts, command, files)
  local executable = style_find_executable(command, files)
  if not executable or executable == "" then
    -- 静默失败，不显示警告（可能用户没安装）
    return
  end

  -- 为每个扩展名注册 autocmd
  for _, ext in ipairs(exts) do
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = style.augroup,
      pattern = "*." .. ext,
      callback = function()
        vim.cmd("silent! !" .. executable .. " %")
      end,
    })
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

  if vim.g.style_format_on_save then
    -- 如果定义了 command，启用自动格式化
    if config.command then
      -- 使用 ext 或默认为 {ft}
      local exts = config.ext or { ft }
      style_enable_formatter(exts, config.command, config.files)
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
function style_format(ftype)
  ftype = ftype or vim.bo.filetype
  local config = style.filetypes[ftype]

  if not config then
    vim.notify("❌ No formatter for filetype: " .. ftype, vim.log.levels.WARN)
    return
  end

  if not config.command then
    vim.notify("⚠️ No formatter command defined for " .. ftype, vim.log.levels.INFO)
    return
  end

  -- 先保存文件
  vim.cmd("silent! write")

  -- 如果 style_format_on_save = true，保存时已经自动格式化，不需要额外工作
  if vim.g.style_format_on_save then
    vim.notify("✅ Formatted on save with " .. config.command, vim.log.levels.INFO)
    return
  end

  -- style_format_on_save = false，手动格式化
  local executable = style_find_executable(config.command, config.files)
  if not executable then
    vim.notify("❌ Formatter not found: " .. config.command, vim.log.levels.ERROR)
    return
  end

  -- 执行格式化（使用 system() 捕获输出）
  local bufname = vim.api.nvim_buf_get_name(0)
  local cmd = executable .. " " .. vim.fn.fnameescape(bufname)
  local output = vim.fn.system(cmd)

  -- 检查错误
  if vim.v.shell_error ~= 0 then
    vim.notify("❌ Failed: " .. output, vim.log.levels.ERROR)
    return
  end

  -- 重新加载文件
  vim.cmd("checktime")

  vim.notify("✅ Formatted with " .. config.command, vim.log.levels.INFO)
end

-- 手动格式化当前文件
vim.api.nvim_create_user_command("StyleFormat", function()
  style_format()
end, { desc = "Format current file using configured formatter" })
