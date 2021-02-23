#!/bin/bash
IS_TWTUI=$HOME/.cache/drudge/is_twtui

if [ -e $IS_TWTUI ]; then
    rm -f $IS_TWTUI
    taskwarrior-tui
    exit 0
fi

if [ -z "$1" ]; then
    touch $IS_TWTUI
    kitty --detach --start-as=maximized --title=twtui
fi
