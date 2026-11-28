return {
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",

        config = function()
            require("copilot").setup({
                copilot_node_command = vim.fn.exepath("node"),

                server = {
                    type = "nodejs",
                },

                suggestion = {
                    enabled = true,
                    auto_trigger = true,
                    keymap = {
                        accept_word = "<C-Right>",
                        accept_line = "<C-End>",
                        accept_all = "<C-Enter>",
                    },
                },

                panel = {
                    enabled = true,
                },
            })
        end,
    },

    {
        "zbirenbaum/copilot-cmp",
        dependencies = {
            "zbirenbaum/copilot.lua",
            "hrsh7th/nvim-cmp",
        },
        config = function()
            require("copilot_cmp").setup()
        end,
    },
}

