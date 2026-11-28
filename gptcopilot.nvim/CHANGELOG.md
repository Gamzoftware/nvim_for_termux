# Changelog

## 3.0.0

- Provider architecture separated from the Neovim plugin core.
- Native REST adapters for OpenAI Chat Completions, Gemini `generateContent`, and DeepSeek Chat Completions.
- User-defined OpenAI-compatible providers.
- 3000 ms debounce reset by text and cursor events.
- Prompt extraction from line and block comments above the cursor.
- Inline suggestions with accept-word, accept-line, accept-all, and hide keymaps.
- Current-buffer context, LSP diagnostics, and explicitly attached additional files.
- Persistent bounded cache keyed by provider, model, prompt, and full context.
- Termux-oriented dependency set: Neovim + curl only.
