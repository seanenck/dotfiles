local function shellcheck() 
    vim.api.nvim_command(':exe ":sign unplace * file=" .. expand("%:p")')
    local file = vim.fn.expand('%')
    local pipe = io.popen('shellcheck -f gcc -x "' .. file .. '"')
    local ns_id = vim.api.nvim_create_namespace("shellcheck")
    local bnr = vim.fn.bufnr('%')
    local all = vim.api.nvim_buf_get_extmarks(bnr, ns_id, 0, -1, {})
    for idx, mark in pairs(all) do
        vim.api.nvim_buf_del_extmark(bnr, ns_id, mark[1])
    end
    for res in pipe:lines() do
        local idx = 0
        local line = nil
        local col = nil
        local cat = nil
        local msg = ""
        for token in string.gmatch(res, "([^:]+)") do
            token = token:match("^%s*(.-)%s*$")
            if idx > 0 then
                if idx == 1 then
                    line = token
                elseif idx == 2 then
                    col = token
                elseif idx == 3 then
                    cat = token
                else
                    msg = msg .. ": " .. token
                end
            end
            idx = idx + 1
        end
        if line ~= nil and col ~= nil and cat ~= nil then
            texthl = "Normal"
            if cat == "error" then
                texthl = "Error"
            elseif cat == "warn" then
                texthl = "Search"
            end
            local define = "shellcheck_l" .. line .. "_c" .. col
            vim.api.nvim_command(":sign define " .. define .. " texthl=" .. texthl .. " text=>>")
            vim.api.nvim_command(':exe ":sign place 2 line=' .. line .. ' name=' .. define .. ' file=" .. expand("%:p")')
            if string.len(msg) > 2 then
                msg = string.sub(msg, 3)
                msg = '    •  ' .. msg
                local l = tonumber(line) - 1
                local have = vim.api.nvim_buf_get_extmarks(bnr, ns_id, {l, 0}, {l, 0}, {})
                local count = 0
                for c in pairs(have) do
                    count = count + 1
                end
                if count == 0 then
                    local opts = {
                        virt_text = {{msg, "Comment"}},
                        virt_text_pos = 'eol',
                    }
                    vim.api.nvim_buf_set_extmark(bnr, ns_id, l, 0, opts)
                end
            end
        end
    end
    pipe:close()
end

vim.api.nvim_create_autocmd({ "BufRead", "BufEnter", "BufWritePost" }, {
    pattern = { "*" },
    callback = function()
        if vim.bo.filetype ~= nil and vim.bo.filetype ~= "" and vim.bo.filetype == "sh" then
            shellcheck()
        end
    end,
})
