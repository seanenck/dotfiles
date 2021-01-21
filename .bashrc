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

if [ -e $IS_LAPTOP ] || [ -e $IS_DESKTOP ]; then
    for f in dev_aliases dev_completions devrc; do
        source ~/.local/env/$f
    done
fi

if [ -e $IS_MAIL ]; then
    for f in $(ls $HOME/.local/env/mail*); do
        source $f
    done
fi
