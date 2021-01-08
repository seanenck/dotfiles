#!/bin/bash
KITTY_IDE=/tmp/is_ide

source ~/.variables

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
