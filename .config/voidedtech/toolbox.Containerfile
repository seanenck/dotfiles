FROM registry.fedoraproject.org/fedora-toolbox:39

RUN dnf install -y \
    bat \
    fish \
    git \
    git-delta \
    make \
    neovim \
    ripgrep \
    kitty-terminfo
