#!/bin/bash
CMD=$1
if [ -z "$CMD" ]; then
    exit
fi
IS_LAPTOP=0
IS_DESKTOP=0
if [ -d /sys/class/power_supply/BAT0 ]; then
    IS_LAPTOP=1
else
    IS_DESKTOP=1
fi
case $CMD in
    "sleep")
        if [ $IS_LAPTOP -eq 1 ]; then
            systemctl suspend
        fi
        ;;
    "outputs")
        if [ $IS_LAPTOP -eq 1 ]; then
            swaymsg output eDP-1 pos 0 0 res 3840x2160
        fi
        if [ $IS_DESKTOP -eq 1 ]; then
            swaymsg output DP-2 transform 90
        fi
        ;;
esac
