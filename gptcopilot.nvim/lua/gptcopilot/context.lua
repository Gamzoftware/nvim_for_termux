local M = {}
local function read_file(path, max_bytes)
  local f = io.open(path, "rb"); if not f then return "[unavailable]" end
  local data = f:read(max_bytes + 1) or ""; f:close()
  if #data > max_bytes then data = data:sub(1, max_bytes) .. "\n[truncated]" end
  return data
end
function M.collect(buf)
  local opts = require("gptcopilot.config").get()
  buf = buf or vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local full_text = table.concat(lines, "\n")
  local first, last, current
  if #full_text <= opts.max_file_bytes then
    first, last, current = 1, #lines, full_text
  else
    first = math.max(1, row - math.floor(opts.max_context_lines / 2))
    last = math.min(#lines, first + opts.max_context_lines - 1)
    local selected = {}
    for i = first, last do selected[#selected + 1] = lines[i] end
    current = table.concat(selected, "\n") .. "\n[large file: context excerpt only]"
  end
  local ft = vim.bo[buf].filetype
  local diagnostics = ""
  if opts.context.include_diagnostics and vim.diagnostic then
    local ds = vim.diagnostic.get(buf)
    local out = {}
    for _, d in ipairs(ds) do
      out[#out + 1] = string.format("line %d: %s", d.lnum + 1, d.message)
    end
    if #out > 0 then diagnostics = "\nLSP/diagnostics:\n" .. table.concat(out, "\n") end
  end
  local extras = {}
  for _, path in ipairs(opts.context.extra_files or {}) do
    local absolute = vim.fn.fnamemodify(path, ":p")
    extras[#extras + 1] = "\n--- Additional file: " .. path .. " ---\n" .. read_file(absolute, opts.max_file_bytes)
  end
  return table.concat({
    "File: " .. (name ~= "" and name or "[No Name]"), "Filetype: " .. ft,
    "Cursor: line " .. row .. ", column " .. (vim.api.nvim_win_get_cursor(0)[2] + 1),
    "Current file context (lines " .. first .. "-" .. last .. "):\n" .. current,
    diagnostics, table.concat(extras, "\n"),
  }, "\n")
end
function M.add_file(path)
  local opts = require("gptcopilot.config").get()
  local absolute = vim.fn.fnamemodify(path, ":p")
  for _, p in ipairs(opts.context.extra_files) do
    if vim.fn.fnamemodify(p, ":p") == absolute then return false end
  end
  table.insert(opts.context.extra_files, absolute); return true
end
function M.clear_files()
  require("gptcopilot.config").get().context.extra_files = {}
end
return M
