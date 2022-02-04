#!/usr/bin/env bash
[[ $- != *i* ]] && return

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth:erasedups

# append to the history file, don't overwrite it
shopt -s histappend
shopt -s direxpand

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=-1
HISTFILESIZE=-1

export VISUAL=vim
export EDITOR="$VISUAL"
export LESSHISTFILE=$HOME/.cache/lesshst
export TERM=xterm-256color
export PAGER=less
export COMP_KNOWN_HOSTS_WITH_HOSTFILE=""

. /etc/profile
for file in $HOME/.bashrc_local \
            $HOME/.machine/bashrc \
            $HOME/.bash_aliases \
            $HOME/.machine/bash_aliases \
            /usr/share/bash-completion/bash_completion; do
    if [ -e "$file" ]; then
        . "$file"
    fi
done

PREFERPS1="\u@\h \W"
if [ -z "$SSH_CONNECTION" ]; then
    PS1='['$PREFERPS1']$ '
else
    PS1='('$PREFERPS1')> '
fi

for f in .vim/undo .vim/swap .vim/backup; do
    h=$HOME/$f
    if [ -d "$h" ]; then
        find "$h" -type f -mtime +1 -delete
    fi
done

# check the window size after each command
shopt -s checkwinsize
