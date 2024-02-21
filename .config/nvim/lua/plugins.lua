-- airline settings
vim.g.airline_extensions = {"tabline"}
vim.g.airline_extensions["tabline"] = {["formatter"] = "unique_tail_improved"}

-- nvim-cmp settings
local cmp = require'cmp'

cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ['<Right>'] = cmp.mapping.confirm({ select = false }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
    }, {
        { name = 'buffer' },
    })
})

-- lsp
util = require 'lspconfig.util'
lspconfig = require "lspconfig"
local on_attach = function(client, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.hover, opts)
end

capabilities = require('cmp_nvim_lsp').default_capabilities()
lspconfig.denols.setup{
    on_attach = on_attach,
    capabilities = capabilities,
}
lspconfig.efm.setup{
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        rootMarkers = {".git/"},
        languages = {
            sh = {
                {
                    lintCommand = "shellcheck -f gcc -x",
                    lintSource = "shellcheck",
                    lintFormats = {
                        '%f:%l:%c: %trror: %m',
                        '%f:%l:%c: %tarning: %m',
                        '%f:%l:%c: %tote: %m',
                    }
                }
            }
        }
    }
}
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = "*",
    callback = function()
        vim.lsp.buf.format { async = false }
    end
})
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics,
    {
        virtual_text = true,
        signs = true,
        update_in_insert = false,
        underline = true,
    }
)

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

-- term
require("toggleterm").setup{
    open_mapping = [[<C-t>]],
}

function _G.set_terminal_keymaps()
  local opts = {buffer = 0}
  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
end

vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
mapall("<C-j>", ":wincmd j<CR>")

-- scrollbar
require("scrollbar").setup({})
