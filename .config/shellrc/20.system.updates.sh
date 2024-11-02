#!/bin/sh
sysupdate() {
  if command -v flatpak >/dev/null; then
    if ! flatpak update; then
      echo "flatpak update failed"
      return
    fi
  fi
  if command -v blap >/dev/null; then
    if ! blap upgrade --commit; then
      echo "blap updates failed"
      return
    fi
  fi
}
