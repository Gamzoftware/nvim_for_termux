return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local builtin = require('telescope.builtin')
    vim.keymap.set('n', 'ff', builtin.find_files, { desc = 'Find Files' })
    vim.keymap.set('n', 'fg', builtin.live_grep, { desc = 'Live Grep' })
  end
}
