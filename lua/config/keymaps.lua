vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set

-- Guardar
map("n", "<leader>w", "<cmd>w<CR>")
map("n", "<leader>q", "<cmd>q<CR>")

-- Navegación entre ventanas
map("n", "<C-h>", "<C-w>h")
map("n", "<C-l>", "<C-w>l")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")

-- Diagnósticos
map("n", "<leader>e", vim.diagnostic.open_float)
map("n", "[d", vim.diagnostic.goto_prev)
map("n", "]d", vim.diagnostic.goto_next)
map("n", "<leader>xx", vim.diagnostic.setloclist)

-- LSP
map("n", "gd", vim.lsp.buf.definition)
map("n", "gr", vim.lsp.buf.references)
map("n", "K", vim.lsp.buf.hover)
map("n", "<leader>rn", vim.lsp.buf.rename)
map("n", "<leader>ca", vim.lsp.buf.code_action)
map("n", "<leader>f", function()
    vim.lsp.buf.format({ async = true })
end)
