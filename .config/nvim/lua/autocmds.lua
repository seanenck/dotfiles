function text()
    vim.opt_local.textwidth = 80
    vim.opt_local.spell = true
end

-- Restore cursor position, setup quickfix
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

-- Shell
vim.api.nvim_create_autocmd({"Filetype"}, {
    pattern = { "sh" },
    callback = function()
        vim.opt_local.shiftwidth = 2
    end
})

vim.api.nvim_create_autocmd({ "CmdlineChanged" }, {
    pattern = { "*" },
    callback = function(e)
        local cmd = vim.fn.getcmdline()
        if cmd ~= nil then
            local invalids = {">", "<", "^:"}
            for _, write in ipairs({"1", ":", " "}) do
                table.insert(invalids, string.format("^w%s", write))
            end
            for i=0,9,1 do
                table.insert(invalids, string.format("^w%d", i))
            end
            for _, invalid in ipairs(invalids) do
                if cmd:find(invalid) ~= nil then
                    vim.fn.setcmdline("")
                end
            end
        end
    end,
})
