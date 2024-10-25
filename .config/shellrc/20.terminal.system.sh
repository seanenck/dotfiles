#!/bin/sh
export TERMINAL_FILE="$HOME/.local/state/terminal"
if [ ! -e "$TERMINAL_FILE" ]; then
  FOUND=0
  for TERMINAL in kitty alacritty wezterm foot; do
    if command -v "$TERMINAL" > /dev/null; then
      FOUND=1
      echo "$TERMINAL" > "$TERMINAL_FILE"
      break
    fi
  done
  if [ "$FOUND" -eq 0 ]; then
    echo "unable to set terminal, unknown type/not found?"
  fi
  unset TERMINAL
fi
