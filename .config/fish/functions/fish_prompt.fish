#!/usr/bin/env fish
function fish_prompt -d "Write out the prompt"
    set -f usepwd $(basename (prompt_pwd))
    printf '[%s%s@%s %s%s%s]> ' "$(git uncommitted --pwd 2>/dev/null)" $USER (set_color blue)$hostname(set_color normal) \
        (set_color $fish_color_cwd) $usepwd (set_color normal)
end
