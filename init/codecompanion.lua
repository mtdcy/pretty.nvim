-- =============================================================================
-- AI: CodeCompanion.nvim - Adapter/Setup 配置
-- =============================================================================
-- 说明：
--   本文件负责 CodeCompanion 的核心配置，包括：
--   1. Adapter 配置（OpenAI Compatible）
--   2. UI 配置（floating window、display 选项）
--   3. System Prompts（上下文注入）
--   4. Rules 配置（PROJECT.md 项目规则）
--   5. 返回 engine 接口表（供 aicoding.lua 使用）
--
-- 设计理念：
--   - 与 aicoding.lua 共存（分工明确）
--   - aicoding.lua 负责入口函数、命令、快捷键
--   - codecompanion.lua 负责 adapter/setup/rules 配置
--
-- 快捷键：
--   - 保持默认值（codecompanion.nvim 只支持覆盖模式，无法清除）
--   - 在 aicoding.lua 中覆盖需要的快捷键
--
-- 使用方式：
--   由 aicoding.lua 通过 loadfile() 加载
-- =============================================================================

local ok, codecompanion = pcall(require, "codecompanion")
if not ok then
  vim.notify("codecompanion.nvim not found", vim.log.levels.WARN)
  return
end

-- =============================================================================
-- 环境变量
-- =============================================================================

local base_url = os.getenv("AICODING_BASE_URL") or "http://localhost:11434"
local model = os.getenv("AICODING_MODEL") or "qwen3-coder-next"

-- 移除模型前缀（如 bailian/qwen3.5-plus → qwen3.5-plus）
model = model:match("[^/\\]+$")

-- =============================================================================
-- Adapter 配置
-- =============================================================================

--- 支持：Dashscope、Ollama、以及其他 OpenAI 兼容接口
---   扩展 openai 而不是 openai_compatible, 因为后者把 url 写死了
local aicoding = function()
  return require("codecompanion.adapters").extend("openai", {
    name = "aicoding",
    formatted_name = "AICoding",
    url = base_url .. "/chat/completions",
    env = {
      api_key = "AICODING_API_KEY",
    },
    schema = {
      model = {
        default = model,
        choices = {
          -- Coding 模型一般没有图像理解能力
          [model] = { opts = { has_vision = false } },
        },
      },
    },
  })
end

-- =============================================================================
-- UI 配置
-- =============================================================================

local floating_window_border = vim.fn.PrettyBorders("PrettyYellow", "PrettyPurple", "AICoding")

-- Floating Window 配置（Chat 窗口）
local floating_window = {
  position = "bottom", -- 位置：底部
  width = 0.8, -- 宽度：80% 屏幕
  height = 0.7, -- 高度：70% 屏幕
  border = floating_window_border,
  relative = "editor", -- 相对：编辑器
  opts = {},
}

-- Display 配置
local display = {
  -- Action Palette（Actions 面板）
  action_palette = {
    prompt = "✨ AI Coding: ", -- 提示符
    provider = "telescope", -- 使用 Telescope 作为选择器
    opts = {
      show_preset_actions = true, -- 显示预设 Actions
      show_preset_prompts = true, -- 显示预设 Prompts
      show_preset_rules = true, -- 显示预设 Rules（PROJECT.md）
      title = vim.g.finder_tips, -- 标题（与 Finder 一致）
    },
  },

  -- Chat 窗口配置
  chat = {
    window = vim.tbl_extend("force", floating_window, {
      layout = "float", -- 布局：悬浮窗
      full_height = false, -- float 必须设置这个（不能占满高度）
    }),
    floating_window = floating_window,
    intro_message = "", -- 空（使用自定义 AIChatShow）
    show_header_separator = true, -- 显示头部的分隔线
  },

  -- Inline

  -- Diff 窗口配置: Inline:start_diff 中 设置 inline=true => Inline 模式不会弹出 Diff 窗口
  diff = {
    enabled = true,
    window = floating_window,
  },
}

-- =============================================================================
-- System Prompts
-- =============================================================================

--- 自定义 System Prompt
--- 在默认 prompt 基础上追加：
---   1. 语言要求（中文回复）
---   2. 用户环境信息（工作目录、日期、Neovim 版本、操作系统）
---   3. 代码变更输出格式（统一 diff/patch 格式）
local system_prompts = function(ctx)
  return ctx.default_system_prompt
    .. string.format(
      [[Additional context:
  - All non-code text responses must be written in the %s language.
  - The user's current working directory is %s.
  - The current date is %s.
  - The user's Neovim version is %s.
  - The user is working on a %s machine. Please respond with system specific commands if applicable.
  - Output Format for Code Changes:
  When suggesting code modifications, ALWAYS output in unified diff/patch format only:
  ```diff
  - original line
  + modified line
  ```

  Do NOT output the complete function/code block unless explicitly asked. Only show the changed lines with context.
  ]],
      ctx.language, -- 语言：Chinese
      ctx.cwd, -- 工作目录
      ctx.date, -- 当前日期
      ctx.nvim_version, -- Neovim 版本
      ctx.os -- 操作系统
    )
