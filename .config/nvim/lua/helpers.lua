function map(mode, shortcut, command)
    vim.api.nvim_set_keymap(mode, shortcut, command, { noremap = true, silent = true })
end

function tmap(shortcut, command)
    map('t', shortcut, command)
end

function mapall(short, command)
    nmap(short, command)
    imap(short, command)
    vmap(short, command)
end

function nmap(shortcut, command)
    map('n', shortcut, command)
end

function imap(shortcut, command)
    map('i', shortcut, command)
end

function vmap(shortcut, command)
    map('v', shortcut, command)
end