#!/bin/ash

CMD=$1

if [ -z "$CMD" ]; then
    echo "command required"
    exit 1
fi

TRIGGER="$HOME/.cache/.hikari.trigger"
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
        rm -f $TRIGGER
        while [ ! -e $TRIGGER ]; do
            _reconfig
            rm -f /tmp/.hikari.*
            hikari -c $CONF 2>&1 | systemd-cat hikari
        done
        ;;
    "reconfigure")
        _reconfig
        ;; 
    "kill")
        touch $TRIGGER
        ;;
    *)
        echo "unknown command: $CMD"
        exit 1
        ;;
esac
