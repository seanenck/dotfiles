switch (uname)
    case Darwin
        function remotes
            set -l remote_file "$HOME/.local/voidedtech/remotes"
            set -l remote_last "$remote_file.last"
            touch "$remote_file" "$remote_last"
            for remote in https://gitlab.alpinelinux.org/alpine/aports https://github.com/kovidgoyal/kitty
                echo "getting: $remote"
                set -l name $(basename "$remote")
                git ls-remote --tags "$remote" 2>/dev/null | awk '{print $2}' | grep -v '{}' | rev | cut -d "/" -f 1 | rev | sed "s#^#$name #g" >> "$remote_file"
            end
            sort -u -o "$remote_file" "$remote_file"
            if diff -u "$remote_last" "$remote_file"
                rm -f "$remote_file"
                return
            end
            read -l -P 'Updates applied? [y/N] ' confirm

            switch $confirm
                case Y y
                    mv "$remote_file" "$remote_last"
            end
            rm -f "$remote_file"
        end
end
