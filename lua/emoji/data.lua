local utils = require("emoji.utils")

local M = {}

local cache = {
  full = nil,
  minimal = nil,
}

local function get_plugin_data_path()
  -- Get the plugin root directory
  local plugin_root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h:h")
  return plugin_root .. "/lua/data/"
end

local function load_emojis(use_minimal)
  local cache_key = use_minimal and "minimal" or "full"
  if cache[cache_key] then
    return cache[cache_key]
  end

  local base_path = get_plugin_data_path()
  local filename = use_minimal and "emojis.minimal.json" or "emojis.json"
  local path = base_path .. filename

  local data = utils.load_from_json(path)
  local items = {}
  for _, e in ipairs(data) do
    if e.character ~= nil and e.unicodeName ~= nil then
      table.insert(items, {
        insert_text = e.character,
        label = e.character .. " " .. e.unicodeName,
        character = e.character,
        name = e.unicodeName,
        group = e.group,
        slug = e.slug,
      })
    end
  end

  cache[cache_key] = items
  return cache[cache_key]
end

local function groups_for(items)
  local seen = {}
  local groups = {}
  for _, item in ipairs(items) do
    if item.group ~= nil and not seen[item.group] then
      seen[item.group] = true
      table.insert(groups, item.group)
    end
  end
  table.sort(groups)
  return groups
end

M.emoji_items = function(use_minimal)
  return load_emojis(use_minimal)
end

M.emoji_groups = function(use_minimal)
  return groups_for(load_emojis(use_minimal))
end

return M
