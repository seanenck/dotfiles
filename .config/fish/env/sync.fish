switch (uname)
    case Darwin
        function sync-system
            set -f sync_dir "$HOME/.local/voidedtech/synced"
            set -f brew_file "$sync_dir/Brewfile"
            if test -e "$brew_file"
                rm -f "$brew_file"
            end
            if ! fish -c "cd $sync_dir && brew bundle dump"
                echo "failed brew dump"
                return
            end
            if ! cp "$HOME/.config/vm/alpine.json" "$sync_dir/vm.json"
                echo "failed to backup vm config"
                return
            end
            if ! rsync -avc --delete-after "$sync_dir/" "core.voidedtech.com:~/Active/air/"
                echo "failed to rsync state"
                return
            end
        end
end
