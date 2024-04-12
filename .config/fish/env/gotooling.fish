if test -e /run/.containerenv
    if set -q GOPATH
        function gotooling
            for tool in (cat "$HOME/.config/voidedtech/gotools")
                echo "installing: $tool"
                if ! go install "$tool"
                    echo "  -> failed"
                end
            end
        end
    end
else
    function gotooling
        toolbox run -c go fish -c "gotooling"
    end
end
