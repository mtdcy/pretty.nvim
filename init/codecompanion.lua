-- AI: codecompanion.nvim - Lua configuration
-- This file is loaded by init/ai.vim

local ok, codecompanion = pcall(require, "codecompanion")
if not ok then
    vim.notify("codecompanion.nvim not found", vim.log.levels.WARN)
    return
end

-- Get environment variables
local base_url = os.getenv("OPENAI_BASE_URL") or "http://localhost:11434"
local api_key = os.getenv("OPENAI_API_KEY") or ""

-- Remove /v1 suffix if present
if base_url and base_url:match("/v1$") then
    base_url = base_url:gsub("/v1$", "")
end

local model = os.getenv("OPENAI_MODEL") or os.getenv("OPENAI_MODEL_CODING") or "qwen3-coder-next"

-- Set splitright for vertical splits to appear on the right
vim.opt.splitright = true

codecompanion.setup({
    adapters = {
        http = {
            default = function()
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
            end,
        },
    },

    -- Use display.chat.window for window configuration
    display = {
        action_palette = {
            prompt = "✨ AI Coding: ", -- Title used for interactive LLM calls
        },
        chat = {
            icons = {
                tool_in_progress = "🤖 ",
                tool_failure = "❌ ",
                tool_success = "✅ ",
                chat_context = "📎 ",
            },
            window = {
                layout = "vertical",
                full_height = true,
                position = "right",
                width = 0.3,
            },

            show_header_separator = true, -- Show header separators in the chat buffer? Set this to false if you're using an external markdown formatting plugin

            intro_message = "", -- show only once, use our AIChatShow
        },
        diff = {
          enabled = true,
          -- Options for any diff windows (extends from floating_window)
          window = {
            width = 0.9, ---@return number|fun(): number
            height = 0.8, ---@return number|fun(): number
            border = "single",
            relative = "editor",
            opts = {},
          },
          word_highlights = {
            additions = true,
            deletions = true,
          },
        },
        icons = {
            warning = "⚠️ ",
        },
    },

    -- Configure interactions
    interactions = {
        chat = {
            adapter = "default",
            opts = {
                system_prompt = function(ctx)
                    return ctx.default_system_prompt .. [[

## Output Format for Code Changes
When suggesting code modifications, ALWAYS output in unified diff/patch format only:
```diff
- original line
+ modified line
```

Do NOT output the complete function/code block unless explicitly asked. Only show the changed lines with context.
]]
                end,
            },
            roles = {
                user = "Coding with AI", -- no show Me
            },
            tools = {
                groups = {
                    opts = {
                        collapse_tools = false,
                    },
                },
            },
            keymaps = {
                options = {
                    modes = { n = "?" },
                    callback = "keymaps.options",
                    description = "Show options",
                },
                send = false,
                completion = false,
                regenerate = false,
                close = false,
                stop = false,
                clear = false,
                codeblock = false,
                yank_code = false,
                yank_codeblock = false,
                buffer_sync_all = false,
                buffer_sync_diff = false,
                next_chat = false,
                previous_chat = false,
                next_header = false,
                previous_header = false,
                change_adapter = false,
                fold_code = false,
                debug = false,
                toggle_system_prompt = false,
                toggle_help = false,
                scroll_up = false,
                scroll_down = false,
            },
        },
        inline = {
            adapter = "default",
            keymaps = {
                accept = false,
                reject = false,
                diff = {
                },
                toggle = {
                    callback = "keymaps.toggle",
                    description = "Toggle diff view",
                    index = 1,
                    modes = { n = "t" },
                },
                diff = {
                    callback = "keymaps.diff",
                    description = "Diff view",
                    index = 2,
                    modes = { n = "di" },
                },
                stop = {
                    callback = "keymaps.stop",
                    description = "Stop request",
                    index = 4,
                    modes = { n = "q" },
                },
            },
            opts = {
                placement = "replace",  -- 默认替换选区
            },
        },
        shared = {
          keymaps = {
            always_accept = {
              callback = "keymaps.always_accept",
              description = "Always accept changes in this buffer",
              index = 1,
              modes = { n = "g1" },
              opts = { nowait = true },
            },
            accept_change = {
              callback = "keymaps.accept_change",
              description = "Accept change",
              index = 2,
              modes = { n = "g2" },
              opts = { nowait = true, noremap = true },
            },
            reject_change = {
              callback = "keymaps.reject_change",
              description = "Reject change",
              index = 3,
              modes = { n = "g3" },
              opts = { nowait = true, noremap = true },
            },
            next_hunk = {
              callback = "keymaps.next_hunk",
              description = "Go to next hunk",
              modes = { n = "}" },
            },
            previous_hunk = {
              callback = "keymaps.previous_hunk",
              description = "Go to previous hunk",
              modes = { n = "{" },
            },
          },
        },
    },

    opts = {
        language = "Chinese",
        log_level = "INFO",
    },
})
