function update-system
    neovim-plugins
    gotooling
    remotes
    set -l brewfile "$HOME/.local/state/Brewfile"
    rm -f "$brewfile"
    cd $(dirname "$brewfile")
    brew bundle dump
end
