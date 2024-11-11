#!/bin/sh
if [ -n "$DESKTOP_SESSION" ] && [ "$DESKTOP_SESSION" = "sway" ]; then
  FOUND=0
  for TERMINAL in kitty alacritty wezterm foot; do
    if command -v "$TERMINAL" > /dev/null; then
      FOUND=1
      export TERMINAL_EMULATOR="$TERMINAL"
      echo "$TERMINAL" > "$HOME/.local/state/terminal"
      break
    fi
  done
  if [ "$FOUND" -eq 0 ]; then
    echo "unable to set terminal, unknown type/not found?"
  fi
fi
