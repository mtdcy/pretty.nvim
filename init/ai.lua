-- AI: codecompanion.nvim - Lua configuration
-- This file is loaded by init/ai.vim
-- Only adapters setup here, all logic moved to ai.vim

local ok, codecompanion = pcall(require, "codecompanion")
if not ok then
    vim.notify("codecompanion.nvim not found", vim.log.levels.WARN)
    return
end

-- Get environment variables (set by ai.vim)
local base_url = os.getenv("OPENAI_BASE_URL") or "http://localhost:11434"
local api_key = os.getenv("OPENAI_API_KEY") or ""

-- Remove /v1 suffix if present (adapter will add it)
if base_url and base_url:match("/v1$") then
    base_url = base_url:gsub("/v1$", "")
end

-- OPENAI_MODEL > OPENAI_MODEL_CODING
local model = os.getenv("OPENAI_MODEL") or os.getenv("OPENAI_MODEL_CODING") or "qwen3-coder-next"

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
                            choices = { model },  -- Always include default model in choices
                        },
                    },
                })
            end,
        },
    },
    strategies = {
        chat = {
            adapter = "default",
            window = {
                layout = "float",
                width = 0.45,
                height = 0.8,
                relative = "editor",
                row = 0.1,
                col = 0.55,
                border = "rounded",
                sticky = true,
            },
        },
        inline = {
            adapter = "default",
        },
    },
    opts = {
        language = "Chinese",
        log_level = "DEBUG",
    },
})
