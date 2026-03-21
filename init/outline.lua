-- =============================================================================
-- Code Outline: Aerial.nvim - 代码大纲配置
-- =============================================================================
-- 说明：
--   本文件负责 Aerial.nvim 的基础配置，包括：
--   1. 双后端配置（Treesitter 优先，LSP 备选）
--   2. 符号过滤（只显示重要的代码结构）
--   3. 快捷键绑定（导航 + 切换）
--   4. UI 配置（窗口位置、宽度等）
--
-- 设计理念：
--   - 轻量级（单文件展示）
--   - 实时更新（基于 AST 分析）
--   - 与 Tagbar 类似的体验（但更精确）
-- =============================================================================

local ok, aerial = pcall(require, "aerial")
if not ok then
  vim.notify("aerial.nvim not found", vim.log.levels.WARN)
  return
end

-- =============================================================================
-- Aerial 配置
-- =============================================================================

aerial.setup({
  -- 后端配置（双引擎）
  backends = { "treesitter", "lsp" },  -- Treesitter 优先，LSP 备选

  -- 符号过滤（只显示重要的代码结构）
  filter_kind = {
    "Class",
    "Constructor",
    "Enum",
    "Function",
    "Interface",
    "Module",
    "Method",
    "Struct",
    -- 以下符号默认隐藏（太详细）
    -- "Constant",
    -- "Field",
    -- "Variable",
    -- "Parameter",
  },

  -- UI 配置
  attach_mode = "global",      -- 全局模式（所有窗口共享大纲）
  show_guides = true,          -- 显示层级引导线
  autojump = false,            -- 不自动跳转（手动控制）

  -- 窗口配置
  layout = {
    min_width = 30,            -- 最小宽度
    default_direction = "right", -- 默认在右侧打开
    placement = "edge",        -- 靠边放置
  },

  -- 快捷键配置（在 aerial 窗口内）
  keymaps = {
    ["<CR>"] = "actions.jump",   -- 跳转到符号
    ["<Space>"] = "actions.jump",   -- 跳转到符号
    ["<2-LeftMouse>"] = "actions.jump",
    ["p"] = "actions.preview",   -- 预览
    ["q"] = "actions.close",     -- 关闭
  },

  -- 日志级别
  log_level = "warn",
})
