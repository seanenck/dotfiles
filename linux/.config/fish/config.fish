if status is-interactive
    set PATH $HOME/.local/bin $PATH
    set -U EDITOR nvim
    set -U VISUAL $EDITOR
    set -x DELTA_PAGER "less -c -X"
    set -x GOPATH "$HOME/.cache/go"
    set -x GOFLAGS "-ldflags=-linkmode=external -trimpath -buildmode=pie -mod=readonly -modcacherw -buildvcs=false"
    set -l state "$HOME/.local/state"
    mkdir -p "$state"
    set -l undos "$state/nvim/undo"
    if test -d "$undos"
        find "$undos" -type f -mmin +60 -delete
    end
    set -l lb_env "$HOME/git/secrets/.env/linux.vars"
    if test -e "$lb_env"
        source "$HOME/git/secrets/.env/linux.vars"
    end
    set -l ssh_agent_env "$state/ssh-agent.env"
    if ! pgrep -u "$USER" ssh-agent > /dev/null
        ssh-agent -c > "$ssh_agent_env"
    end
    set -x SSH_AUTH_SOCK "$state/ssh-agent.socket"
    if ! test -f "$SSH_AUTH_SOCKET"
        source "$ssh_agent_env" > /dev/null
    end
    for file in "$HOME/.ssh/"*.privkey
        ssh-add "$file" > /dev/null 2>&1
    end
    abbr -a cat bat
    abbr -a grep rg
    abbr -a vi $EDITOR
    abbr -a vim $EDITOR
    echo "disks"
    echo "==="
    df -h 2>/dev/null | grep '^/dev/vd' | awk '{printf "  %-10s %s\n", $1, $5}' | sort
    echo
    if ! git uncommitted --quiet
        echo "uncommitted"
        echo "==="
        git uncommitted | sed "s#$HOME/##g" | sed 's/^/  /g'
        echo
    end
end
