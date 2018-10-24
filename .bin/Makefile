PERSONAL := $(HOME)/store/documents/
CONFS    := $(PERSONAL)configs/
SRCWEE   := $(PERSONAL)/weechat/
SYSD     := $(HOME)/.config/systemd/etc/
WEECHAT  := $(HOME)/.weechat/
PLUGINS  := autosort buffer_autoset
SERVICES := sync.timer sync.path maintain.timer
SYS_SERV := nftables systemd-networkd $(SYSD)wsw.path $(SYSD)wsw-monitor.path
VIM_DIRS := "/.vim/{swap,undo}"
SRCMAIL  := $(PERSONAL)mail/
WSW      := /var/cache/wsw/
WSW_FILE := network mon.pid

all: _check _setup services update

_check:
ifeq ($(shell whoami), root)
	$(error must not be run as root)
endif
	echo "ready..."

_setup:
	mkdir -p $(HOME)/downloads
	mkdir -p $(HOME)/.tmp
	mkdir -p $(HOME)$(VIM_DIRS)
	ln -sf $(CONFS)epiphyte.conf $(HOME)/.config/epiphyte/env
	ln -sf $(SRCWEE)buffer_autoset.conf $(WEECHAT)/buffer_autoset.conf
	ln -sf $(SRCWEE)irc.conf $(WEECHAT)irc.conf
	ln -sf $(SRCMAIL)/msmtp $(HOME)/.msmtprc
	ln -sf $(SRCMAIL)/mbsync.conf $(HOME)/.mbsyncrc
	ln -sf $(CONFS)serverlist $(HOME)/.podget/serverlist
	sudo ln -sf /home/enck/.vimrc /etc/vimrc
	sudo mkdir -p /etc/systemd/nspawn
	sudo timedatectl set-ntp true
	sudo mkdir -p /root$(VIM_DIRS)
	sudo ln -sf $(SYSD)wsw.service /etc/systemd/system/
	sudo ln -sf $(SYSD)wsw-monitor.service /etc/systemd/system/

services: $(SERVICES) $(SYS_SERV) $(WSW_FILE)

$(WSW_FILE):
	sudo install -Dm755 -d $(WSW)
	sudo touch $(WSW)$@
	sudo chmod 666 $(WSW)$@

$(SYS_SERV):
	sudo systemctl enable $@

$(SERVICES):
	systemctl --user enable $@

update: _check $(PLUGINS)

$(PLUGINS):
	curl -s https://www.weechat.org/files/scripts/$@.py > $(WEECHAT)python/$@.py
