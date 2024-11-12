#!/bin/sh
FOUND=0
for TERMINAL in kitty alacritty wezterm foot; do
  if command -v "$TERMINAL" > /dev/null; then
    FOUND=1
    export TERMINAL_EMULATOR="$TERMINAL"
    break
  fi
done
if [ -n "$DESKTOP_SESSION" ] && [ "$DESKTOP_SESSION" = "sway" ]; then
  if [ "$FOUND" -eq 1 ]; then
    echo "$TERMINAL_EMULATOR" > "$HOME/.local/state/terminal"
  else 
    echo "unable to set terminal, unknown type/not found?"
  fi
fi
unset FOUND
