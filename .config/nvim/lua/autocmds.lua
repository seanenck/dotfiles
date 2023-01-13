function text()
    vim.opt_local.textwidth = 80
    vim.opt_local.spell = true
end

-- Restore cursor position
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    pattern = { "*" },
    callback = function()
        vim.api.nvim_exec('silent! normal! g`"zv', false)
    end,
})

-- Text spelling
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.md", "*.txt" },
    callback = text
})

-- Go
vim.api.nvim_create_autocmd({"Filetype"}, {
    pattern = { "go" },
    callback = function()
        vim.opt_local.expandtab = false
    end
})

-- Syntax for gxs
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = { "*.gxs" },
    callback = function()
        vim.opt_local.ft = "gxs"
        vim.opt_local.syntax = "gxs"
    end,
})
