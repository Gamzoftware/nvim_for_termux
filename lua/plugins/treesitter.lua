return {
    {
        "nvim-treesitter/nvim-treesitter",

        branch = "main",
        lazy = false,
        build = ":TSUpdate",

        dependencies = {
            "neovim-treesitter/treesitter-parser-registry",
        },

        config = function()

            require("nvim-treesitter").setup({
                install_dir =
                    vim.fn.stdpath("data") .. "/site",
            })

            vim.api.nvim_create_autocmd("FileType", {
                pattern = {
                    "php",
                    "javascript",
                    "javascriptreact",
                    "typescript",
                    "typescriptreact",
                    "sql",
                    "bash",
                    "sh",
                    "dart",
                    "lua",
                    "html",
                    "css",
                    "json",
                },

                callback = function()
                    vim.treesitter.start()
                end,
            })

        end,
    },
}
