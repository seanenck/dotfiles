#!/usr/bin/env bash
[[ $- != *i* ]] && return

export GOPATH="$HOME/.cache/go"
export GOFLAGS="-trimpath -buildmode=pie -mod=readonly -modcacherw -buildvcs=false"
export DELTA_PAGER="less -c -X"
export PATH="$HOME/.bin/:$HOME/.cargo/bin:$PATH"
. /etc/bashrc

HISTCONTROL=ignoreboth:erasedups

shopt -s histappend
shopt -s direxpand

HISTSIZE=-1
HISTFILESIZE=-1

export VISUAL=hx
export EDITOR="$VISUAL"
export LESSHISTFILE=$HOME/.cache/lesshst
export COMP_KNOWN_HOSTS_WITH_HOSTFILE=""
export TERM=xterm-256color
PREFERPS1="(\u@\h \W)"
if [ -z "$SSH_CONNECTION" ]; then
    PS1=$PREFERPS1'$ '
else
    PS1='\[\033[01;33m\]'$PREFERPS1'\[\033[0m\]> '
fi

# disable ctrl+s
stty -ixon

# check the window size after each command
shopt -s checkwinsize

alias diff="diff -u"
alias ls='ls --color=auto'
alias grep="rg"
alias vi=$EDITOR
alias vim=$EDITOR
alias hx=$EDITOR
PS1="\$(git-uncommitted --pwd 2>/dev/null)$PS1"

for file in ".bashrc_local" ".bash_aliases" ".bash_completions"; do
    file="$HOME/$file"
    if [ -e "$file" ]; then
        source "$file"
    fi
done
for dir in .completions; do
    dir="$HOME/$dir"
    if [ -d "$dir" ]; then
        for file in $(ls $dir); do
            source "$dir/$file"
	done
    fi
done
unset file
unset dir

if [ -n "$SSH_CONNECTION" ]; then
    export LOCKBOX_CLIP_OSC52=yes
fi

_not-pushed() {
    if ! git uncommitted --quiet; then
        echo
        echo "uncommitted:"
        git uncommitted | cut -d " " -f 1 | sort -u | sed "s#$HOME/##g" | sed 's/^/  -> /g'
        echo
    fi
}
_not-pushed
