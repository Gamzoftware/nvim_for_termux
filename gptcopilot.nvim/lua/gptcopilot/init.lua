local M = {}
local timer_id = 0
local logger = require("gptcopilot.logger")
local function notify(msg, level) vim.notify("gptcopilot: " .. msg, level or vim.log.levels.INFO) end
local function request(prompt)
  logger.info("request requested; prompt_chars=" .. #prompt)
  local buf = vim.api.nvim_get_current_buf()
  local position = vim.api.nvim_win_get_cursor(0)
  local context = require("gptcopilot.context").collect(buf)
  logger.debug("request context collected; bytes=" .. #context)
  require("gptcopilot.client").request(prompt, context, function(err, result, cached)
    if err then
      logger.error("request failed; details omitted from log for privacy")
      notify(err, vim.log.levels.ERROR)
      return
    end
    -- Never paint a late response over a buffer/cursor position that has changed.
    if vim.api.nvim_get_current_buf() ~= buf then
      logger.debug("response ignored: current buffer changed")
      return
    end
    local now = vim.api.nvim_win_get_cursor(0)
    if now[1] ~= position[1] or now[2] ~= position[2] then
      logger.debug("response ignored: cursor moved")
      return
    end
    require("gptcopilot.suggestion").show(result)
    logger.info(
      "suggestion displayed; result_chars=" .. #result ..
      (cached and "; source=cache" or "; source=api")
    )
    if cached then notify("suggestion from cache") end
  end)
end
local function schedule()
  timer_id = timer_id + 1
  local current = timer_id
  local opts = require("gptcopilot.config").get()
  vim.defer_fn(function()
    if current ~= timer_id then return end
    local buf = vim.api.nvim_get_current_buf()
    local allowed = opts.filetypes[vim.bo[buf].filetype]
    if allowed == nil then allowed = opts.filetypes["*"] end
    if not allowed then return end
    local prompt = opts.completion.comment_prompts and require("gptcopilot.prompt").from_above(buf) or nil
    if prompt then request(prompt)
    elseif opts.completion.auto_trigger then
      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      local line = vim.api.nvim_get_current_line()
      request("Continue the code naturally at the cursor. Return only the code to insert.\nLine: " .. line .. "\nCursor column: " .. (col + 1) .. "\nLine number: " .. row)
    end
  end, opts.completion.debounce_ms)
end
function M.setup(user)
  local opts = require("gptcopilot.config").setup(user)
  local group = vim.api.nvim_create_augroup("GPTCopilot", { clear = true })
  vim.api.nvim_create_autocmd({ "TextChangedI", "TextChanged", "CursorMovedI", "CursorMoved" }, {
    group = group, callback = function() if opts.completion.enabled then schedule() end end,
  })
  vim.api.nvim_create_autocmd("InsertLeave", { group = group, callback = function() timer_id = timer_id + 1 end })
  local function map(lhs, rhs, desc)
    if lhs and lhs ~= "" then vim.keymap.set("i", lhs, rhs, { silent = true, desc = desc }) end
  end
  local sug = require("gptcopilot.suggestion")
  map(opts.keymap.accept_word, sug.accept_word, "Accept AI suggestion word")
  map(opts.keymap.accept_line, sug.accept_line, "Accept AI suggestion line")
  map(opts.keymap.accept_all, sug.accept_all, "Accept all AI suggestion")
  map(opts.keymap.hide, sug.hide, "Hide AI suggestion")
  vim.api.nvim_create_user_command("GPTCopilot", function() request("Generate code for the current cursor position. Return only code.") end, {})
  vim.api.nvim_create_user_command("GPTCopilotAsk", function(a) request(a.args) end, { nargs = "+" })
  vim.api.nvim_create_user_command("GPTCopilotProvider", function(a)
    if not opts.providers[a.args] then notify("unknown provider: " .. a.args, vim.log.levels.ERROR); return end
    opts.provider, opts.model = a.args, opts.providers[a.args].model
    notify("provider=" .. opts.provider .. ", model=" .. opts.model)
  end, { nargs = 1, complete = function() return vim.tbl_keys(opts.providers) end })
  vim.api.nvim_create_user_command("GPTCopilotModel", function(a)
    if a.args == "" then notify("provider=" .. opts.provider .. ", model=" .. opts.model)
    else opts.model = a.args; notify("model=" .. opts.model) end
  end, { nargs = "?" })
  vim.api.nvim_create_user_command("GPTCopilotAddProvider", function(a)
    local ok, data = pcall(vim.json.decode, a.args)
    if not ok or type(data) ~= "table" or not data.name or not data.base_url or not data.api_key_env or not data.model then
      notify('usage: :GPTCopilotAddProvider {"name":"local","protocol":"openai","base_url":"https://.../v1","api_key_env":"MY_KEY","model":"model-id"}', vim.log.levels.ERROR); return
    end
    opts.providers[data.name] = { protocol = data.protocol or "openai", base_url = data.base_url, api_key_env = data.api_key_env, model = data.model }
    notify("provider added: " .. data.name)
  end, { nargs = "+" })
  vim.api.nvim_create_user_command("GPTCopilotAddFile", function(a)
    if require("gptcopilot.context").add_file(a.args) then notify("context file added") else notify("file already included") end
  end, { nargs = 1, complete = "file" })
  vim.api.nvim_create_user_command("GPTCopilotClearFiles", function() require("gptcopilot.context").clear_files(); notify("additional files cleared") end, {})
  vim.api.nvim_create_user_command("GPTCopilotHide", sug.hide, {})
  vim.api.nvim_create_user_command("GPTCopilotClearCache", function() require("gptcopilot.cache").clear(); notify("cache cleared") end, {})
  vim.api.nvim_create_user_command("GPTCopilotCmpRegister", function()
    local ok, cmp = pcall(require, "cmp")
    if not ok then notify("nvim-cmp is not installed", vim.log.levels.ERROR); return end
    cmp.register_source("gptcopilot", require("gptcopilot.sources.nvim-cmp").new()); notify("nvim-cmp source registered")
  end, {})
  logger.info(
    "plugin initialized; provider=" .. opts.provider ..
    "; model=" .. opts.model
  )
  return opts
end
return M
