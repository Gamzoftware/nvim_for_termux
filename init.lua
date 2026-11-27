require("config.options")
require("config.keymaps")
require("config.lazy")

vim.g.clipboard = {
    name = "Termux",
    copy = {
        ["+"] = "termux-clipboard-set",
        ["*"] = "termux-clipboard-set",
    },
    paste = {
        ["+"] = "termux-clipboard-get",
        ["*"] = "termux-clipboard-get",
    },
    cache_enabled = 0,
}

