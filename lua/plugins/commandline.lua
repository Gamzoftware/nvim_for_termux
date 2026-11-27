return {
    {
        "folke/noice.nvim",
        event = "VeryLazy",

        dependencies = {
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
        },

        config = function()
            require("noice").setup({
                cmdline = {
                    enabled = true,
                    view = "cmdline_popup",
                },

                popupmenu = {
                    enabled = true,
                    backend = "nui",
                },

                messages = {
                    enabled = true,
                },
            })
        end
    }
}
