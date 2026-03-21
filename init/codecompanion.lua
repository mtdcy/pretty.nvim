-- AI: codecompanion.nvim - Lua configuration
-- This file is loaded by init/ai.vim
--
-- 快捷键：保持默认值。codecompanion.nvim 只支持覆盖模式，没办法清除
--  => 在 aicoding.lua 中 覆盖需要的快捷键

local ok, codecompanion = pcall(require, "codecompanion")
if not ok then
  vim.notify("codecompanion.nvim not found", vim.log.levels.WARN)
  return
end

-- Get environment variables
local base_url = os.getenv("OPENAI_BASE_URL") or "http://localhost:11434"
local api_key = os.getenv("OPENAI_API_KEY") or ""
local model = os.getenv("OPENAI_MODEL") or os.getenv("OPENAI_MODEL_CODING") or "qwen3-coder-next"

-- Remove /v1 suffix if present
if base_url and base_url:match("/v1$") then
  base_url = base_url:gsub("/v1$", "")
end

local aicoding = function()
  return require("codecompanion.adapters").extend("openai_compatible", {
    name = "OpenAI Compatible",
    env = {
      api_key = api_key,
      url = base_url,
    },
    schema = {
      model = {
        default = model,
        choices = { model },
      },
    },
  })
end

local floating_window = {
  position = "bottom",
  width = 0.8,
  height = 0.8,
  border = "single",
  relative = "editor",
  opts = {},
}

local display = {
  action_palette = {
    prompt = "✨ AI Coding: ", -- Title used for interactive LLM calls
    -- telescope|mini_pick|snacks|default
    -- provider = providers.action_palette,
    provider = "telescope", -- work with Telescope
    opts = {
      show_preset_actions = true, -- @see CodeCompanionActions
      show_preset_prompts = true,
      show_preset_rules = true,
      title = vim.g.finder_tips,
    },
  },
  chat = {
    window = vim.tbl_extend("force", floating_window, {
      layout = "float",
      full_height = false, -- float 一定要设置这个
    }),

    -- Options for an floating windows
    floating_window = floating_window,

    -- Chat buffer options --------------------------------------------------
    intro_message = "", -- show only once, use our AIChatShow
    show_header_separator = true, -- Show header separators in the chat buffer? Set this to false if you're using an external markdown formatting plugin
  },
}

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
      ctx.language,
      ctx.cwd,
      ctx.date,
      ctx.nvim_version,
      ctx.os
    )
end

codecompanion.setup({
  adapters = {
    http = {
      default = aicoding,
      opts = {
        allow_insecure = false, -- Allow insecure connections?
        show_presets = true, -- Show preset adapters
        show_model_choices = true, -- Show model choices when changing adapter
      },
    },
    acp = nil,
    opts = {},
  },

  -- DISPLAY OPTIONS ----------------------------------------------------------
  display = display,

  -- Configure interactions
  interactions = {
    -- BACKGROUND INTERACTION -------------------------------------------------
    background = nil, -- 暂时没发现这个需求点在哪
    -- CHAT INTERACTION -------------------------------------------------------
    chat = {
      adapter = "default",
      roles = {
        user = "✨ AI Coding",
        -- Custom LLM header name (default: "CodeCompanion (OpenAI Compatible)")
        llm = "🌹 AI Agent",
      },
      opts = {
        ---This is the default prompt which is sent with every request in the chat interactions
        system_prompt = system_prompts,
      },
    },
    -- INLINE INTERACTION -----------------------------------------------------
    inline = {
      adapter = "default",
    },
    -- CMD INTERACTION --------------------------------------------------------
    cmd = nil, -- 暂时没发现这个需求点在哪
    shared = {
    },
  },
  -- MCP SERVERS ----------------------------------------------------------------
  mcp = {},
  -- PROMPT LIBRARIES ---------------------------------------------------------
  -- prompt_library = {},
  -- RULES -------------------------------------------------------------------
  -- 定义我们自己的规则文件 - 唯一
  rules = {
    default = {
      description = "Project rules",
      files = { "PROJECT.md" }, -- markdown 格式
      parser = "claude", -- 支持 markdown
      is_preset = true,
    },
    opts = {
      chat = {
        enabled = true, -- Automatically add memory to new chat buffers?
        autoload = "default", -- autoload rules
      },
      show_presets = true, -- Show the preset rules files?
      show_defaults = true, -- 显示预设
    },
  },
  -- EXTENSIONS ------------------------------------------------------
  extensions = {},

  -- GENERAL OPTIONS ----------------------------------------------------------
  opts = {
    language = "Chinese",
    log_level = "TRACE",
  },
})

return {
  inline = {
    submit = function(prompt)
      vim.cmd("CodeCompanion " .. prompt)
    end,
  },
  chat = {
    launch = function()
      vim.cmd("CodeCompanionActions")
    end,
    toggle = function()
      vim.cmd("CodeCompanionChat Toggle")
    end,
    submit = function()
      require("codecompanion").last_chat():submit()
    end,
  },
  context = {
    buffer = function()
      return "#{buffer}"
    end,
  },
}
