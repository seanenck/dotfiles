#!/usr/bin/env fish
function fish_prompt -d "Write out the prompt"
    set -f display $hostname
    if test -e /run/.containerenv
        set -f display $(cat /run/.containerenv | grep '^name=' | cut -d "=" -f 2 | sed 's/"//g')
    end
    set -f usepwd $(basename (prompt_pwd))
    printf '[%s %s@%s %s%s%s]> ' (__fish_git_prompt) $USER (set_color purple)$display(set_color normal) \
        (set_color $fish_color_cwd) $usepwd (set_color normal)
end
