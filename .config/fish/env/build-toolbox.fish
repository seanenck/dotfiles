if ! test -e /run/.containerenv
    function create-containerfile
        echo "FROM registry.fedoraproject.org/fedora-toolbox:$VERSION"
        echo
        echo "RUN dnf update -y && dnf upgrade -y"
        echo "RUN dnf install -y \\"
        switch $argv[1]
            case go
                echo "    golang-go \\"
            case ffmpeg
                echo "    ffmpeg-free \\"
        end
        for package in (echo "$PACKAGE_BASE_SET" | tr ' ' '\n')
            if [ "$package" = "$(echo "$PACKAGE_BASE_SET" | tr ' ' '\n' | tail -n 1)" ]
                echo "    $package"
            else
                echo "    $package \\"
            end
        end
    end
    function build-toolbox
        for export in VERSION PACKAGE_BASE_SET
            eval (sh -c "source $HOME/.config/voidedtech/containers && echo set -g -x $export \'\$$export\'")
        end
        for tb in go ffmpeg generic
            if toolbox list -c | tail -n +2 | awk '{print $2}' | grep -q "^$tb\$"
                echo "$tb exists..."
                continue
            end
            set -l tmpfile (mktemp)
            create-containerfile $tb > "$tmpfile"
            set -l image "voidedtech-$tb-$VERSION"
            if ! toolbox list -i | tail -n +2 | awk '{print $2}' | grep -q "$image"
                if ! podman build -f "$tmpfile" --tag "$image"
                    echo "failed to build: $image"
                end
            end
            if ! toolbox create --image "$image" "$tb"
                echo "failed to create: $tb"
            end
            rm -f $tmpfile
        end
    end
end
