#!/usr/bin/env bash
if ! git uncommitted --quiet; then
  echo
  echo "uncommitted:"
  git uncommitted | cut -d " " -f 1 | sort -u | sed "s#$HOME/##g" | sed 's/^/  -> /g'
  echo
fi

_backups() {
  systemctl start --user backups
  if data-sync --check; then
    return
  fi
  echo
  echo "backups:"
  echo "  -> backup issues"
  echo
}

neovim-plugins() {
  make -C "$HOME/.config/nvim" | grep -v '^make'
}

_backups
