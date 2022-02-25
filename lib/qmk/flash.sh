read -p "ready to flash? (y/N) " yesno
if [ "$yesno" != "y" ]; then
    exit 1
fi
