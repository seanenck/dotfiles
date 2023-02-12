function text()
    vim.opt_local.textwidth = 80
    vim.opt_local.spell = true
end

-- quickfix/fugitive, disable on load
function quickfix()
    local enable = quickfix_window()
    if enable then
        mapall("<C-k>", ":cprev<CR>")
        mapall("<C-j>", ":cnext<CR>")
        mapall("<C-h>", ":vertical resize +1<CR>")
        mapall("<C-l>", ":vertical resize -1<CR>")
    else
        mapall("<C-k>", "")
        mapall("<C-j>", "")
        mapall("<C-h>", "")
        mapall("<C-l>", "")
    end
end
quickfix()

-- Restore cursor position, setup quickfix
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    pattern = { "*" },
    callback = function()
        vim.api.nvim_exec('silent! normal! g`"zv', false)
        quickfix()
    end,
})

-- Text spelling
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.md", "*.txt" },
    callback = text
})

-- Shell
vim.api.nvim_create_autocmd({"Filetype"}, {
    pattern = { "sh" },
    callback = function()
        vim.opt_local.shiftwidth = 2
    end
})
