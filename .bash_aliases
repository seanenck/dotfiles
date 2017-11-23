alias checksum='find -type f -exec sha512sum "{}" + | sort -k 2'
alias csv-processing="$HOME/.bin/modules/csv-stats/csvstats.sh"
alias machinectl="sudo machinectl"
alias notes="vim notes"
alias pacman="sudo pacman"
alias reset-brightness="sudo tee /sys/class/backlight/intel_backlight/brightness <<< 2000"
alias ssid="sudo iwlist wlp3s0 scanning essid"
alias tree='tree -J | python -c "import sys, json; print(json.dumps(json.loads(sys.stdin.read()), indent=1, sort_keys=True, separators=(\",\", \":\")))"'
alias vimtext="touch /tmp/textmode && vim"
alias weechat="rm -f /tmp/weechat.ready && weechat"
alias xhost-local="xhost +local:"
alias vi="vim"
alias nano="vim"
