#!/bin/sh
source resume.env
make ADDRESS="$ADDRESS" PHONE="$PHONE" EMAIL="$EMAIL"
test -s bin/resume.pdf || exit 1
if ! mv bin/resume.pdf /opt/$1.pdf; then
    exit 1
fi
exit 0
