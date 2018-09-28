PERSONAL := $(HOME)/store/documents/configs/
WEECHAT  := $(HOME)/.weechat/
SRCWEE   := $(PERSONAL/weechat/
PLUGINS  := autosort buffer_autoset
SERVICES := sync.timer sync.path maintain.timer
SYS_SERV := nftables systemd-networkd wsw
VIM_DIRS := "/.vim/{swap,undo}"

_check:
ifeq ($(shell whoami), root)
	$(error must not be run as root)
endif

all: _check update _setup services

_setup:
	mkdir -p $(HOME)/Downloads
	mkdir -p $(HOME)/.tmp
	mkdir -p $(HOME)$(VIM_DIRS)
	mkdir -p $(HOME)/.cache/dmenurls
	ln -sf $(PERSONAL)epiphyte.conf $(HOME)/.config/epiphyte/env
	ln -sf $(SRCWEE)buffer_autoset.conf $(WEECHAT)/buffer_autoset.conf
	ln -sf $(SRCWEE)irc.conf $(WEECHAT)irc.conf
	ln -sf $(PERSONAL)mail/msmtp $(HOME)/.msmtprc
	sudo rm -f /etc/vimrc
	sudo ln -s /home/enck/.vimrc /etc/vimrc
	sudo mkdir -p /etc/systemd/nspawn
	sudo timedatectl set-ntp true
	sudo mkdir -p /root$(VIM_DIRS)

services: $(SERVICES) $(SYS_SERV)

$(SYS_SERV):
	sudo systemctl enable $@

$(SERVICES):
	systemctl --user enable $@

update: _check $(PLUGINS)

$(PLUGINS):
	curl -s https://www.weechat.org/files/scripts/$@.py > $(WEECHAT)python/$@.py
