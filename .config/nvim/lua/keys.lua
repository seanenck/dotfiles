local mappers = {}
for idx, k in pairs({"n", "i", "v"}) do
    mappers[k .. "map"] = function(shortcut, command)
        vim.api.nvim_set_keymap(k, shortcut, command, { noremap = true, silent = true })
    end
end
mappers.nop = function(shortcuts)
    for i, val in pairs(shortcuts) do
        for idx, fxn in pairs({mappers.nmap, mappers.imap, mappers.vmap}) do
            fxn(val, '<Nop>')
        end
    end
end

-- Disable help
mappers.nop({"<F1>"})
-- Mouse, disable paste on middle click
for _, mouseMiddle in ipairs({"", "2-", "3-", "4-"}) do
    mappers.nop({"<" .. mouseMiddle .. "MiddleMouse>"})
end
mappers.nop({"<RightMouse>"})

-- disable macros
mappers.nmap("q", "<Nop>")

-- Disable shifted cursor keys, ctrl jklh cursor, and q
-- Disable ctrl jklh cursors
mappers.nop({"<S-Up>", "<S-Down>", "<S-Right>", "<S-Left>",
             "<C-h>", "<C-l>", "<C-q>"})

-- Buffer/split movements
mappers.nmap("<Tab>", ":bnext<CR>")
mappers.nmap("<S-Tab>", ":bprevious<CR>")
mappers.nmap("<C-w>", ":bprevious <BAR> bd #<CR>")
mappers.nmap("<S-l>", ":wincmd l<CR>")
mappers.nmap("<S-h>", ":wincmd h<CR>")
for key, command in pairs({ ["gl"] = "$", ["gh"] = "^", ["gk"] = "gg", ["gj"] = "G"}) do
    mappers.nmap(key, command)
    mappers.vmap(key, command)
end

-- allow clip on/off
local clip_cfg = {}
local handle_clip = function()
    clip_color = "black"
    if clip_cfg.clipboard == nil then
        clip_cfg.clipboard = vim.opt.clipboard
        vim.opt.clipboard = ""
    else
        vim.opt.clipboard = clip_cfg.clipboard
        clip_cfg.clipboard = nil
        clip_color = "#373737"
    end
    vim.api.nvim_set_hl(0, "Normal", {bg=clip_color, fg='white'})
end

handle_clip()
vim.keymap.set("n", "<C-c>", handle_clip, { noremap = true, silent = true })
