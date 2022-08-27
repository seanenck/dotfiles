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
export PAGER=less
export COMP_KNOWN_HOSTS_WITH_HOSTFILE=""

. /etc/profile
for file in $HOME/.machine/bashrc \
            $HOME/.bash_aliases \
            $HOME/.machine/bash_aliases \
            $HOME/.machine/bash_completions \
            /usr/share/bash-completion/bash_completion; do
    if [ -e "$file" ]; then
        . "$file"
    fi
done

export TERM=xterm-256color
PREFERPS1="(\u@\h \W)"
if [ -z "$SSH_CONNECTION" ]; then
    PS1=$PREFERPS1'$ '
else
    PS1='\[\033[01;33m\]'$PREFERPS1'\[\033[0m\]> '
fi

_vimclean() {
    local h
    h=$HOME/.vim/$f
    if [ -d "$h" ]; then
        find "$h" -type f -mtime +1 -delete
    fi
}
_vimclean undo
_vimclean swap
_vimclean backup

# check the window size after each command
shopt -s checkwinsize
