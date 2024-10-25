#!/bin/sh
export TERMINAL_FILE="$HOME/.local/state/terminal"
if [ ! -e "$TERMINAL_FILE" ]; then
  for TERMINAL in kitty alacritty wezterm foot; do
    if command -v "$TERMINAL" > /dev/null; then
      echo "$TERMINAL" > "$TERMINAL_FILE"
      break
    fi
  done
  unset TERMINAL
fi
