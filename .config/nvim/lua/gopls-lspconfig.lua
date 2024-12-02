return function(capabilities, lspconfig)
    lspconfig["gopls"].setup{
        capabilities = capabilities, 
        settings = {
            gopls = {
                gofumpt = true,
                staticcheck = true
            }
        }
    }
end
