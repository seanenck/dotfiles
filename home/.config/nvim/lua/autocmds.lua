-- Restore cursor position
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    pattern = { "*" },
    callback = function()
        vim.api.nvim_exec('silent! normal! g`"zv', false)
        vim.api.nvim_exec('silent! normal! ^', false)
    end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.md", "*.txt" },
    callback = function()
        vim.api.nvim_exec("setlocal textwidth=80 spell", false)
    end
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "/tmp/mutt*" },
    callback = function()
        vim.api.nvim_exec("setlocal spell filetype=mail wm=0 textwidth=80 nonumber nolist", false)
    end
})
