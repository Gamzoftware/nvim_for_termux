local M = {}
function M.build(provider, model, prompt, context, max_tokens)
  local key = assert(os.getenv(provider.api_key_env), "Missing " .. provider.api_key_env)
  local url = provider.base_url:gsub("/$", "") .. "/models/" .. model .. ":generateContent"
  return url, { ["x-goog-api-key"] = key, ["Content-Type"] = "application/json" }, {
    contents = { { role = "user", parts = { { text = "You are a precise programming assistant. Return only code to insert; avoid Markdown fences unless requested.\n\nTASK / PROMPT:\n" .. prompt .. "\n\nPROJECT CONTEXT:\n" .. context } } } },
    generationConfig = { maxOutputTokens = max_tokens, temperature = 0.2 },
  }
end
function M.extract(data)
  local c = data.candidates and data.candidates[1]
  local parts = c and c.content and c.content.parts or {}
  local out = {}; for _, p in ipairs(parts) do if p.text then out[#out + 1] = p.text end end
  return table.concat(out, "")
end
return M
