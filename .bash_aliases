#!/usr/bin/env bash
alias cat=bat
alias diff="diff -u"
alias ls='ls --color=auto'
alias grep="rg"
alias vi=$EDITOR
alias vim=$EDITOR
alias hx=$EDITOR
alias scp="rsync"

if [ -n "$TOOLBOX" ] && [ "$TOOLBOX" == "dev" ]; then
goimports() {
    gopls format $@
}

gomod-update() {
    go get -u ./...
    go mod tidy
}
fi

advantage360() {
	local cache
	cache="$HOME/.cache/adv360"
	if [ ! -d "$cache" ]; then
		if ! git clone https://github.com/enckse/Adv360-Pro-ZMK $cache; then
			return
		fi
	fi
	if ! git -C "$cache" fetch; then
		return
	fi
	if ! git -C "$cache" pull; then
		return
	fi
	git -C "$cache" diff 0fb8e5824fee2fb11f263de745f5b1c0efbcd78a > $HOME/.config/adv360/mappings.patch
}
