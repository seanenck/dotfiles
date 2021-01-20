#!/bin/bash
SCRIPT=$1
if [ -z "$SCRIPT" ]; then
    echo "script required"
    exit 1
fi
SCRIPT="$HOME/.local/bin/$SCRIPT.pl"
if [ ! -e "$SCRIPT" ]; then
    echo "invalid script: $SCRIPT"
    exit 1
fi
perl $SCRIPT
