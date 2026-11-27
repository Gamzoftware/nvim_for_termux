return {

    {
        "nvim-lua/plenary.nvim",
        lazy = true,
    },

    {
        "nvim-telescope/telescope.nvim",

        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
        },

        config = function()

            local telescope = require("telescope")

            telescope.setup({})

            local builtin = require("telescope.builtin")

            vim.keymap.set("n", "<leader>ff",
                builtin.find_files)

            vim.keymap.set("n", "<leader>fg",
                builtin.live_grep)

            vim.keymap.set("n", "<leader>fb",
                builtin.buffers)

            vim.keymap.set("n", "<leader>fh",
                builtin.help_tags)

        end
    },

    {
        "nvim-neo-tree/neo-tree.nvim",

        branch = "v3.x",

        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
        },

        config = function()

            require("neo-tree").setup({})

            vim.keymap.set(
                "n",
                "<leader>nt",
                "<cmd>Neotree toggle<CR>"
            )

        end
    },

    {
        "nvim-lualine/lualine.nvim",

        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },

        config = function()
            require("lualine").setup({})
        end
    },

    {
        "lewis6991/gitsigns.nvim",

        config = function()
            require("gitsigns").setup({})
        end
    },

}
