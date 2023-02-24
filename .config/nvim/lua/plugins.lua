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
local on_attach = function(client, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
end

local function setuplsp(exec, name, extension, settings, filetypes)
    if vim.fn.executable(exec) ~= 1 then
        return
    end
    capabilities = require('cmp_nvim_lsp').default_capabilities()
    local cfg = require("lspconfig")[name]
    cfg.setup{
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes=filetypes,
        settings = settings,
    }
    if extension ~= nil then
        vim.api.nvim_create_autocmd({ "BufWritePre" }, {
            pattern = { "*." .. extension },
            callback = function()
                vim.lsp.buf.format { async = false }
            end
        })
    end
    vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
        vim.lsp.diagnostic.on_publish_diagnostics,
        {
            virtual_text = false,
            signs = true,
            update_in_insert = false,
            underline = true,
        }
    )
end

setuplsp("gopls", "gopls", "go", {gopls = { gofumpt = true, staticcheck = true}}, nil)
setuplsp("rust-analyzer", "rust_analyzer", "rs", nil, nil)
setuplsp("efm-langserver", "efm", nil, nil, {"sh", "json", "yaml"})
local diagnostics_active = true
toggle_diagnostics = function()
    diagnostics_active = not diagnostics_active
    if diagnostics_active then
        vim.diagnostic.enable()
    else
        vim.diagnostic.disable()
    end
end
vim.api.nvim_buf_set_keymap(0, 'n', '<C-d>', ':call v:lua.toggle_diagnostics()<CR>', {silent=true, noremap=true})

vim.o.updatetime = 250
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
    pattern = "*",
    callback = function()
        if diagnostics_active then
            vim.diagnostic.open_float(nil, {focus=false})
        end
    end
})

-- telescope
local function is_git()
    local res = os.execute("git rev-parse")
    return res ~= nil and res
end

require('telescope').setup{
  defaults = {
    mappings = {
      n = {
        ["<C-q>"] = "close"
      },
      i = {
        ["<C-q>"] = "close"
      }
    }
  },
}

local tele = require('telescope.builtin')
local function list_files()
    if quickfix_window() then
        return
    end
    if is_git() then
        tele.git_files()
    else
        tele.find_files()
    end
end

vim.keymap.set('n', '<C-o>', list_files, {})

-- term
require("toggleterm").setup{
    open_mapping = [[<C-t>]],
    direction = "float",
}
