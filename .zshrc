autoload -Uz compinit && compinit
comps="$HOME/.local/share/zsh-completion/completions"
if [ -d "$comps" ]; then
  for file in "$comps/"*; do
    source "$file"
  done
fi

[ -d "$HOME/.local/bin" ] && path=("$HOME/.local/bin" $path)
export TERMINAL_EMULATOR="kitty"

export SECRET_ROOT="$HOME/Library/com.ttypty/secrets"
git -C "$SECRET_ROOT" pull >/dev/null 2>&1
[ -s "$SECRET_ROOT/secrets.env" ] && source "$SECRET_ROOT/secrets.env" && export SECRETS_ENV_FILE="$SECRET_ROOT/secrets.env"
export CFG_LB="darwin"

transcode-media() {
  "$HOME/.local/libexec/transcode-media"
}

vfu() {
  "$HOME/.local/libexec/vfu" $@
}

if [ -n "$KITTY_PID" ]; then
  ssh() {
    kitten ssh $@
    return
  }
fi

command -v dotfiles >/dev/null && dotfiles --check
command -v manage-data >/dev/null && manage-data motd
