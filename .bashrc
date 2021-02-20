[[ $- != *i* ]] && return

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth:erasedups

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=-1
HISTFILESIZE=-1

export VISUAL=vim
export EDITOR="$VISUAL"
export LESSHISTFILE=$HOME/.cache/lesshst

PS1='[\u@\h \W]\$ '

for file in $HOME/.local/env/vars \
            /etc/voidedtech/skel/bash_aliases \
            $HOME/.local/private/etc/env \
            /usr/share/bash-completion/bash_completion \
            $HOME/.config/user-dirs.dirs; do
    if [ -e $file ]; then
        . $file
    fi
done

. /etc/profile
if [ -x /usr/bin/sway ]; then
    if [ -z $DISPLAY ] && [ "$(tty)" == "/dev/tty1" ]; then
        export MOZ_ENABLE_WAYLAND=1
        sway > ~/.cache/sway.log 2>&1
        exit
    fi
fi

# check the window size after each command
shopt -s checkwinsize

if [ $IS_DEV -eq 1 ]; then
    source ~/.local/env/devrc
else
    hook=~/.git/hooks/pre-commit
    if [ ! -e $hook ]; then
        cp ~/.local/lib/no-commit.sh $hook
        chmod u+x $hook
    fi
fi

if [ -e $IS_MAIL ]; then
    for f in $(ls $HOME/.local/env/mail*); do
        source $f
    done
fi
if [ -x /usr/bin/drudge ]; then
    drudge motd.highlight
fi
