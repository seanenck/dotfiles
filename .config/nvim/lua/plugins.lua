-- ALE settings
function override_linters(extension, fixer, linters)
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { "*." .. extension },
        callback = function()
            vim.g.ale_linters = linters
            vim.g.ale_fixers = {[extension] = {fixer}}
        end
    })
    vim.api.nvim_create_autocmd({ "BufWrite" }, {
        pattern = { "*." .. extension },
        callback = function()
            vim.api.nvim_exec(":ALEFix", false)
            vim.api.nvim_exec("sleep 50m", false)
        end
    })
end

vim.g.ale_set_highlights = 0
vim.g.ale_sign_column_always = 1
vim.g.ale_completion_enabled = 1
override_linters("go", "gofumpt", {["go"] = {"gopls", "govet", "staticcheck"}}) 

-- Airline settings
vim.g.airline_extensions = {"tabline"}
vim.g.airline_extensions["tabline"] = {["formatter"] = "unique_tail_improved"}
