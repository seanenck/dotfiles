#!/usr/bin/env bash
[[ $- != *i* ]] && return

export GOPATH="$HOME/.cache/go"
export XDG_RUNTIME_DIR=/tmp/$(id -u)-runtimedir
export DELTA_PAGER="less -c -X"
export PATH="$HOME/.bin/:$PATH"

if [ ! -d $XDG_RUNTIME_DIR ]; then
    mkdir $XDG_RUNTIME_DIR
    chmod 0700 $XDG_RUNTIME_DIR
fi
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    exec dbus-launch --exit-with-session sway > $HOME/.cache/sway.log 2>&1 
fi

PS1="\$(git-uncommitted --pwd 2>/dev/null)$PS1"

SSH_AGENT_ENV="$XDG_RUNTIME_DIR/ssh-agent.env"
if ! pgrep ssh-agent > /dev/null; then
    ssh-agent > "$SSH_AGENT_ENV"
fi
if [[ ! -f "$SSH_AUTH_SOCK" ]]; then
    source "$SSH_AGENT_ENV" >/dev/null
fi

for file in ".abuild/abuild.conf" ".bashrc_local" ".bash_aliases" ".bash_completions"; do
    file="$HOME/$file"
    if [ -e "$file" ]; then
        source "$file"
    fi
done
unset file

_not-pushed() {
    if ! git uncommitted --quiet; then
        echo
        echo "uncommitted:"
        git uncommitted | cut -d " " -f 1 | sort -u | sed "s#$HOME/##g" | sed 's/^/  -> /g'
        echo
    fi
}
_not-pushed

