switch (uname)
    case Darwin
        function sync-system
            set -f sync_dir "$HOME/.local/voidedtech/synced"
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
