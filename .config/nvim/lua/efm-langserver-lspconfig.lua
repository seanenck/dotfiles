return function(capabilities, lspconfig)
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
end
