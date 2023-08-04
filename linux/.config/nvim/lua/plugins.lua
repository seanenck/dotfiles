-- airline settings
vim.g.airline_extensions = {"tabline"}
vim.g.airline_extensions["tabline"] = {["formatter"] = "unique_tail_improved"}

-- ale
function override_linters(extension, fixers, linters)
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { "*." .. extension },
        callback = function()
            if linters ~= nil then
                vim.g.ale_linters = linters
            end
            if fixers ~= nil then
                vim.g.ale_fixers = fixers
            end
        end
    })
    vim.api.nvim_create_autocmd({ "BufWrite" }, {
        pattern = { "*." .. extension },
        callback = function()
            vim.api.nvim_exec("autocmd User ALEFixPost let g:override_alefix=0", false)
            vim.g.override_alefix = 1
            vim.api.nvim_exec(":ALEFix", false)
            while vim.g.override_alefix == 1 do
                vim.api.nvim_exec("sleep 5m", false)
            end
        end
    })

end

vim.g.ale_set_highlights = 0
vim.g.ale_sign_column_always = 1
vim.g.ale_completion_enabled = 1
override_linters("go", {["go"] = {"gofumpt"}}, {["go"] = {"gopls", "govet", "staticcheck", "revive"}}) 
override_linters("pl", {["perl"] = {"perltidy"}}, {["perl"] = {"perl", "perlcritic"}})
vim.g.ale_go_staticcheck_options = '-checks all'

-- term
require("toggleterm").setup{
    open_mapping = [[<C-Space>]],
    direction = "float",
}
