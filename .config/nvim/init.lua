-- Plugins
require("options")
require("plugins")
require("autocmds")

local function map(mode, shortcut, command)
    vim.api.nvim_set_keymap(mode, shortcut, command, { noremap = true, silent = true })
end

local function nmap(shortcut, command)
    map('n', shortcut, command)
end

local function imap(shortcut, command)
    map('i', shortcut, command)
end

local function vmap(shortcut, command)
    map('v', shortcut, command)
end

local function nop(vals)
    for i, val in pairs(vals) do
        for idx, fxn in pairs({nmap, imap, vmap}) do
            fxn(val, '<Nop>')
        end
    end
end


if vim.version().major == 0 and vim.version().minor >= 10 then
    vim.cmd 'colorscheme vim'
end

-- Disable help
nop({"<F1>"})
-- Mouse, disable paste on middle click
for _, mouseMiddle in ipairs({"", "2-", "3-", "4-"}) do
    nop({"<" .. mouseMiddle .. "MiddleMouse>"})
end

-- disable macros
nmap("q", "<Nop>")

-- Disable shifted cursor keys, ctrl jklh cursor, and q
-- Disable ctrl jklh cursors
nop({"<S-Up>", "<S-Down>", "<S-Right>", "<S-Left>",
     "<C-h>", "<C-l>", "<C-q>"})

-- Buffer/split movements
nmap("<Tab>", ":bnext<CR>")
nmap("<S-Tab>", ":bprevious<CR>")
nmap("<C-w>", ":bprevious <BAR> bd #<CR>")
nmap("<S-l>", ":wincmd l<CR>")
nmap("<S-h>", ":wincmd h<CR>")
for key, command in pairs({ ["gl"] = "$", ["gh"] = "^", ["gk"] = "gg", ["gj"] = "G"}) do
    nmap(key, command)
    vmap(key, command)
end

vim.api.nvim_set_hl(0, "Pmenu", {bg='white', fg='black'})
vim.api.nvim_set_hl(0, "Search", {bg='white', fg='black'})
