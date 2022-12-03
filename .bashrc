#!/usr/bin/env bash
[[ $- != *i* ]] && return
for file in $HOME/.config/profile.d/*; do
    if [ -e "$file" ]; then
        . "$file"
    fi
done
for file in /etc/profile.d/*; do
    if [ -e "$file" ]; then
        . "$file"
    fi
done
unset file
