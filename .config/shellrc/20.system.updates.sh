#!/bin/sh
HAS=0
for ITEM in flatpak blap; do
  if command -v "$ITEM" >/dev/null; then
    HAS=1
    break
  fi
done
if [ "$HAS" -eq 1 ]; then
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
fi
unset HAS ITEM
