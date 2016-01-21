define IPTABLES_RULES
# This file was created automatically
# All changed need to be pushed back into the configuration
*filter
:INPUT DROP [11:1508]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [219:35101]
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
COMMIT
endef

define IPTABLES_SETUP
#!/bin/sh
/sbin/iptables-restore < /etc/iptables.rules
endef

export IPTABLES_RULES
export IPTABLES_SETUP

package_list = alsa-utils chromium cryptsetup debootstrap feh firmware-iwlwifi gawk git i3 i3lock i3status iptables keepass2 lxterminal p7zip pandoc pm-utils screen systemd-container unzip vim vim-youcompleteme wicd wireless-tools wpasupplicant xautolock xbacklight xdm xorg
iptables_rule = /etc/iptables.rules
iptables_setup = /etc/network/if-pre-up.d/iptables
ssh_config = $(HOME)/.ssh/config
auto_home = $(HOME)/.bin/autocomplete/
bash_auto = /etc/bash_completed.d/

all: clean install

install:
		sudo apt-get install $(package_list)
		@echo "$$IPTABLES_RULES" | sudo tee $(iptables_rule)
		@echo "$$IPTABLES_SETUP" | sudo tee $(iptables_setup)
		sudo chmod 700 $(iptables_setup)
		sudo ln -s $(auto_home)* $(bash_auto)
		mounting crypt
		ln -s /mnt/crypt/ssh/ssh.config $(ssh_config)
		nspawn --install
		csv-processing --install
		locking --install
		git config --global core.excludesfiles ~/.config/.gitignore
		git config --global push.default simple

clean:
		sudo rm -f $(iptables_rule)
		sudo rm -f $(iptables_setup)
		rm -f $(ssh_config)
		nspawn --remove
		csv-processing --remove
		locking --remove
		sudo rm -f $(bash_auto)subsystem
		sudo rm -f $(bash_auto)mounting
