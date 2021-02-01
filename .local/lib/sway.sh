#!/bin/bash
source ~/.local/env/vars
CMD=$1
if [ -z "$CMD" ]; then
    exit
fi
case $CMD in
    "sleep")
        if [ -e $IS_LAPTOP ]; then
            systemctl suspend
        fi
        ;;
    "outputs")
        if [ -e $IS_LAPTOP ]; then
            swaymsg output eDP-1 pos 0 0 res 3840x2160
        fi
        ;;
esac
