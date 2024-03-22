#!/bin/sh
for f in coreutils findutils make gnu-sed; do
  export PATH="/opt/homebrew/opt/$f/libexec/gnubin:$PATH"
done
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}";
