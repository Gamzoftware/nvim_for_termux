return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },

        config = function()

            require("mason").setup()

            require("mason-lspconfig").setup({
                ensure_installed = {
                    "intelephense",
                    "ts_ls",
                    "sqls",
                    "bashls",
                    "dartls",
                },

                automatic_enable = false,
            })

            local capabilities =
                require("cmp_nvim_lsp").default_capabilities()

            vim.lsp.config("*", {
                capabilities = capabilities,
            })

            -- PHP
            vim.lsp.enable("intelephense")

            -- JavaScript / TypeScript
            vim.lsp.enable("ts_ls")

            -- SQL
            vim.lsp.enable("sqls")

            -- Bash
            vim.lsp.enable("bashls")

            -- Dart / Flutter
            vim.lsp.enable("dartls")

        end
    }
}
