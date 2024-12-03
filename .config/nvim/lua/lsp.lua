-- nvim-cmp settings
local cmp = require("cmp")

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
require("lspclients")
local capababilities = require('cmp_nvim_lsp').default_capabilities()
for exe, client in pairs(get_clients()) do
    if vim.fn.executable(exe) then
        settings = {}
        settings.name = exe
        settings.capabilities = capabilities 
        client(settings)
    end
end

-- straight from the neovim docs on how to handle formatting
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client.supports_method('textDocument/formatting') then
            vim.api.nvim_create_autocmd('BufWritePre', {
                buffer = args.buf,
                callback = function()
                    vim.lsp.buf.format { async = false }
                end
            })
        end
    end
})

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = true,
        signs = true,
        update_in_insert = false,
        underline = true,
    }
)

vim.keymap.set("n", "<C-e>", function()
        vim.diagnostic.open_float(nil, {
            focus=false,
            scope="buffer",
            format=function(d)
                return string.format("%s (line: %d, col: %d)", d.message, d.lnum, d.col)
            end
        })
    end, { noremap = true, silent = true }
)
