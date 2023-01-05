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
if [ -n "$TOOLBOX" ]; then
    export $TOOLBOX
    export PATH="$HOME/.bin/toolbox-$TOOLBOX:$PATH"
else
    export PATH="$HOME/.bin/host:$PATH"
    unset $TOOLBOX
fi

PS1="\$(_toolbox-prompt)\$(git-uncommitted --pwd 2>/dev/null)$PS1"

SESSIONS="$HOME/.cache/sessions/"
export SESSION_LOCAL_ENV="$SESSIONS/$(cat  /proc/sys/kernel/random/boot_id).env"

if [ ! -d "$SESSIONS" ]; then
    mkdir -p "$SESSIONS"
fi

HAS_LOCAL_SESSION=0
if [ ! -e "$SESSION_LOCAL_ENV" ]; then
  if [ -z "$SSH_CONNECTION" ]; then
    rm -f $SESSIONS*    
    echo "export XDG_RUNTIME_DIR='$XDG_RUNTIME_DIR'" > "$SESSION_LOCAL_ENV" 
  fi
fi
if [ -e "$SESSION_LOCAL_ENV" ]; then
    source "$SESSION_LOCAL_ENV"
    export SSH_AGENT_ENV="$XDG_RUNTIME_DIR/ssh-agent.env"
    if [ ! -e "$SSH_AGENT_ENV" ] || ! pgrep ssh-agent > /dev/null; then
        pkill ssh-agent
        ssh-agent > "$SSH_AGENT_ENV"
    fi
    if [[ ! -f "$SSH_AUTH_SOCK" ]]; then
        source "$SSH_AGENT_ENV" >/dev/null
    fi
    HAS_LOCAL_SESSION=1
fi
export HAS_LOCAL_SESSION

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
