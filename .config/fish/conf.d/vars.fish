fish_add_path -gP "$HOME/.local/bin";
set -U EDITOR nvim
set -U VISUAL $EDITOR
set -x DELTA_PAGER "less -c -X"
set -x GOPATH "$HOME/Library/Go"
set -x GOFLAGS "-ldflags=-linkmode=external -trimpath -buildmode=pie -mod=readonly -modcacherw -buildvcs=false"
