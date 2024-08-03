if vim.version().major == 0 and vim.version().minor >= 10 then
    vim.cmd 'colorscheme vim'
end

vim.api.nvim_set_hl(0, "Pmenu", {bg='white', fg='black'})
vim.api.nvim_set_hl(0, "Search", {bg='white', fg='black'})
