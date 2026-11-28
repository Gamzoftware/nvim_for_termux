local M = {}
local function starts_with(s, prefix)
  return prefix ~= "" and s:sub(1, #prefix) == prefix
end
local function ends_with(s, suffix)
  return suffix ~= "" and s:sub(-#suffix) == suffix
end
local function strip_comment(line, buf)
  local trimmed = vim.trim(line)
  local cs = vim.bo[buf].commentstring or ""
  local before, after = cs:match("^(.-)%%s(.-)$")
  if before and before ~= "" and starts_with(trimmed, before) then
    trimmed = vim.trim(trimmed:sub(#before + 1))
    if after and after ~= "" and ends_with(trimmed, after) then
      trimmed = vim.trim(trimmed:sub(1, #trimmed - #after))
    end
    return true, trimmed
  end
  local patterns = {
    { "^//+", "^%s*//+%s?" }, { "^#+", "^%s*#+%s?" },
    { "^%-%-+", "^%s*%-%-%-?%s?" }, { "^;", "^%s*;%s?" },
    { "^%%", "^%s*%%%s?" }, { "^/%*", "^%s*/%*+%s?" },
    { "^%*", "^%s*%*%s?" }, { "^%*/", "^%s*%*/%s?" },
    { "^<!%-%-%", "^%s*<!%-%-%s?" }, { "^%-%-%[", "^%s*%-%-%[%[?%s?" },
  }
  for _, p in ipairs(patterns) do
    if trimmed:match(p[1]) then
      trimmed = line:gsub(p[2], "")
      trimmed = trimmed:gsub("%s*%*/%s*$", ""):gsub("%s*-->%s*$", ""):gsub("%s*%]%]%s*$", "")
      return true, vim.trim(trimmed)
    end
  end
  return false, line
end
function M.from_above(buf, row)
  buf = buf or vim.api.nvim_get_current_buf()
  row = row or vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_get_lines(buf, 0, row - 1, false)
  local collected, started = {}, false
  for i = #lines, 1, -1 do
    local line = lines[i]
    local trimmed = vim.trim(line)
    local is_comment, content = strip_comment(line, buf)
    if is_comment then
      started = true
      table.insert(collected, 1, content)
    elseif trimmed == "" then
      if started then table.insert(collected, 1, "") end
    elseif started then
      break
    else
      break
    end
  end
  local prompt = vim.trim(table.concat(collected, "\n"))
  if prompt == "" then return nil end
  return prompt
end
return M
