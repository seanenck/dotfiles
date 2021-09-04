#!/usr/bin/env bash
if [ -z "$AUTOMATED" ]; then
    [[ $- != *i* ]] && return
fi

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth:erasedups

# append to the history file, don't overwrite it
shopt -s histappend

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
            $HOME/.bash_aliases \
            /usr/share/bash-completion/bash_completion; do
    if [ -e $file ]; then
        . $file
    fi
done

PS1='[\u@\h \W]\$ '

for f in .vim/undo .vim/swap .vim/backup; do
    h=$HOME/$f
    if [ -d $h ]; then
        find $h -type f -mtime +1 -delete
    fi
done

# check the window size after each command
shopt -s checkwinsize
