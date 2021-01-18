#!/bin/bash
$HOME/.local/bin/sys mail &
kitty --start-as=maximized --title=fastmail -d=$HOME/downloads /usr/bin/mutt -F $HOME/.mutt/fastmail.muttrc
