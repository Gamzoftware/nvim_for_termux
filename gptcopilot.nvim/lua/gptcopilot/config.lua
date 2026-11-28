local M = {}

M.defaults = {
  provider = "openai",
  model = "gpt-6.2-astra",
  request_timeout = 90,
  max_context_lines = 160,
  max_file_bytes = 120000,
  filetypes = { ["*"] = true, help = false, markdown = false },
  context = { include_diagnostics = true, extra_files = {} },
  completion = {
    enabled = true,
    auto_trigger = true,
    debounce_ms = 3000,
    comment_prompts = true,
    max_output_tokens = 500,
  },
  keymap = {
    accept_word = "<C-Right>",
    accept_line = "<C-End>",
    accept_all = "<C-Down>",
    hide = "<C-Space>",
  },
  cache = { enabled = true, max_entries = 100, persist = true },
  logging = {
    enabled = true,
    level = "INFO", -- DEBUG, INFO, WARN, ERROR
    file = nil, -- Ruta predeterminada: stdpath("state")/gptcopilot.log
    max_size_kb = 1024, -- Rotación al alcanzar 1 MB
  },
  providers = {
    openai = {
      protocol = "openai", base_url = "https://api.openai.com/v1",
      api_key_env = "OPENAI_API_KEY", model = "gpt-6.2-astra",
    },
    gemini = {
      protocol = "gemini", base_url = "https://generativelanguage.googleapis.com/v1beta",
      api_key_env = "GEMINI_API_KEY", model = "gemini-2.5-flash",
    },
    deepseek = {
      protocol = "openai", base_url = "https://api.deepseek.com",
      api_key_env = "DEEPSEEK_API_KEY", model = "deepseek-v4-pro",
    },
  },
}

function M.setup(user)
  user = user or {}
  M.options = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), user)
  if user.model == nil and M.options.providers[M.options.provider] then
    M.options.model = M.options.providers[M.options.provider].model
  end
  return M.options
end

function M.get()
  if not M.options then return M.setup({}) end
  return M.options
end

return M
