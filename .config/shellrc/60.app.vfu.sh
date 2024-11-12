#!/bin/sh
if [ "$(uname)" = "Darwin" ]; then
  vfu() {
    EXT="\.json"
    SCREEN_NAME="vfu-vm-"
    CONFIGS="$HOME/.config/vfu/"
    START="start"
    STATUS="status"
    SCRIPT="vm"
    if [ -z "$1" ]; then
      echo "command required"
      return
    fi
    
    if [ "$1" = "completions" ]; then
      cat << EOF
#compdef _lb lb

_vfu() {
  local curcontext="$curcontext" state len chosen found args
  typeset -A opt_args

  _arguments \
    '1: :->main'\
    '*: :->args'

  len=\${#words[@]}
  case \$state in
    main)
      args="$START $STATUS"
      _arguments "1:main:(\$args)"
      ;;
    *)
      if [ "\$len" -ne 3 ]; then
        return
      fi
      chosen=\$words[2]
      if [ "\$chosen" = "$START" ]; then
        compadd \$@ \$(ls "$CONFIGS" | grep "$EXT" | cut -d "." -f 1)
      fi
      ;;
  esac
}

compdef _vfu vfu
EOF
      return
    fi
    
    DONE=0
    for FILE in $(ls "$CONFIGS" | grep "$EXT"); do
      NAME="$(basename "$FILE" | cut -d "." -f 1)"
      SCREEN="$SCREEN_NAME$NAME"
      case "$1" in
        "$STATUS")
          if [ "$DONE" -eq 0 ]; then
            printf "%-10s %s\n------------------\n" "vm" "status"
          fi
          DONE=1
          printf "%-10s " "$NAME"
          if screen -list 2>/dev/null | grep -q "$SCREEN"; then
            printf "running"
          else
            printf "stopped"
          fi
          echo
          ;;
        "$START")
          if [ -n "$2" ] && [ "$2" = "$NAME" ]; then
            screen -d -m -S "$SCREEN" /Applications/vfu.app/Contents/MacOS/vfu-cli --config "$CONFIGS/$FILE"
            DONE=1
            break
          fi
          ;;
      esac
    done
    
    if [ "$DONE" -eq 1 ]; then
      return
    fi
    
    echo "invalid command"
    echo
    echo "$SCRIPT [$START|$STATUS] <vm?>"
}
fi
