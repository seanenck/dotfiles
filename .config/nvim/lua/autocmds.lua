function text()
    vim.opt_local.textwidth = 80
    vim.opt_local.spell = true
end

-- quickfix/fugitive, disable on load
function quickfix(enable)
    if enable then
        mapall("<C-k>", ":cprev<CR>")
        mapall("<C-j>", ":cnext<CR>")
        mapall("<C-q>", ":close<CR>")
    else
        mapall("<C-k>", "")
        mapall("<C-j>", "")
        mapall("<C-q>", ":Gclog<CR>")
    end
end
quickfix(false)

-- Restore cursor position, setup quickfix
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    pattern = { "*" },
    callback = function()
        vim.api.nvim_exec('silent! normal! g`"zv', false)
        local exists = false
        for _, win in pairs(vim.fn.getwininfo()) do
            if win["quickfix"] == 1 then
                exists = true
            end
        end
        quickfix(exists)
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
