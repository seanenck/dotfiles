#!/bin/bash
_config () {
    local vars i
    vars=""
    for i in $(cat ~/.variables | grep "^export " | cut -d " " -f 2-); do
        vars="$vars --env=$i"
    done
    kitty @ goto-layout grid
    for i in $(seq 0 7); do
        if [ $i -eq 6 ]; then
            continue
        fi
        kitty @ launch $vars ssh cluster$i.voidedtech.com
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
