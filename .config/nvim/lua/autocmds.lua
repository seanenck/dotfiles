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

-- Handle unknown filetypes
vim.api.nvim_create_autocmd({ "BufEnter" }, {
    pattern = { "*" },
    callback = function()
        if vim.fn.did_filetype() and vim.bo.filetype == "conf" then
            local fstline = vim.api.nvim_buf_get_lines(0, 0, 1, true)[1]
            if fstline then
                shebang =  fstline:match("#!%s*/usr/bin/env%s+(%S+)")
                        or fstline:match("#!%s*/%S+/([^ /]+)")
                if shebang == "pwsh" then
                    vim.bo.filetype = "ps1"
                end
            end
        end
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

local bad_prefix = function()
    local invalids = {">", "<", "^:"}
    for _, prefix in ipairs({"w", "wq"}) do
        for _, write in ipairs({"1", ":", " "}) do
            table.insert(invalids, string.format("^%s%s", prefix, write))
        end
        for i=0,9,1 do
            table.insert(invalids, string.format("^%s%d", prefix, i))
        end
    end
    return invalids
end
local invalid_commands = bad_prefix()

vim.api.nvim_create_autocmd({ "CmdlineChanged" }, {
    pattern = { "*" },
    callback = function(e)
        local cmd = vim.fn.getcmdline()
        if cmd ~= nil then
            for _, invalid in ipairs(invalid_commands) do
                if cmd:find(invalid) ~= nil then
                    vim.fn.setcmdline("")
                end
            end
        end
    end,
})
