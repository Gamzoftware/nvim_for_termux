return {
    {
        "stevearc/conform.nvim",

        config = function()

            require("conform").setup({

                formatters_by_ft = {

                    php = { "php_cs_fixer" },

                    javascript = { "prettier" },
                    javascriptreact = { "prettier" },

                    typescript = { "prettier" },
                    typescriptreact = { "prettier" },

                    json = { "prettier" },
                    html = { "prettier" },
                    css = { "prettier" },

                    sql = { "sql_formatter" },

                    sh = { "shfmt" },
                    bash = { "shfmt" },

                    dart = { "dart_format" },

                },

                format_on_save = {
                    timeout_ms = 3000,
                    lsp_format = "fallback",
                },

            })

        end
    }
}
