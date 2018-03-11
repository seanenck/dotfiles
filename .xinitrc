#!/bin/bash
xmodmap -e "clear lock"
[[ -f ~/.Xmodmap ]] && xmodmap ~/.Xmodmap
xrdb -merge ~/.Xresources
exec i3
