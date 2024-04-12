set -g EDITOR nvim
set -g VISUAL $EDITOR
set -x SECRETS "$HOME/Env/secrets"
set -x DELTA_PAGER "less -c -X"
set -l local_bin "$HOME/.local/bin"

if test -e /run/.containerenv
    switch (cat /run/.containerenv | grep "^name=" | cut -d "=" -f 2- | sed 's/"//g')
        case go
            fish_add_path -gP "$HOME/.cache/go/bin";
            set -x GOPATH "$HOME/.cache/go"
            set -x GOFLAGS "-ldflags=-linkmode=external -trimpath -buildmode=pie -mod=readonly -modcacherw -buildvcs=false"
    end
else
    if test -d "$local_bin"
        fish_add_path -gP "$local_bin";
    end
    if test -x "$local_bin/voidedtech"
        set -f do_startup 1
    end
end

for file in "$HOME/.config/fish/env/"*
    source "$file"
end

if status is-interactive
    set -l state "$HOME/.local/state"
    mkdir -p "$state"
    set -l undos "$state/nvim/undo"
    if test -d "$undos"
        find "$undos" -type f -mmin +60 -delete
    end
    set -l lb_env "$SECRETS/db/lockbox.fish"
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

    echo "disks"
    echo "==="
    df -h /dev/mapper/* | grep '^/' | awk '{printf "  %-20s %s\n", $6, $5}' | sort
    git-uncommitted | sed "s#$HOME/##g" | sed 's/^/  /g' | sed '1 i\\\nuncommitted\n==='
    echo

    if set -q do_startup
        voidedtech startup
    end
end
