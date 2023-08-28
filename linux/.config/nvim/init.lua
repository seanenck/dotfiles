vim.o.runtimepath = vim.o.runtimepath
vim.o.directory = "/home/enck/.cache/nvim"

-- Plugins
require("options")
require("helpers")
require("plugins")
require("autocmds")

-- Mouse, disable paste on middle click
for _, mouseMiddle in ipairs({"", "2-", "3-", "4-"}) do
    mapall("<" .. mouseMiddle .. "MiddleMouse>", '<Nop>')
end

-- Disable help
mapall("<F1>", "<Nop>")
-- Disable macros
nmap("q", "<Nop>")

-- Disable shifted cursor keys, ctrl jklh cursor, and q
-- Disable ctrl jklh cursors
disableall({"<S-Up>", "<S-Down>", "<S-Right>", "<S-Left>"})
disableall({"<C-j>", "<C-h>", "<C-l>", "<C-q>"})

-- Buffer/split movements
nmap("<Tab>", ":bnext<CR>")
nmap("<S-Tab>", ":bprevious<CR>")
nmap("<C-w>", ":bprevious <BAR> bd #<CR>")
nmap("<S-l>", ":wincmd l<CR>")
nmap("<S-h>", ":wincmd h<CR>")
local move_maps = { ["gl"] = "$", ["gh"] = "^", ["gk"] = "gg", ["gj"] = "G"}
for key, command in pairs(move_maps) do
    nmap(key, command)
    vmap(key, command)
end

-- allow for a non-register overwrite delete
nmap("rr", "\"_dd")

vim.api.nvim_set_hl(0, "Pmenu", {bg='black'})
vim.api.nvim_set_hl(0, "Search", {bg='peru', fg='wheat'})
