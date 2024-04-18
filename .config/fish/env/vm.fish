switch (uname)
    case Darwin
        function vm
            set -l screen_name "vfu-vm"
            if not set -q argv[1]
                echo "argument required"
                return
            end
            switch $argv[1]
                case status
                    if screen -list 2>/dev/null | grep -q "$screen_name"
                        echo "running"
                        return
                    end
                    echo "stopped"
                case start
                    screen -d -m -S "$screen_name" vfu --config "$HOME/.config/vm/alpine.json"
                case '*'
                    echo "unknown command"
                    return
            end
        end
end
