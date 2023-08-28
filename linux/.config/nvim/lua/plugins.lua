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
    elseif exe == "efm-langserver" then
        lspconfig.efm.setup{
            on_attach = on_attach,
            capabilities = capabilities,
            init_options = {documentFormatting = true},
            settings = {
                rootMarkers = {".git/"},
                languages = {
                    sh = {
                        {
                            lintCommand = 'shellcheck -f gcc -x',
                            lintSource = 'shellcheck',
                            lintFormats = {
                                '%f:%l:%c: %trror: %m',
                                '%f:%l:%c: %tarning: %m',
                                '%f:%l:%c: %tote: %m'
                            },
                            lintIgnoreExitCode = true
                        }
                    }
                }
            }
        }
    elseif exe == "pylsp" then
        lspconfig.pylsp.setup{
            on_attach = on_attach,
            capabilities = capabilities,
            init_options = {documentFormatting = true},
            settings = {
                pylsp = {
                    plugins = {
                        autopep8 = {
                            enabled = false,
                        },
                        pylsp_mypy = {
                            enabled = true,
                            strict = true
                        },
                        yapf = {
                            enabled = true
                        },
                        pycodestyle = {
                            enabled = true,
                            maxLineLength = 120,
                        },
                        pyflakes = {
                            enabled = true,
                        }
                    }
                }
            }
        }
    else
        error("unknown lsp requested")
    end
    vim.api.nvim_create_autocmd({ "BufWritePre" }, {
        pattern = { "*" },
        callback = function()
            for _, ft in ipairs(format_types) do
                if vim.bo.filetype ~= nil and vim.bo.filetype ~= "" and vim.bo.filetype == ft then
                    vim.lsp.buf.format { async = false }
                    return
                end
            end
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
end

setuplsp("pylsp", {"python"})
setuplsp("rust-analyzer", {"rust"})
setuplsp("gopls", {"go"})
setuplsp("efm-langserver", {})
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
    open_mapping = [[<C-Space>]],
}

function _G.set_terminal_keymaps()
  local opts = {buffer = 0}
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
end

vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
mapall("<C-k>", ":wincmd k<CR>")
