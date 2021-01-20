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

START=/tmp/start_mail
if [ ! -e $START ]; then
    ssh $MAILHOST 2>&1 &
fi

ssh -t $MAILHOST -- perl $HOME/.mutt/mail.pl mutt
touch $START
