#!/usr/bin/env bash
[[ $- != *i* ]] && return
for file in $HOME/.config/profile.d/*; do
    if [ -e "$file" ]; then
        . "$file"
    fi
done
PS1="\$(git-uncommitted --pwd 2>/dev/null)$PS1"
unset file
