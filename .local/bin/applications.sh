#!/bin/bash
KITTY_CLUSTER=/tmp/is_cluster
KITTY_IDE=/tmp/is_ide
KITTY_NODE=/tmp/is_node

source ~/.variables

if [ -e $KITTY_CLUSTER ]; then
    rm -f $KITTY_CLUSTER
    perl ~/.local/bin/cluster
    exit 0
fi

if [ -e $KITTY_NODE ]; then
    rm -f $KITTY_NODE
    perl ~/.local/bin/cluster node
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

cmd=""
screen="maximized"
case $action in
    "ide")
        touch $KITTY_IDE
        ;;
    "cluster")
        touch $KITTY_CLUSTER
        screen="minimized"
        ;;
    "node")
        touch $KITTY_NODE
        ;;
    "fastmail")
        $HOME/.local/bin/sys mail &
        cmd="-d=$HOME/downloads /usr/bin/mutt -F $HOME/.mutt/fastmail.muttrc"
        ;;
    *)
        action=""
        ;;
esac

if [ ! -z "$action" ]; then
    kitty --detach --start-as=$screen --title=$action $cmd
fi
