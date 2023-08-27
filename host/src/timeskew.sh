#!/bin/bash
TIME_SOURCE="http://192.168.65.1:8989"

_run() {
  local lt rt delta is_daemon hr
  is_daemon=0
  if [ "$1" == "--daemon" ]; then
    is_daemon=1
  fi
  while : ; do
    hr=$(curl --silent "$TIME_SOURCE/hour")
    if [ -n "$hr" ]; then
      if [ "$hr" -gt 21 ] || [ "$hr" -lt 6 ]; then
        sleep 1800
      fi
    fi
    if [ "$is_daemon" -eq 1 ]; then
      sleep 10
    fi
    rt=$(curl --silent "$TIME_SOURCE/time")
    if [ -n "$rt" ] && [ "$rt" -eq "$rt" ] 2>/dev/null; then
      lt=$(date +%s)
      delta=0
    else
      echo "failed to get remote time"
      if [ "$is_daemon" -eq 1 ]; then
        sleep 5
        continue
      else
        return
      fi
    fi
    if [ "$lt" -gt "$rt" ]; then
      delta=$((lt-rt))
    else
      if [ "$rt" -gt "$lt" ]; then
        delta=$((rt-lt))
      fi
    fi
    if [ "$is_daemon" -eq 1 ]; then
      if [ "$delta" -gt 10 ]; then
        echo "delta detected, exceeds threshold: $delta (local: $lt, remote: $rt)"
        systemctl restart systemd-timesyncd
      fi
    else
      echo "delta: $delta, remote: $rt (hour: $hr), local: $lt"
      return
    fi
  done
}

if [ -n "$1" ]; then
  if [ "$1" == "--daemon" ]; then
    _run --daemon
    exit 0
  fi
  echo "unknown argument: $1"
  exit 1
fi
_run
