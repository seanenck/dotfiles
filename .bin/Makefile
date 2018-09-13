PERSONAL=$(HOME)/.config/personal/
WEECHAT=$(HOME)/.weechat/
all:
ifeq ($(shell whoami), root)
	$(error must not be run as root)
endif
	mkdir -p $(HOME)/Downloads
	mkdir -p $(HOME)/.tmp
	mkdir -p $(HOME)/.vim/swap
	mkdir -p $(HOME)/.vim/undo
	mkdir -p $(HOME)/.cache/dmenurls
	ln -sf $(PERSONAL)epiphyte.conf $(HOME)/.config/epiphyte/env
	ln -sf $(PERSONAL)buffer_autoset.conf $(WEECHAT)/buffer_autoset.conf
	ln -sf $(PERSONAL)weechat.irc.conf $(WEECHAT)irc.conf
	ln -sf $(HOME)/.synced/msmtp $(HOME)/.msmtprc
	sudo rm -f /etc/vimrc
	sudo ln -s /home/enck/.vimrc /etc/vimrc
	sudo mkdir -p /etc/systemd/nspawn
	sudo timedatectl set-ntp true
	sudo systemctl enable nftables
