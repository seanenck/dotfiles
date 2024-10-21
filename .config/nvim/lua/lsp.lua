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

-- actual lsp setup
util = require("lspconfig.util")
lspconfig = require("lspconfig")

local capabilities = require('cmp_nvim_lsp').default_capabilities()
local paths = {}
for p in string.gmatch(os.getenv("PATH"), "([^:]+)") do
    paths[p] = 1
end
lsps = {
    ["bashls"] = {},
    ["pyright"] = {},
    ["efm"] = {
        filetypes = {"sh"},
        init_options = {documentFormatting = false},
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
    },
    ["gopls"] = {
        settings = {
            gopls = {
                gofumpt = true,
                staticcheck = true
            }
        }
    }
}

for lsp, overrides in pairs(lsps) do
    cfg = require(string.format("lspconfig.configs.%s", lsp)).default_config
    exe = nil
    for _, arg in pairs(cfg.cmd) do
        exe = arg
        break
    end
    if exe == nil then
        error("cmd not found for lsp")
    end
    local function set_or_default(key)
        val = cfg[key]
        if overrides[key] ~= nil then
            val = overrides[key]
        end
        return val
    end
    for path in pairs(paths) do
        if util.path.is_file(string.format("%s/%s", path, exe)) then
            lspconfig[lsp].setup{
                init_options = set_or_default("init_options"),
                capabilities = capabilities, 
                settings = set_or_default("settings"),
                filetypes = set_or_default("filetypes")
            }
            break
        end
    end
end

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = "*",
    callback = function()
        for key, val in pairs(vim.lsp.get_clients({bufnr = vim.api.nvim_get_current_buf()})) do
            if val["name"] == "efm" then
                return
            end
        end
        vim.lsp.buf.format { async = false }
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
    end, { noremap = true, silent = true })
