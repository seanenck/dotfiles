fish_add_path -gP "$HOME/.local/bin";
set -U EDITOR nvim
set -U VISUAL $EDITOR
set -x DELTA_PAGER "less -c -X"
switch (uname)
    case Darwin
        set -x GOPATH "$HOME/Library/Go"
    case Linux
        set -x GOPATH "$HOME/.cache/go"
end
set -x GOFLAGS "-ldflags=-linkmode=external -trimpath -buildmode=pie -mod=readonly -modcacherw -buildvcs=false"
set -x SECRETS "$HOME/Git/secrets"
