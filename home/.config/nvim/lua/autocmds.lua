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

-- Go
vim.api.nvim_create_autocmd({"Filetype"}, {
    pattern = { "go" },
    callback = function()
        vim.opt_local.expandtab = false
    end
})

-- Stop writing of some buffer names to file
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    pattern = { "*" },
    callback = function(vars)
        local f = vars["file"]
        if f == "1" or f == "1q" then
            os.execute("rm -f 1 1q")
        end
    end,
})

-- Syntax for gxs
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = { "*.gxs" },
    callback = function()
        vim.opt_local.ft = "gxs"
        vim.opt_local.syntax = "gxs"
    end,
})
