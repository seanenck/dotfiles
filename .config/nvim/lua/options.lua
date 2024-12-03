vim.opt.background = 'dark'
vim.opt.confirm = true
vim.opt.mouse = 'a'
vim.opt.expandtab = true
vim.opt.completeopt = "noinsert"
vim.opt.number = true
vim.opt.shiftwidth = 4
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.softtabstop = 4
vim.opt.tabstop = 4
vim.opt.termguicolors = true
vim.opt.undofile = true
vim.opt.undolevels = 5000
vim.opt.virtualedit = "onemore"
vim.opt.autoindent = false
vim.opt.wrap = false
vim.opt.errorbells = false
vim.opt.visualbell = false
vim.opt.whichwrap = "b,s,<,>,[,],h,l"
vim.opt.foldlevelstart = 99
vim.opt.foldmethod = "indent"
vim.opt.signcolumn = "yes"
vim.opt.clipboard = "unnamedplus"
vim.opt.omnifunc = "syntaxcomplete#Complete"
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0

-- option? no treesitter please
vim.treesitter.start = function()
end
