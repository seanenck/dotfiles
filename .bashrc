#!/usr/bin/env bash
[[ $- != *i* ]] && return
for file in $HOME/.config/bash/*; do
    if [ -e "$file" ]; then
        . "$file"
    fi
done
