# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.bin" ] ; then
    PATH="$HOME/.bin:$PATH"
    if [ -d "$HOME/.cache/dmenu_urls" ]; then
        PATH="$HOME/.cache/dmenu_urls:$PATH"
    fi
    if [ -d "$HOME/.cache/helper_cache" ]; then
        PATH="$HOME/.cache/helper_cache:$PATH"
    fi
fi
