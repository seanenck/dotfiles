[[ $- != *i* ]] && return

for file in $HOME/.local/env/vars \
            /etc/voidedtech/bash/bashrc \
            /etc/voidedtech/bash/aliases \
            $HOME/.local/private/etc/env \
            /usr/share/bash-completion/bash_completion \
            $HOME/.config/user-dirs.dirs; do
    if [ -e $file ]; then
        . $file
    fi
done

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

motd
