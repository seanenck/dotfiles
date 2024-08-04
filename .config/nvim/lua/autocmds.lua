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
    end,
})

-- Directory
vim.api.nvim_create_autocmd({ "BufEnter" }, {
    pattern = "*",
    callback = function(args)
        local b = vim.fn.expand("%s")
        if vim.fn.isdirectory(b) == 1 then
            vim.api.nvim_buf_set_option(args.buf, "readonly", true)
        end
    end
})

-- Shell
vim.api.nvim_create_autocmd({"Filetype"}, {
    pattern = { "sh" },
    callback = function()
        vim.opt_local.shiftwidth = 2
    end
})

-- prevent 'wq[.]' from writing files with another name"
vim.api.nvim_create_autocmd({ "CmdlineChanged" }, {
    pattern = { "*" },
    callback = function(e)
        local cmd = vim.fn.getcmdline()
        if cmd ~= nil then
            if cmd:match("^wq.") then
                vim.fn.setcmdline("")
            end
        end
    end,
})
