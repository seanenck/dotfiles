[[ $- != *i* ]] && return

for file in $HOME/.variables \
            /etc/voidedtech/bash/bashrc \
            /etc/voidedtech/bash/aliases \
            $HOME/.config/private/etc/private.exports \
            /usr/share/bash-completion/bash_completion \
            $HOME/.config/user-dirs.dirs; do
    if [ -e $file ]; then
        . $file
    fi
done

# check the window size after each command
shopt -s checkwinsize

if [ -e $IS_LAPTOP ] || [ -e $IS_DESKTOP ]; then
    for f in $(ls $HOME/.local/env/dev*); do
        source $f
    done
fi

if [ -e $IS_MAIL ]; then
    for f in $(ls $HOME/.local/env/mail*); do
        source $f
    done
fi
