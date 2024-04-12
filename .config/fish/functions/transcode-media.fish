if test -e /run/.containerenv
    function transcode-media
        for file in (ls)
            set -f target (date +%d.T_%H%M%S).(echo "$file" | sha256sum | cut -c 1-7)
            set -l ext (echo "$file" | tr '[:upper:]' '[:lower:]' | rev | cut -d "." -f 1 | rev)
            echo "processing: $file"
            switch $ext
                case jpeg
                    set -f output "$target.jpeg"
                    if ! cp "$file" "$output"
                        echo "unable to copy"
                        return
                    end
                case mov
                    set -f output "$target.mp4"
                    if ! ffmpeg -i "$file" -c copy "$target"
                        echo "unable to transcode via ffmpeg"
                        return
                    end
            end
            if set -q output
                echo "  -> $output"
                rm -f "$file"
            end
        end
    end
else
    function transcode-media
        toolbox run -c ffmpeg transcode-media
    end
end
