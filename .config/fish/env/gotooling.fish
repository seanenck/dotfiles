if set -q GOPATH
    function gotooling
        for tool in (cat "$HOME/.config/etc/gotools")
            echo "installing: $tool"
            if ! go install "$tool"
                echo "  -> failed"
            end
        end
    end
end
