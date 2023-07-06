#!/usr/bin/env bash
PIDFILE="/run/timeskew.pid"

_datetime() {
  date | cut -d " " -f 2- | rev | cut -d " " -f 3- | rev
}

_daemon() {
  local dt pid cur
  dt=$(_datetime)
  pid="$$"
  echo "$pid" > $PIDFILE
  while : ; do
    if [ ! -e "$PIDFILE" ]; then
      return
    fi
    cur=$(cat "$PIDFILE")
    if [ "$cur" != "$pid" ]; then
      return
    fi
    sleep 1
    if awk "\$0>=\"$dt\"" < /var/log/messages | grep -q "WARNING: clock skew detected"; then
      echo "skew detected, restarting chronyd"
      pkill chronyd
      if ! rc-service chronyd restart; then
        continue
      fi
    fi
    dt=$(_datetime)
  done
}

_daemon &
