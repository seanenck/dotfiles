#!/bin/bash
export MOZ_ENABLE_WAYLAND=1
while [ 1 -eq 1 ]; do
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
        hikari -c $CONF > $HOME/.cache/hikari.log
done
