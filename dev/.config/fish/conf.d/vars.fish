set PATH $HOME/.local/bin $PATH
set -U EDITOR nvim
set -U VISUAL $EDITOR
set -x DELTA_PAGER "less -c -X"
set -x GOPATH "$HOME/Library/go"
set -x GOFLAGS "-ldflags=-linkmode=external -trimpath -buildmode=pie -mod=readonly -modcacherw -buildvcs=false"
set -x DOTFILES_PROFILE dev 
