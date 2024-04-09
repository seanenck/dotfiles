FROM registry.fedoraproject.org/fedora-toolbox:39

RUN dnf update -y && dnf upgrade -y
RUN dnf install -y \
    bat \
    fish \
    git \
    git-delta \
    make \
    neovim \
    ripgrep \
    kitty-terminfo
