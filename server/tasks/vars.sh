#!/bin/sh
export PATH="/opt/homebrew/bin:$HOME/.local/bin:$PATH"
for f in coreutils findutils make gnu-sed; do
  export PATH="/opt/homebrew/opt/$f/libexec/gnubin:$PATH"
done
