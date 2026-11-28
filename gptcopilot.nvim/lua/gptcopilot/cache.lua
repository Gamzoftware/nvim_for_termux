local M = { memory = {}, order = {}, loaded = false }
local function cache_path()
  return vim.fn.stdpath("cache") .. "/gptcopilot-cache.json"
end
function M.key(value) return vim.fn.sha256(vim.json.encode(value)) end
function M.get(key)
  if not M.loaded then
    M.loaded = true
    local opts = require("gptcopilot.config").get()
    if opts.cache.persist then
      local f = io.open(cache_path(), "r")
      if f then
        local raw = f:read("*a"); f:close()
        local ok, data = pcall(vim.json.decode, raw)
        if ok and type(data) == "table" then M.memory = data end
      end
    end
    for k in pairs(M.memory) do M.order[#M.order + 1] = k end
    local max = opts.cache.max_entries
    while #M.order > max do M.memory[table.remove(M.order, 1)] = nil end
  end
  return M.memory[key]
end
function M.set(key, value)
  local opts = require("gptcopilot.config").get()
  if not opts.cache.enabled then return end
  M.memory[key] = value
  M.order[#M.order + 1] = key
  while #M.order > opts.cache.max_entries do
    local old = table.remove(M.order, 1)
    M.memory[old] = nil
  end
  if opts.cache.persist then
    vim.fn.mkdir(vim.fn.stdpath("cache"), "p")
    local f = io.open(cache_path(), "w")
    if f then f:write(vim.json.encode(M.memory)); f:close(); pcall(vim.fn.setfperm, cache_path(), "rw-------") end
  end
end
function M.clear()
  M.memory, M.order, M.loaded = {}, {}, true
  pcall(os.remove, cache_path())
end
return M
