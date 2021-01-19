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

SSHMAIL="fastmail@$MAILHOST"
IMAP="/home/fastmail/imap/fastmail/"
if [ ! -z "$1" ]; then
    case $1 in
        "new")
            ssh $SSHMAIL -- find $IMAP -type f -path '*/new/*' | grep -v Trash | rev | cut -d '/' -f 3- | rev | sort | sed "s#$IMAP##g"
            ;;
    esac
    exit 0
fi

ssh -t $SSHMAIL /usr/bin/mutt -F /home/fastmail/.mutt/fastmail.muttrc
