-- lsp configurations
local capabilities = require('cmp_nvim_lsp').default_capabilities()
lspconfig["pylsp"].setup{
    capabilities = capabilities,
    settings = {
        pylsp = {
            plugins = {
                pylsp_mypy = {
                    enabled = true,
                    strict = true
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
lspconfig["efm"].setup{
    capabilities = capabilities, 
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
}
lspconfig["gopls"].setup{
    capabilities = capabilities, 
    settings = {
        gopls = {
            gofumpt = true,
            staticcheck = true
        }
    }
}
