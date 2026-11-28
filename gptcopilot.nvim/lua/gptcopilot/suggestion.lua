local M = { text = nil, ns = vim.api.nvim_create_namespace("gptcopilot"), buf = nil }
local function render()
  if not M.text or not M.buf or not vim.api.nvim_buf_is_valid(M.buf) then return end
  vim.api.nvim_buf_clear_namespace(M.buf, M.ns, 0, -1)
  local win = vim.fn.bufwinid(M.buf)
  if win == -1 then return end
  local row, col = unpack(vim.api.nvim_win_get_cursor(win)); row = row - 1
  local lines = vim.split(M.text, "\n", { plain = true })
  local virt_lines = {}
  for i = 2, #lines do virt_lines[#virt_lines + 1] = { { lines[i], "Comment" } } end
  vim.api.nvim_buf_set_extmark(M.buf, M.ns, row, col, {
    virt_text = { { lines[1] or "", "Comment" } },
    virt_text_pos = "inline", virt_lines = virt_lines, hl_mode = "combine",
  })
end
function M.show(text)
  M.buf, M.text = vim.api.nvim_get_current_buf(), text
  render()
end
function M.hide()
  if M.buf and vim.api.nvim_buf_is_valid(M.buf) then vim.api.nvim_buf_clear_namespace(M.buf, M.ns, 0, -1) end
  M.text = nil
end
local function take(n)
  if not M.text then return end
  local parts = vim.split(M.text, "\n", { plain = true })
  local first = parts[1] or ""
  local accepted, rest
  if n == "all" then accepted, rest = M.text, ""
  elseif n == "line" then accepted = first .. (#parts > 1 and "\n" or ""); table.remove(parts, 1); rest = table.concat(parts, "\n")
  else
    local word = first:match("^(%s*[%w_]+%W*)") or first:sub(1, 1)
    accepted, rest = word, M.text:sub(#word + 1)
  end
  local win = vim.fn.bufwinid(M.buf)
  if win == -1 then M.hide(); return end
  local row, col = unpack(vim.api.nvim_win_get_cursor(win)); row = row - 1
  local accepted_lines = vim.split(accepted, "\n", { plain = true })
  vim.api.nvim_buf_set_text(M.buf, row, col, row, col, accepted_lines)
  local new_row = row + #accepted_lines - 1
  local new_col = (#accepted_lines == 1) and (col + #accepted_lines[1]) or #accepted_lines[#accepted_lines]
  vim.api.nvim_win_set_cursor(win, { new_row + 1, new_col })
  M.text = rest ~= "" and rest or nil
  if M.text then render() else M.hide() end
end
function M.accept_word() take("word") end
function M.accept_line() take("line") end
function M.accept_all() take("all") end
return M
