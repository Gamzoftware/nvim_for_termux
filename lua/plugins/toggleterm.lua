return {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
        require("toggleterm").setup({
            direction = "horizontal",
            size = 10,
        })

        vim.keymap.set(
            "n",
            "<leader>tt",
            "<cmd>ToggleTerm<CR>"
        )
    end
}
