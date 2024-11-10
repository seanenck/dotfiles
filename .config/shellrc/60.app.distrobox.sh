#!/bin/sh
if [ "$DISTROBOX_ENTER_PATH" != "" ]; then
  if [ -z "$DBX_SKIP_WORKDIR" ]; then
    echo "suggested distrobox configuration env vars:"
    echo
    echo "export DBX_SKIP_WORKDIR=1"
    echo
  fi  
fi
