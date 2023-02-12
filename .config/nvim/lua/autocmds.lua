function text()
    vim.opt_local.textwidth = 80
    vim.opt_local.spell = true
end

-- quickfix/fugitive, disable on load
function quickfix(enable)
    if enable then
        mapall("<C-k>", ":cprev<CR>")
        mapall("<C-j>", ":cnext<CR>")
        mapall("<C-q>", ":cclose<CR>")
        mapall("<C-h>", ":vertical resize +1<CR>")
        mapall("<C-l>", ":vertical resize -1<CR>")
    else
        mapall("<C-k>", "")
        mapall("<C-j>", "")
        mapall("<C-h>", "")
        mapall("<C-l>", "")
        local width = vim.api.nvim_win_get_width(0) * (3/4)
        mapall("<C-q>", string.format(":vertical Gclog<CR>:vertical resize %s<CR>", width))
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
