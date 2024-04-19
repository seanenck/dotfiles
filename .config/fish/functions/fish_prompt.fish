#!/usr/bin/env fish
function fish_prompt -d "Write out the prompt"
    set -f display $hostname
    if test -e "$HOME/.host"
        set -f display $(cat "$HOME/.host")
    end
    set -f usepwd $(basename (prompt_pwd))
    printf '[%s%s@%s %s%s%s]> ' "$(git uncommitted --pwd 2>/dev/null)" $USER (set_color purple)$display(set_color normal) \
        (set_color $fish_color_cwd) $usepwd (set_color normal)
end
