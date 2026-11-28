#!/data/data/com.termux/files/usr/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
need() { grep -R -q -- "$1" "$ROOT" || { echo "FAIL: missing $1"; exit 1; }; }
need 'https://api.openai.com/v1'
need 'https://generativelanguage.googleapis.com/v1beta'
need 'https://api.deepseek.com'
need 'debounce_ms = 3000'
need 'accept_word = "<C-Right>"'
need 'accept_line = "<C-End>"'
need 'accept_all = "<C-Down>"'
need 'hide = "<C-Space>"'
need 'GPTCopilotAddFile'
need 'cache.key'
need 'comment_prompts'
need 'nvim-cmp'
echo 'PASS: required feature markers found (static check only).'
