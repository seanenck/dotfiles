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
    configurations["deno"] = function(options)
        new_client_autocmd({'javascript', 'typescript'}, function(args)
              return {
                  name = options.name,
                  capabilities = options.capabilities,
                  cmd = {options.name, "lsp"},
                  root_dir = vim.fs.root(args.buf, {'deno.json', 'deno.jsonc', '.git'}),
                  settings = {}
              }
          end
        )
    end
    return configurations
end
