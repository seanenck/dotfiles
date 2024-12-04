#!/bin/sh
if command -v delta > /dev/null; then
  export DELTA_PAGER="less -R -c -X"
fi
