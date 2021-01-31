#!/bin/ash

CMD=$1

if [ -z "$CMD" ]; then
    echo "command required"
    exit 1
fi

CONF="$HOME/.cache/.hikari.conf"

_reconfig() {
    local use f
    if [ -e $IS_LAPTOP ]; then
        use="laptop"
    else
        if [ -e $IS_DESKTOP ]; then
            use="desktop"
        fi
    fi
    rm -f $CONF
    for f in $(echo "template $use"); do
        cat $HOME/.config/hikari/$f.conf >> $CONF
    done
}

case $CMD in
    "start")
        _reconfig
        rm -f /tmp/.hikari.*
        hikari -c $CONF > $HOME/.cache/hikari.log 2>&1
        ;;
    "reconfigure")
        _reconfig
        ;; 
    *)
        echo "unknown command: $CMD"
        exit 1
        ;;
esac
