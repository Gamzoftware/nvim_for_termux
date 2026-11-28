local source = {}
source.__index = source
function source.new() return setmetatable({}, source) end
function source:is_available() return require("gptcopilot.config").get().completion.enabled end
function source:get_debug_name() return "gptcopilot" end
function source:get_trigger_characters() return { ".", "(" } end
function source:complete(params, callback)
  local buf = params.context.bufnr
  local context = require("gptcopilot.context").collect(buf)
  local line = vim.api.nvim_buf_get_lines(buf, params.context.cursor.row - 1, params.context.cursor.row, false)[1] or ""
  require("gptcopilot.client").request("Complete the code at the cursor. Return only the continuation.\n" .. line, context, function(err, text)
    if err then callback({ items = {}, isIncomplete = false }); return end
    callback({ items = { { label = text, insertText = text, kind = require("cmp").lsp.CompletionItemKind.Text } }, isIncomplete = false })
  end)
end
return source
