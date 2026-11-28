local M = {}
function M.build(provider, model, prompt, context, max_tokens)
  return provider.base_url:gsub("/$", "") .. "/chat/completions",
    { ["Authorization"] = "Bearer " .. assert(os.getenv(provider.api_key_env), "Missing " .. provider.api_key_env), ["Content-Type"] = "application/json" },
    { model = model, stream = false, max_tokens = max_tokens, messages = {
      { role = "system", content = "You are a precise programming assistant. Return only the code to insert. Do not use Markdown fences unless they are part of the requested code." },
      { role = "user", content = "TASK / PROMPT:\n" .. prompt .. "\n\nPROJECT CONTEXT:\n" .. context },
    } }
end
function M.extract(data)
  return data.choices and data.choices[1] and data.choices[1].message and data.choices[1].message.content
end
return M
