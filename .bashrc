#!/usr/bin/env bash
[[ $- != *i* ]] && return

export GOPATH="$HOME/.cache/go"
export DELTA_PAGER="less -c -X"
export PATH="$HOME/.bin/:$PATH"
source /etc/profile

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    exec sway 2>&1 | systemd-cat -t sway
    exit 0
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

