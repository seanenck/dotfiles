return function(settings)
    settings.lspconfig["gopls"].setup{
        capabilities = settings.capabilities, 
        settings = {
            gopls = {
                gofumpt = true,
                staticcheck = true
            }
        }
    }
end
