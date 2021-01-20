#!/bin/bash
if [ ! -z $SSH_CONNECTION ]; then
    echo "do not run from ssh"
    exit 0
fi

source ~/.variables
if [ ! -e $IS_LOCAL ]; then
    exit 0
fi

MAILHOST=$SERVER
if [ ! -z "$1" ]; then
    case $1 in
        "new")
            curl -s http://$MAILHOST/files/mutt/new.txt
            ;;
    esac
    exit 0
fi

ssh -t $MAILHOST -- tmux attach -t mutt
