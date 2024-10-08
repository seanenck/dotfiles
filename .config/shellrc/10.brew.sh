#!/usr/bin/env bash
if [ -d "/opt/homebrew" ]; then
  export HOMEBREW_PREFIX="/opt/homebrew";
  export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
  export HOMEBREW_REPOSITORY="/opt/homebrew";
  export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:";
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}";
  export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}";
fi
