#!/usr/bin/env bash
[[ $- != *i* ]] && return
for dir in "$HOME/.config/profile.d/" "/etc/profile.d/" "$HOME/.bin/completions/"; do
    for file in $dir*; do
        if [ -e "$file" ]; then
            . "$file"
        fi
    done
done
unset file
unset dir
