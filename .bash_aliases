alias checksum='find -type f -exec sha512sum "{}" + | sort -k 2'
alias clip="xclip -selection 'clip-board'"
alias nano="vim"
alias notes="vim notes"
alias pacman="sudo pacman"
alias reset-brightness="sudo tee /sys/class/backlight/intel_backlight/brightness <<< 2000"
alias ssid="sudo iwlist wlp3s0 scanning essid"
alias tree='tree -J | python -c "import sys, json; print(json.dumps(json.loads(sys.stdin.read()), indent=1, sort_keys=True, separators=(\",\", \":\")))"'
alias vimtext="touch /home/enck/.tmp/textmode && vim"
alias vi="vim"
alias weechat="rm -f /home/enck/.tmp/weechat.ready && weechat"
alias xhost-local="xhost +local:"
git() {
    /usr/bin/git "$@" || return
    echo "$@" | grep -E -q "(push|commit|reset|checkout|branch|stash|status)"
    if [ $? -eq 0 ]; then
        rm -rf /home/enck/.tmp/git.changes
    fi
}
machinectl() {
    local did=0
    if [ ! -z "$1" ]; then
        case "$1" in
            "$USER")
                sudo /usr/bin/machinectl shell $USER@$2
                did=1
                ;;
            "shell")
                if [ ! -z "$2" ]; then
                    machinectl list-images | grep -q $2
                    if [ $? -ne 0 ]; then
                        echo "machine $2 does not exist"
                    else
                        machinectl status $2 &> /dev/null
                        if [ $? -ne 0 ]; then
                            echo "starting $2"
                            machinectl start $2
                            sleep 1
                        fi
                    fi
                fi
                ;;
        esac
    fi
    if [ $did -eq 0 ]; then
        sudo /usr/bin/machinectl $@
    fi
}
