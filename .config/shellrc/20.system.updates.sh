#!/bin/sh
COMMANDS=""
for ITEM in flatpak blap; do
  if command -v "$ITEM" >/dev/null; then
    COMMANDS="$COMMANDS $ITEM"
  fi
done
if [ -n "$COMMANDS" ]; then
  sysupdate() {
    for cmd in $COMMANDS; do
      case "$cmd" in
        "flatpak")
          if ! flatpak update; then
            echo "flatpak update failed"
            return
          fi
          ;;
        "blap")
          if ! blap upgrade --commit; then
            echo "blap updates failed"
            return
          fi
          ;;
      esac
    done
  }
fi
unset ITEM
