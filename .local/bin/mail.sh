#!/bin/bash
if [ ! -z $SSH_CONNECTION ]; then
    echo "do not run from ssh"
    exit 0
fi

source ~/.variables
MAILHOST=$SERVER
ping -c1 -w5 $MAILHOST > /dev/null 2>&1
if [ $? -ne 0 ]; then
    exit 0;
fi

IMAP="/home/fastmail/imap/fastmail/"
if [ ! -z "$1" ]; then
    case $1 in
        "new")
            curl -s http://$MAILHOST/files/mutt/new.txt
            ;;
    esac
    exit 0
fi

ssh fastmail@$MAILHOST
