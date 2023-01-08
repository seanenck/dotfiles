#!/usr/bin/env bash
[[ $- != *i* ]] && return

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
export GOPATH="$HOME/.cache/go"
export GOFLAGS="-trimpath -buildmode=pie -mod=readonly -modcacherw -buildvcs=false"
export DELTA_PAGER="less -c -X"
export PATH="$HOME/.bin/:$HOME/.cargo/bin:$PATH"
export LOCAL_STORE="$HOME/.store"
export PKGS_STORE="$LOCAL_STORE/pkgs"
export RPMS_STORE="$PKGS_STORE/rpms"

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

_toolbox-name(){
    local name
    if [ -f "/run/.toolboxenv" ]; then
        name=$(cat /run/.containerenv | grep -oP "(?<=name=\")[^\";]+")
        echo "$name"
    fi
}

_toolbox-prompt() {
    local name=$(_toolbox-name)
    if [ -n "$name" ]; then
        echo "[$name]"
    fi
}

TOOLBOX=$(_toolbox-name)
HOME_BASH="host"
if [ -n "$TOOLBOX" ]; then
    export TOOLBOX=$TOOLBOX
    export PATH="$HOME/.bin/$TOOLBOX:$PATH"
    HOME_BASH="$TOOLBOX"
else
    export PATH="$HOME/.bin/host:$PATH"
    unset $TOOLBOX
fi
for file in $(find $HOME/.config/voidedtech/bashrc.d -name "*.$HOME_BASH.sh"); do
    source $file
done
unset HOME_BASH

PS1="\$(_toolbox-prompt)\$(git-uncommitted --pwd 2>/dev/null)$PS1"

export SSH_AGENT_ENV="$XDG_RUNTIME_DIR/ssh-agent.env"
if [ ! -e "$SSH_AGENT_ENV" ] || ! pgrep ssh-agent > /dev/null; then
    pkill ssh-agent
    ssh-agent > "$SSH_AGENT_ENV"
fi
if [[ ! -f "$SSH_AUTH_SOCK" ]]; then
    source "$SSH_AGENT_ENV" >/dev/null
fi

for file in ".bashrc_local" ".bash_aliases" ".bash_completions"; do
    file="$HOME/$file"
    if [ -e "$file" ]; then
        source "$file"
    fi
done
unset file