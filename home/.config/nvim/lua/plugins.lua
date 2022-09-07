require("toggleterm").setup{}

-- ALE settings
function override_linters(extension, linters)
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { "*." .. extension },
        callback = function()
            vim.g.ale_linters = linters
        end
    })
end

vim.g.ale_set_highlights = 0
vim.g.ale_sign_column_always = 1
vim.g.ale_completion_enabled = 1
override_linters("py", {["python"] = {"pylsp", "pycodestyle", "flake8", "pydocstyle"}})
override_linters("go", {["go"] = {"gopls", "revive", "govet", "staticcheck"}}) 

-- Airline settings
vim.g.airline_extensions = {"tabline"}
vim.g.airline_extensions["tabline"] = {["formatter"] = "unique_tail_improved"}
