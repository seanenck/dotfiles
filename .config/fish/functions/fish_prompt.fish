#!/usr/bin/env fish
function fish_prompt -d "Write out the prompt"
    printf '[%s%s@%s %s%s%s]> ' "$(git uncommitted pwd 2>/dev/null)" $USER (set_color purple)$(hostname | cut -d "." -f 1)(set_color normal) \
        (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
end
