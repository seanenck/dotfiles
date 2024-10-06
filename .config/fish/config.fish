set -g EDITOR nvim
set -g VISUAL $EDITOR
set -x DELTA_PAGER "less -c -X"
set -l local_bin "$HOME/.local/bin"

if test -d "$local_bin"
    fish_add_path -gP "$local_bin";
end

set -gx HOMEBREW_PREFIX "/opt/homebrew";
set -gx HOMEBREW_CELLAR "/opt/homebrew/Cellar";
set -gx HOMEBREW_REPOSITORY "/opt/homebrew";
fish_add_path -gP "/opt/homebrew/bin" "/opt/homebrew/sbin";
! set -q MANPATH; and set MANPATH ''; set -gx MANPATH "/opt/homebrew/share/man" $MANPATH;
! set -q INFOPATH; and set INFOPATH ''; set -gx INFOPATH "/opt/homebrew/share/info" $INFOPATH;

set -l state "$HOME/.local/state"
mkdir -p "$state"
set -l undos "$state/nvim/undo"
if test -d "$undos"
    find "$undos" -type f -mmin +60 -delete
end

set -x GOPATH "$HOME/Library/go"
fish_add_path -gP "$GOPATH/bin"
set -x GOFLAGS "-ldflags=-linkmode=external -trimpath -buildmode=pie -mod=readonly -modcacherw -buildvcs=false"

set -f bat bat
set -gx ENABLE_LSP 1
set -g -x SECRET_ROOT "$HOME/Env/secrets"
set -l lb_env "$SECRET_ROOT/db/lockbox.fish"
if test -e "$lb_env"
    source "$lb_env"
end


for file in "$HOME/.config/fish/env/"*
    source "$file"
end

if status is-interactive
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

    caffeinate task-runner

    abbr -a cat $bat
    abbr -a grep rg
    abbr -a vi $EDITOR
    abbr -a vim $EDITOR
    abbr -a nano $EDITOR

    set -g fish_autosuggestion_enabled 0
    set fish_greeting
    git-uncommitted --motd
end
