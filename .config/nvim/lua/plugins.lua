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
local function lsp_exists(name)
    if os.getenv("ENABLE_LSP") == nil then
        return false
    end
    for p in string.gmatch(os.getenv("PATH"), "([^:]+)") do
        local exe = string.format("test -x %s/%s", p, name)
        code, _, _ = os.execute(exe)
        if code == 0 or code == true then
            return true
        end
    end
    return false
end

util = require 'lspconfig.util'
lspconfig = require "lspconfig"
local on_attach = function(client, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.hover, opts)
end

capabilities = require('cmp_nvim_lsp').default_capabilities()

if lsp_exists("efm-langserver") then
    lspconfig.efm.setup{
        on_attach = on_attach,
        capabilities = capabilities,
    }
end

if lsp_exists("bash-language-server") then
    lspconfig.bashls.setup{
        on_attach = on_attach,
        capabilities = capabilities,
    }
end
if lsp_exists("deno") then
    lspconfig.denols.setup{
        on_attach = on_attach,
        capabilities = capabilities,
    }
end

if lsp_exists("zls") then
    lspconfig.zls.setup{
        on_attach = on_attach,
        capabilities = capabilities,
    }
end

if lsp_exists("gopls") then
    lspconfig.gopls.setup{
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
            gopls = {
                gofumpt = true,
                staticcheck = true
            }
        }
    }
end

if lsp_exists("pylsp") then
   lspconfig.pylsp.setup{
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
            pylsp = {
                plugins = {
                    pylsp_mypy = {
                        enabled = true,
                        strict = true
                    },
                    pydocstyle = {
                        enable = true,
                    },
                    pycodestyle = {
                        enabled = true,
                        maxLineLength = 120,
                    },
                    pyflakes = {
                        enabled = true,
                    },
                    yapf = {
                        enabled = false,
                    },
                    ruff = {
                        enabled = false,
                    }
                }
            }
        }
    }
end

if lsp_exists("rust-analyzer") then
    lspconfig.rust_analyzer.setup{
        on_attach = on_attach,
        capabilities = capabilities,
    }
end

if lsp_exists("clangd") then
    lspconfig.clangd.setup{
        on_attach = on_attach,
        capabilities = capabilities,
    }
end

if lsp_exists("nimlangserver") then
    lspconfig.nim_langserver.setup{
        on_attach = on_attach,
        capabilities = capabilities,
    }
end

if lsp_exists("serve-d") then
    lspconfig.serve_d.setup{
        on_attach = on_attach,
        capabilities = capabilities,
    }
end


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

-- scrollbar
require("scrollbar").setup({})
