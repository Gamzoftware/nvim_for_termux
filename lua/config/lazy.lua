local lazypath =
    vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
    local repo =
        "https://github.com/folke/lazy.nvim.git"

    local out = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        repo,
        lazypath
    })

    if vim.v.shell_error ~= 0 then
        error("No se pudo instalar lazy.nvim: " .. out)
    end
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = {
        { import = "plugins" }
    },

    checker = {
        enabled = true
    },

    change_detection = {
        notify = false
    }
})