end

-- =============================================================================
-- CodeCompanion Setup
-- =============================================================================

codecompanion.setup({
  -- Adapter 配置
  adapters = {
    http = {
      default = aicoding, -- 默认使用上面定义的 aicoding adapter
      opts = {
        allow_insecure = false, -- 不允许不安全连接
        show_presets = true, -- 显示预设 adapters
        show_model_choices = false, -- 显示模型选择
      },
    },
    acp = nil, -- 禁用 ACP（Autocomplete Provider）
    opts = {},
  },

  -- Display 配置
  display = display,

  -- 交互配置
  interactions = {
    -- 后台交互（暂无需求）
    background = nil,

    -- Chat 交互
    chat = {
      adapter = "default", -- 使用默认 adapter
      roles = {
        user = "✨ AI Coding", -- 用户角色名称
        llm = "🌹 AI Agent", -- LLM 角色名称
      },
      slash_commands = {
        ["file"] = {
          opts = {
            provider = "telescope",
          },
        },
      },
      keymaps = {
        send = nil, -- 使用 aicoding.lua 的按键绑定
        completion = nil, -- 使用 nvim-cmp 的按键绑定
      },
      opts = {
        system_prompt = system_prompts, -- 使用上面定义的 system_prompt
        completion_provider = cmp,
      },
    },

    -- Inline 交互
    inline = {
      adapter = "default", -- 使用默认 adapter
    },

    -- Cmd 交互（暂无需求）
    cmd = nil,

    -- 共享配置
    shared = {},
  },

  -- MCP Servers（暂无配置）
  mcp = {},

  -- Rules 配置（项目规则文件）
  rules = {
    -- 默认规则：PROJECT.md
    default = {
      description = "Project rules",
      files = { "PROJECT.md" }, -- markdown 格式
      parser = "claude", -- 使用 claude parser（支持 markdown）
      is_preset = true, -- 标记为预设（通过特殊命令启动）
    },
    opts = {
      chat = {
        enabled = true, -- 自动添加到新 Chat
        autoload = "default", -- 自动加载 default rule
      },
      show_presets = true, -- 显示预设 rules（Actions 面板）
      show_defaults = true, -- 显示默认 rules
    },
  },

  -- 扩展（暂无配置）
  extensions = {},

  -- 通用选项
  opts = {
    language = "Chinese", -- 语言：中文
    log_level = "TRACE", -- 日志级别：TRACE（最详细，便于调试）
  },
})

-- =============================================================================
-- 返回 Engine 接口表（供 aicoding.lua 使用）
-- =============================================================================

return {
  -- Inline 接口
  inline = {
    -- @param args table
    -- @param callback function
    submit = function(args, callback)
      if callback then
        vim.api.nvim_create_autocmd("User", {
          once = true,
          pattern = { "CodeCompanionInlineFinished" },
          callback = callback,
        })
      end

      require("codecompanion").inline(args)
    end,
  },

  -- Chat 接口
  chat = {
    launch = function(args) -- 打开 Actions 面板
      vim.cmd("CodeCompanionActions")
    end,

    toggle = function(args, callback) -- 开关 Chat 窗口
      if callback then
        vim.api.nvim_create_autocmd("User", {
          once = true,
          pattern = { "CodeCompanionChatOpened", "CodeCompanionChatClosed", "CodeCompanionChatHidden" },
          callback = function(event)
            local opts = vim.deepcopy(event or {})

            opts.opened = opts.match and opts.match == "CodeCompanionChatOpened" or false

            callback(opts)
          end,
        })
      end

      vim.cmd("CodeCompanionChat Toggle")
    end,

    submit = function(args, callback) -- 提交当前消息
      if callback then
        vim.api.nvim_create_autocmd("User", {
          once = true,
          pattern = { "CodeCompanionChatDone" },
          callback = callback,
        })
      end

      require("codecompanion").last_chat():submit()
    end,
  },

  -- Context 接口
  context = {
    buffer = function()
      return "#{buffer}" -- 返回上下文标识符
    end,
  },
}
