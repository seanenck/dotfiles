#!/bin/bash
IS_MAIL=$HOME/.cache/drudge/is_mail

if [ -e $IS_MAIL ]; then
    rm -f $IS_MAIL
    mutt -F $HOME/.mutt/fastmail.muttrc
    exit 0
fi

if [ -z "$1" ]; then
    touch $IS_MAIL
    kitty --detach --start-as=maximized --title=fastmail
fi
