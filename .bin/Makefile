all:
ifeq ($(shell whoami), root)
	$(error must not be run as root)
endif
	mkdir -p $(HOME)/Downloads
	mkdir -p $(HOME)/.tmp
	mkdir -p $(HOME)/.vim/swap
	mkdir -p $(HOME)/.vim/undo
	mkdir -p $(HOME)/.cache/dmenurls
	ln -sf $(HOME)/.synced/configs/epiphyte.conf $(HOME)/.config/epiphyte/env
	sudo rm -f /etc/vimrc
	sudo ln -s /home/enck/.vimrc /etc/vimrc
	sudo ln -sf /home/enck/.bin/locking /usr/local/bin/locking
	sudo mkdir -p /etc/systemd/nspawn
	sudo timedatectl set-ntp true
	sudo systemctl enable nftables
