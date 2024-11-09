#!/bin/sh
if [ -n "$XDG_CURRENT_DESKTOP" ]; then
  FOUND=0
  for TERMINAL in kitty alacritty wezterm foot; do
    if command -v "$TERMINAL" > /dev/null; then
      FOUND=1
      export TERMINAL_EMULATOR="$TERMINAL"
      break
    fi
  done
  if [ "$FOUND" -eq 0 ]; then
    echo "unable to set terminal, unknown type/not found?"
  fi
fi
