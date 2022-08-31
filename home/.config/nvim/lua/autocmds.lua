-- Restore cursor position
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    pattern = { "*" },
    callback = function()
        vim.api.nvim_exec('silent! normal! g`"zv', false)
        vim.api.nvim_exec('silent! normal! ^', false)
    end,
})

-- Text spelling
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.md", "*.txt" },
    callback = function()
        vim.opt_local.textwidth = 80
        vim.opt_local.spell = true
    end
})

-- Emails
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "/tmp/mutt*" },
    callback = function()
        vim.opt_local.textwidth = 80
        vim.opt_local.spell = true
        vim.opt_local.list = false
        vim.opt_local.filetype = "mail"
        vim.opt_local.wrapmargin = 0
    end
})
