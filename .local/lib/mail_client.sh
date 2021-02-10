#!/bin/bash
if [ ! -z "$SSH_CONNECTION" ]; then
    echo "do not run from ssh"
    sleep 5
    exit 1
fi

source ~/.local/env/vars
drudge system.online local
if [ $? -ne 0 ]; then
    echo "local server unavailable?"
    sleep 5
    exit 1
fi

MAILHOST=$LOCAL_SERVER
if [ ! -z "$1" ]; then
    case $1 in
        "new")
            drudge ask $MAILHOST mail | grep -v '^$' | sed 's/^/mail:/g'
            ;;
    esac
    exit 0
fi

ssh $MAILHOST -- touch $START_MUTT
ssh $MAILHOST
