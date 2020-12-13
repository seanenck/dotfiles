#!/bin/bash
_config () {
    local i
    kitty @ goto-layout grid
    for i in $(seq 0 7); do
        if [ $i -eq 6 ]; then
            continue
        fi
        kitty @ launch --env KITTY_CLUSTER="cluster$i" ~/.local/bin/sys sshcluster 
    done
}

source ~/.variables
if [ -e $KITTY_CLUSTER_FILE ]; then
    rm $KITTY_CLUSTER_FILE
    _config > /dev/null
else
    if [ ! -z "$1" ]; then
        echo "$1" > /tmp/action
        case "$1" in
            "start")
                touch $KITTY_CLUSTER_FILE
                kitty --detach --start-as=maximized --title=cluster
                ;;
        esac
    fi
fi
