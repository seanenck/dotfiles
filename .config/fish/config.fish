set -g EDITOR nvim
set -g VISUAL $EDITOR
set -x DELTA_PAGER "less -c -X"
set -l local_bin "$HOME/.local/bin"

if test -d "$local_bin"
    fish_add_path -gP "$local_bin";
end

set -l state "$HOME/.local/state"
mkdir -p "$state"
set -l undos "$state/nvim/undo"
if test -d "$undos"
    find "$undos" -type f -mmin +60 -delete
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

    abbr -a cat $bat
    abbr -a grep rg
    abbr -a vi $EDITOR
    abbr -a vim $EDITOR
    abbr -a nano $EDITOR

    set -g fish_autosuggestion_enabled 0
    set fish_greeting
    git-uncommitted --motd
end
