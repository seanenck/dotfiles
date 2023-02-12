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

-- fugitive/telescope
local function is_git()
    local res = os.execute("git rev-parse")
    return res ~= nil and res
end

local function set_ctrlq(enable)
    local function is_active()
        if not is_git() then
            return false
        end
        return quickfix_window()
    end
    local function manage_quickfix()
        if is_active() then
            vim.api.nvim_exec(":cclose", false)
        else
            local width = vim.api.nvim_win_get_width(0) * (3/4)
            vim.api.nvim_exec(":vertical Gclog -n 1000", false)
            vim.api.nvim_exec(string.format(":vertical resize %s<CR>", width), false)
        end
    end
    local function manage_ctrll()
        if is_active() then
            vim.api.nvim_exec(":vertical resize -1", false)
        else
            vim.api.nvim_exec(":vsplit", false)
        end
    end
    local function manage_keybind(call)
        return function()
            if is_active() then
                vim.api.nvim_exec(call, false)
            end
        end
    end

    mapall("<C-k>", "")
    mapall("<C-j>", "")
    mapall("<C-h>", "")
    mapall("<C-l>", "")
    vim.keymap.set('n', '<C-l>', manage_ctrll, {})
    if enable and is_git() then
        vim.keymap.set('n', '<C-h>', manage_keybind(":vertical resize +1"), {})
        vim.keymap.set('n', '<C-j>', manage_keybind(":cnext"), {})
        vim.keymap.set('n', '<C-k>', manage_keybind(":cprev"), {})
        vim.keymap.set('n', '<C-q>', manage_quickfix, {})
    else
        mapall("<C-q>", "")
    end
end

-- telescope
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
    set_ctrlq(false)
    if is_git() then
        tele.git_files()
    else
        tele.find_files()
    end
    set_ctrlq(true)
end

vim.keymap.set('n', '<C-o>', list_files, {})

set_ctrlq(true)
