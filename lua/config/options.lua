local opt = vim.opt

opt.number = true
opt.relativenumber = true

opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartindent = true

opt.wrap = false
opt.cursorline = true
opt.signcolumn = "yes"

opt.termguicolors = true
opt.mouse = "a"

opt.clipboard = "unnamedplus"
opt.ignorecase = true
opt.smartcase = true

opt.splitright = true
opt.splitbelow = true

opt.updatetime = 250
opt.timeoutlen = 400

opt.undofile = true
opt.swapfile = false

opt.scrolloff = 8
opt.sidescrolloff = 8

-- Autocompletado en la consola de comandos
opt.wildmenu = true
opt.wildmode = "longest:full,full"

-- Mostrar sugerencias en ventana emergente
opt.wildoptions = "pum"

-- Ignorar mayúsculas/minúsculas
opt.wildignorecase = true

-- Archivos que se omiten al completar rutas
opt.wildignore = {
    "*.o",
    "*.obj",
    "*.pyc",
    "*.class",
    "*.swp",
    "node_modules/**",
    "vendor/**",
    ".git/**"
}
