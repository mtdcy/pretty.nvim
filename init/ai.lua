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
            prompt = vim.g.pretty_ai_prompt,
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

            intro_message = vim.g.pretty_ai_message,
        },
        icons = {
            warning = "⚠️ ",
        },
    },

    -- Configure interactions
    interactions = {
        chat = {
            adapter = "default",
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
            opts = {
                -- Prompt decorator: automatically add context to user messages
                ---@param message string
                ---@param adapter table
                ---@param context table
                ---@return string
                prompt_decorator = function(message, adapter, context)
                    -- Skip empty messages
                    if not message or message:match("^%s*$") then
                        return message
                    end

                    local parts = {}
                    local mode = vim.fn.mode()

                    -- Add current file reference
                    table.insert(parts, "📄 File: #{buffer}(" .. vim.g.pretty_ai_bufname .. ")")

                    -- Add visual selection ( visual mode )
                    -- Add cursor line (non-Visual mode)
                    if mode == "v" or mode == "V" or mode == "\22" then
                        local start_pos = vim.fn.getpos("v")
                        local end_pos = vim.fn.getpos(".")
                        local start_line = start_pos[2]
                        local end_line = end_pos[2]
                        local lines = vim.api.nvim_buf_get_lines(vim.g.pretty_ai_bufnr, start_line - 1, end_line, false)
                        if #lines > 0 then
                            table.insert(parts, "📋 Selection:\n```\n" .. table.concat(lines, "\n") .. "\n```")
                        else
                            table.insert(parts, "📍 Cursor: line #" .. vim.g.pretty_ai_line)
                        end
                    else
                        table.insert(parts, "📍 Cursor: line #" .. vim.g.pretty_ai_line)
                    end

                    -- Build final message: context first, user message last
                    if #parts > 0 then
                        return table.concat(parts, "\n\n") .. "\n\n" .. message
                    end

                    return message
                end,
            },
            keymaps = {
                options = {
                    modes = { n = "?" },
                    callback = "keymaps.options",
                    description = "Show options",
                },
                send = {
                    -- only send in normal mode
                    modes = { n = "<CR>" },
                    callback = "keymaps.send",
                    description = "Send message",
                },
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
                diff = false,
                toggle = false,
            },
        },
    },

    opts = {
        language = "Chinese",
        log_level = "INFO",
    },
})
