#!/usr/bin/env bash
alias cat=bat

goimports() {
    gopls format $@
}

gomod-update() {
    go get -u ./...
    go mod tidy
}

adv360() {
    local bin cache patch target
    bin=$(mktemp -d)
    cache=$HOME/.cache/adv360
    if [ ! -d $cache ]; then
        git clone https://github.com/KinesisCorporation/Adv360-Pro-ZMK $cache
        git -C $cache checkout V2.0
    fi
    git -C "$cache" pull
    cp -r "$cache" "$bin"
    patch=$HOME/.config/adv360/keys.patch
    target=$bin/adv360
    if ! (cd $target && patch -p1 < $patch); then
        echo "patch failed"
        exit 1
    fi
    if ! (cd $target && make all); then
        echo "build failed"
        exit 1
    fi
    cp $target/firmware/* $HOME/downloads/
    rm -rf $bin
}