function build-toolbox
    set -l toolbox_version 39
    for tb in go ffmpeg
        if toolbox list -c | tail -n +2 | awk '{print $2}' | grep -q "^$tb\$"
            echo "$tb exists..."
            continue
        end
       if ! toolbox create --image "ghcr.io/enckse/fedora-toolbox-$tb:$toolbox_version-master" "$tb"
           echo "failed to build $tb"
           return
       end
    end
end
