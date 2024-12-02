return function(capabilities, lspconfig)
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
end
