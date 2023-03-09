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

local valid_file = function(file) 
    for _, write in ipairs({"1", "1q", "w"}) do
        if file == write or string.upper(write) == file then
            return false
        end
    end
    if file:find("^:") ~= nil then
        return false
    end
    return true
end

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    pattern = { "*" },
    callback = function(e) 
        if e ~= nil then
            if not valid_file(e.file) then
                error(string.format("invalid file name: %s", e.file))
            end
        end
    end,
})
