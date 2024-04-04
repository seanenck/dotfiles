if status is-interactive
    set -g EDITOR nvim
    set -g VISUAL $EDITOR
    set -x SECRETS "$HOME/Git/secrets"
    set -l state "$HOME/.local/state"
    mkdir -p "$state"
    set -l undos "$state/nvim/undo"
    if test -d "$undos"
        find "$undos" -type f -mmin +60 -delete
    end
    set -l lb_env "$SECRETS/src/lockbox.fish"
    if test -e "$lb_env"
        source "$lb_env"
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
    abbr -a nano $EDITOR

    set -g fish_autosuggestion_enabled 0
    set fish_greeting
    set -x DELTA_PAGER "less -c -X"

    fish_add_path -gP "$HOME/.local/bin";
    if set -q TOOLBOX_PATH
        if test -x /usr/bin/go
            fish_add_path -gP "$HOME/.cache/go/bin";
            set -x GOPATH "$HOME/.cache/go"
            set -x GOFLAGS "-ldflags=-linkmode=external -trimpath -buildmode=pie -mod=readonly -modcacherw -buildvcs=false"
        end
    end
    voidedtech startup
end
