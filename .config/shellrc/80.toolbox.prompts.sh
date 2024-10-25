#!/bin/sh
FILE="/run/.containerenv"
if [ -e "$FILE" ]; then
  export CONTAINER_NAME="$(grep "name=" "$FILE" | sed 's/"//g' | cut -d "=" -f 2)"
fi
unset FILE
