function neovim-plugins
    set -l plugins "$HOME/.config/nvim/pack/plugins/start"
    for plugin in (cat "$HOME/.config/voidedtech/neovim-plugins")
        set -l name (basename "$plugin")
        set -l clone "$plugins/$name"
        echo "updating plugin: $name"
        if test -d "$clone"
            if ! git -C "$clone" pull origin (git -C "$clone" rev-parse --abbrev-ref HEAD)
                echo "  -> failed to update"
            end
        else
            if ! git clone "$plugin" "$clone" --single-branch
                echo "  -> failed to clone"
            end
        end
    end
end
