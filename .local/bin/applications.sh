#!/bin/bash
KITTY_CLUSTER=/tmp/is_cluster
KITTY_IDE=/tmp/is_ide

source ~/.variables

if [ -e $KITTY_CLUSTER ]; then
    rm -f $KITTY_CLUSTER
    perl ~/.local/bin/cluster
    exit 0
fi

_ide () {
    kitty @ goto-layout splits
    kitty @ launch --location=hsplit
    kitty @ resize-window --axis=vertical -i=-8
}

if [ -e $KITTY_IDE ]; then
    rm -f $KITTY_IDE
    _ide > /dev/null
    exit 0
fi

action=$1

if [[ "$action" == "" ]]; then
    exit 0
fi

case $action in
    "ide")
        touch $KITTY_IDE
        ;;
    "cluster")
        touch $KITTY_CLUSTER
        ;;
    *)
        action=""
        ;;
esac

if [ ! -z "$action" ]; then
    kitty --detach --start-as=maximized --title=$action
fi
