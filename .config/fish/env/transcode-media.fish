switch (uname)
    case Darwin
        function transcode-media
            for file in (ls)
                set -f target (date +%d.T_%H%M%S).(echo "$file" | shasum -a 256 | cut -c 1-7)
                set -l ext (echo "$file" | tr '[:upper:]' '[:lower:]' | rev | cut -d "." -f 1 | rev)
                echo "processing: $file"
                switch $ext
                    case heic
                        set -f output "$target.jpeg"
                        if ! sips --setProperty format jpeg --out "$output" "$file"
                            echo "unable to transcode via sips"
                            return
                        end
                    case mov
                        set -f output "$target.mp4"
                        if ! avconvert -s "$file" -o "$output" -p PresetHEVCHighestQuality
                            echo "unable to transcode via avconvert"
                            return
                        end
                end
                if set -q output
                    echo "  -> $output"
                    rm -f "$file"
                end
            end
        end
end
