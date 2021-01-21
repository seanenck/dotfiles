#!/bin/bash
if [ ! -z $SSH_CONNECTION ]; then
    echo "do not run from ssh"
    exit 0
fi

source ~/.local/env/vars
if [ ! -e $IS_LOCAL ]; then
    exit 0
fi

MAILHOST=$LOCAL_SERVER
if [ ! -z "$1" ]; then
    case $1 in
        "new")
            curl -s http://$MAILHOST/files/mutt/new.txt
            ;;
    esac
    exit 0
fi

ssh $MAILHOST 2>&1 &
ssh -t $MAILHOST -- tmux attach -t $MUTT_SESSION
