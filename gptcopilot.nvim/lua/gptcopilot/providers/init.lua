local M = {}
function M.resolve(provider)
  if provider.protocol == "gemini" then return require("gptcopilot.providers.gemini") end
  return require("gptcopilot.providers.openai") -- OpenAI, DeepSeek and OpenAI-compatible custom APIs
end
return M
