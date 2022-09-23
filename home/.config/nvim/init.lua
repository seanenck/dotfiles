vim.o.runtimepath = vim.o.runtimepath .. ',/usr/share/vim/vimfiles'

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

-- Disable cursor keys
for _, cursor in ipairs({"<S-Up>", "<S-Down>", "<S-Right>", "<S-Left>"}) do
    mapall(cursor, "<Nop>")
end

-- Buffer/split movements
nmap("<Tab>", ":bnext<CR>")
nmap("<S-Tab>", ":bprevious<CR>")
nmap("<C-w>", ":bprevious <BAR> bd #<CR>")
nmap("<C-k>", ":vsplit<CR>")
nmap("<C-j>", ":close<CR>")
nmap("<S-l>", ":wincmd l<CR>")
nmap("<S-h>", ":wincmd h<CR>")

-- Terminal
tmap("<ESC>", " exit<CR>")
nmap("<C-t>", " :ToggleTerm direction=float<CR>")
