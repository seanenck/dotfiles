local function new_client_autocmd(pattern, factory)
    vim.api.nvim_create_autocmd('FileType', {
        pattern = pattern,
        callback = function(args)
            vim.lsp.start(factory(args))
        end
    })
end

function get_clients()
    local configurations = {}
    configurations["gopls"] = function(options)
        new_client_autocmd({'go', 'gomod'}, function(args)
              return {
                  name = options.name,
                  capabilities = options.capabilities,
                  cmd = {options.name},
                  root_dir = vim.fs.root(args.buf, {'go.mod', 'go.sum'}),
                  settings = {
                      gopls = {
                          gofumpt = true,
                          staticcheck = true
                      }
                  }
              }
          end
        )
    end
    configurations["efm-langserver"] = function(options)
        new_client_autocmd({'sh'}, function(args)
                return {
                    name = options.name,
                    capabilities = options.capabilities,
                    init_options = {documentFormatting = false},
                    cmd = {options.name},
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
        )
    end
    return configurations
end
