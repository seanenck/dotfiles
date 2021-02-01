#!/bin/bash
source ~/.local/env/vars
if [ -e $IS_LAPTOP ]; then
    swaymsg output eDP-1 pos 0 0 res 3840x2160
fi
