#!/bin/bash
_config () {
    local vars i
    vars=""
    for i in $(cat ~/.variables | grep "^export " | cut -d " " -f 2-); do
        vars="$vars --env=$i"
    done
    kitty @ goto-layout grid
    for i in $(seq 1 7); do
        kitty @ launch $vars ssh cluster$i
    done
}

source ~/.variables
if [ -e $KITTY_CLUSTER_FILE ]; then
    rm $KITTY_CLUSTER_FILE
    _config > /dev/null
else
    if [ ! -z "$1" ]; then
        if [[ "$1" == "start" ]]; then
            touch $KITTY_CLUSTER_FILE
            kitty --detach --start-as=maximized --title=cluster
        fi
    fi
fi
