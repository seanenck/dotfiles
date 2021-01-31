#!/bin/bash
export MOZ_ENABLE_WAYLAND=1
TRIGGER="$HOME/.cache/.hikari"
rm -f $TRIGGER
while [ ! -e $TRIGGER ]; do
    CONF=$HOME/.cache/.hikari.conf
    USE="template"
    if [ -e $IS_LAPTOP ]; then
        USE="$USE laptop"
    fi
    if [ -e $IS_DESKTOP ]; then
        USE="$USE desktop"
    fi
    rm -f $CONF
    for f in $(echo $USE); do
        cat $HOME/.config/hikari/$f.conf >> $CONF
    done
    rm -f /tmp/.hikari.*
    hikari -c $CONF > $HOME/.cache/hikari.log 2>&1
done
