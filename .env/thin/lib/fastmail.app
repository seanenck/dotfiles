#!/bin/bash
IS_MAIL=$HOME/.cache/drudge/is_mail

if [ -e $IS_MAIL ]; then
    rm -f $IS_MAIL
    MAILHOST=library
    ssh $MAILHOST -- touch $START_MUTT
    ssh $MAILHOST
    exit 0
fi

if [ -z "$1" ]; then
    touch $IS_MAIL
    kitty --detach --start-as=maximized --title=fastmail
fi
