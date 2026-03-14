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
        chat = {
            window = {
                layout = "vertical",
                full_height = true,
                position = "right",
                width = 0.3,
                border = "single",
            },
        },
    },
    
    -- Configure interactions for keymaps
    interactions = {
        chat = {
            adapter = "default",
            keymaps = {
                options = {
                    modes = { n = "?" },
                    callback = "keymaps.options",
                    description = "Show options",
                },
                send = {
                    modes = { n = "<CR>", i = "<CR>" },
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
        intro_message = "欢迎使用 CodeCompanion ✨! 按 ? 查看选项，Enter 选择",
    },
})
