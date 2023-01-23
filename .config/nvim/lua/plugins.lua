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

  local bufopts = { noremap=true, silent=true, buffer=bufnr }

  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

local function setuplsp(exec, name, extension, settings)
  if vim.fn.executable(exec) ~= 1 then
      return
  end
  capabilities = require('cmp_nvim_lsp').default_capabilities()
  require("lspconfig")[name].setup{
    on_attach = on_attach,
    capabilities = capabilities,
    settings = settings
  }
  vim.api.nvim_create_autocmd({ "BufWritePre" }, {
      pattern = { "*." .. extension },
      callback = function()
          vim.lsp.buf.format { async = false }
      end
  })
end

setuplsp("gopls", "gopls", "go", {gopls = { gofumpt = true, staticcheck = true}})
setuplsp("rust-analyzer", "rust_analyzer", "rs", {})
setuplsp("efm-langserver", "efm", "*", {})
