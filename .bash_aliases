alias tree='tree -J | python -c "import sys, json; print(json.dumps(json.loads(sys.stdin.read()), indent=1, sort_keys=True, separators=(\",\", \":\")))"'
alias checksum='find -type f -exec sha512sum "{}" + | sort -k 2'
alias machinectl="sudo machinectl"
alias notes="vim notes"
alias ssid="sudo iwlist wlp3s0 scanning essid"
alias csv-processing="$HOME/.bin/modules/csv-stats/csvstats.sh"
alias xhost-local="xhost +local:"
alias load-keys="mounting keys"
alias clip="xclip -selection 'clip-board'"
