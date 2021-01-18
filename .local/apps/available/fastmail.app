#!/bin/bash
perl $HOME/.local/bin/mail.pl sync &
kitty --start-as=maximized --title=fastmail -d=$HOME/downloads /usr/bin/mutt -F $HOME/.mutt/fastmail.muttrc
