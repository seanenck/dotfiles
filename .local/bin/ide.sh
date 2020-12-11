#!/bin/bash
_config () {
    kitty @ goto-layout splits
    kitty @ launch --location=hsplit
    kitty @ resize-window --axis=vertical -i=-8
}

source ~/.variables
if [ -e $KITTY_IDE_FILE ]; then
    rm -f $KITTY_IDE_FILE
    _config > /dev/null
else
    if [ ! -z "$1" ]; then
        if [[ "$1" == "start" ]]; then
            touch $KITTY_IDE_FILE
            kitty --detach --start-as=maximized --title=ide
        fi
    fi
fi
