-- airline settings
vim.g.airline_extensions = {"tabline"}
vim.g.airline_extensions["tabline"] = {["formatter"] = "unique_tail_improved"}

-- lsp
lspconfig = require "lspconfig"
local function setuplsp()
    lspconfig.gopls.setup{
        settings = {
            gopls = {
                gofumpt = true,
                staticcheck = true
            }
        },
    }
    lspconfig.pylsp.setup{
        settings = {
            pylsp = {
                plugins = {
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

setuplsp()
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
  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
end

vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
mapall("<C-j>", ":wincmd j<CR>")

-- guard
local ft = require('guard.filetype')
local lint = require('guard.lint')

ft('go'):fmt({
    cmd = 'gofumpt',
    args = {"-extra"},
    stdin = true
})

ft("python"):fmt({
    cmd = "yapf",
    stdin = true,
    ignore_error = true
}):lint({
    cmd = "dmypy",
    args = {"--status-file", os.getenv( "HOME" ) .. "/.cache/dmypy.json", "run"},
    ignore_error = true,
    parse = lint.from_regex({
        regex = ':(%d+):(%d*):%s+(%w+):%s+(.-)%s+%[(.-)%]',
        groups = { 'lnum', 'col', 'severity', 'message', 'code' },
        severities = {
          information = lint.severities.info,
          hint = lint.severities.info,
          note = lint.severities.style,
        },
  }),
})

ft("sh"):lint("shellcheck")

require('guard').setup({
    fmt_on_save = true,
    lsp_as_default_formatter = false,
})

-- mini completion
vim.api.nvim_command('inoremap <silent><expr> <Right> pumvisible() ? "<C-n>" : "<Right>"')
require('mini.completion').setup()
