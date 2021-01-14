#!/bin/bash
KITTY_IDE=/tmp/is_ide
_ide () {
    kitty @ goto-layout splits
    kitty @ launch --location=hsplit
    kitty @ resize-window --axis=vertical -i=-8
}

if [ -e $KITTY_IDE ]; then
    rm -f $KITTY_IDE
    _ide > /dev/null
fi

if [ -z "$1" ]; then
    touch $KITTY_IDE
    kitty --detach --start-as=maximized --title=ide
fi
