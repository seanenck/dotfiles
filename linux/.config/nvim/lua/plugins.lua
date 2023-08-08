-- airline settings
vim.g.airline_extensions = {"tabline"}
vim.g.airline_extensions["tabline"] = {["formatter"] = "unique_tail_improved"}

-- nvim-cmp settings
local cmp = require'cmp'

cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<Right>'] = cmp.mapping.confirm({ select = false }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    }, {
        { name = 'buffer' },
    })
})

-- lsp
util = require 'lspconfig.util'
lspconfig = require "lspconfig"
local on_attach = function(client, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
end

local no_exec = function(name)
    return vim.fn.executable(name) ~= 1
end

local function setuplsp(exe, format_types)
    if no_exec(exe) then
        return
    end
    capabilities = require('cmp_nvim_lsp').default_capabilities()
    if exe == "gopls" then
        lspconfig.gopls.setup{
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
                gopls = {
                    gofumpt = true,
                    staticcheck = true
                }
            },
        }
    elseif exe == "rust-analyzer" then
        lspconfig.rust_analyzer.setup{
            on_attach = on_attach,
            capabilities = capabilities,
        }
    else
        error("unknown lsp requested")
    end
    if format_types ~= nil then
        vim.api.nvim_create_autocmd({ "BufWritePre" }, {
            pattern = { "*." .. format_types },
            callback = function()
                vim.lsp.buf.format { async = false }
            end
        })
    end
    vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
        vim.lsp.diagnostic.on_publish_diagnostics,
        {
            virtual_text = true,
            signs = true,
            update_in_insert = false,
            underline = true,
        }
    )
end

setuplsp("rust-analyzer", "rs")
setuplsp("gopls", "go")
function toggle_diagnostics()
    vim.diagnostic.open_float(nil, {
        focus=false,
        scope="buffer",
        format=function(d)
            return string.format("%s (line: %d, col: %d)", d.message, d.lnum, d.col)
        end
    })
end
vim.api.nvim_set_keymap("n", "<C-e>", ':call v:lua.toggle_diagnostics()<CR>', { noremap = true, silent = true })

-- ale
function ale_handlers(ft, has_fixers)
    vim.api.nvim_create_autocmd({ "BufRead", "BufEnter" }, {
        pattern = { "*" },
        callback = function()
            if vim.bo.filetype ~= ft then
                return
            end
            vim.b.ale_enabled = 1
        end
    })
    if has_fixers then
        vim.api.nvim_create_autocmd({ "BufWrite" }, {
            pattern = { "*" },
            callback = function()
                if vim.bo.filetype ~= ft then
                    return
                end
                vim.api.nvim_exec("autocmd User ALEFixPost let g:override_alefix=0", false)
                vim.g.override_alefix = 1
                vim.api.nvim_exec(":ALEFix", false)
                while vim.g.override_alefix == 1 do
                    vim.api.nvim_exec("sleep 5m", false)
                end
            end
        })
    end
end

vim.g.ale_enabled = 0
vim.g.ale_set_highlights = 0
vim.g.ale_sign_column_always = 1
vim.g.ale_completion_enabled = 1
vim.g.ale_linters = {
    ["perl"] = {"perl", "perlcritic"},
    ["sh"] = {"shellcheck"},
}
vim.g.ale_fixers = {
    ["perl"] = {"perltidy"},
}
ale_handlers("perl", true)
ale_handlers("sh", false)

-- term
require("toggleterm").setup{
    open_mapping = [[<C-Space>]],
    direction = "float",
}

