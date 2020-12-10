#!/bin/bash
_config () {
    kitty @ goto-layout splits
    kitty @ launch --location=hsplit
    kitty @ resize-window --axis=vertical -i=-8
}

source ~/.variables
if [ -e $IDE_FILE ]; then
    rm $IDE_FILE
    _config > /dev/null
else
    if [ ! -z "$1" ]; then
        if [[ "$1" == "start" ]]; then
            touch $IDE_FILE
            kitty --start-as=maximized --title=ide
        fi
    fi
fi
