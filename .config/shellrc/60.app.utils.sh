#!/bin/sh
if command -v delta > /dev/null; then
  export GIT_PAGER=delta
  export DELTA_PAGER="less -R -c -X"
fi
if command -v nvim > /dev/null; then
  find "$HOME/.local/state/nvim" -type f -mtime +1 -delete
fi
