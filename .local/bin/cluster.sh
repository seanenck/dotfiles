#!/bin/bash
SESSION=$(mktemp)
_session() {
    echo "layout grid"
    for i in $(seq 1 7); do
        echo "launch ssh cluster$i"
    done
}

_session > $SESSION
kitty --session $SESSION
rm -f $SESSION
