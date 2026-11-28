
return {
    dir = vim.env.HOME .. "/.config/nvim/gptcopilot.nvim",
    name = "gptcopilot.nvim",

    lazy = false,

    config = function()
        require("gptcopilot").setup({

            -- Proveedor predeterminado
            provider = "gemini",

            -- Modelo predeterminado
            model = "gemini-3.6-flash",

            logging = {
                enabled = true,
                level = "DEBUG",
                file = vim.fn.expand(
                    "~/.local/state/nvim/gptcopilot.log"
                ),
                max_size_kb = 1024,
            },

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

            context = {
                include_diagnostics = true,
                extra_files = {},
            },

            cache = {
                enabled = true,
                max_entries = 100,
                persist = true,
            },
        })
    end,
}

