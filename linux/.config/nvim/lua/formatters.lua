function formatter(formatter, format_types)
    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        pattern = { "*" },
        callback = function()
            for _, ft in ipairs(format_types) do
                if vim.bo.filetype ~= nil and vim.bo.filetype ~= "" and vim.bo.filetype == ft then
                    local file = vim.fn.expand('%')
                    os.execute(formatter .. ' "' .. file .. '"')
                    vim.api.nvim_command(':checktime')
                    return
                end
            end
        end
    })
end

formatter("yapf -i", {"python"})
formatter("gofumpt -w -extra", {"go"})
