local M = {}

---@class EmojiConfig
---@field enable_cmp_integration? boolean

---@type EmojiConfig
M.options = {
  enable_cmp_integration = false,
}

---@param options? EmojiConfig
function M.setup(options)
  M.options = vim.tbl_deep_extend("force", {}, M.options, options or {})
end

return M
