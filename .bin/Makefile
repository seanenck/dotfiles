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

package_list = alsa-utils chromium cryptsetup debootstrap feh firmware-iwlwifi gawk git i3 i3lock i3status iptables keepass2 lxterminal p7zip pm-utils screen systemd-container unzip wicd wireless-tools wpasupplicant xautolock xbacklight xdm xorg
iptables_rule = /etc/iptables.rules
iptables_setup = /etc/network/if-pre-up.d/iptables

all: clean install

install:
		sudo apt-get install $(package_list)
		@echo "$$IPTABLES_RULES" | sudo tee $(iptables_rule)
		@echo "$$IPTABLES_SETUP" | sudo tee $(iptables_setup)
		sudo chmod 700 $(iptables_setup)
		vscode install

clean:
		sudo rm -f $(iptables_rule)
		sudo rm -f $(iptables_setup)
		vscode remove
