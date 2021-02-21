#!/bin/sh
branch="$(git rev-parse --abbrev-ref HEAD)"

if [ "$branch" = "master" ]; then
    echo "commits disabled"
    exit 1
fi
