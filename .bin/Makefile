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

iptables_rule = /etc/iptables.rules
iptables_setup = /etc/network/if-pre-up.d/iptables

all: clean install

install:
		@echo "$$IPTABLES_RULES" | sudo tee $(iptables_rule)
		@echo "$$IPTABLES_SETUP" | sudo tee $(iptables_setup)
		sudo chmod 700 $(iptables_setup)

clean:
		sudo rm -f $(iptables_rule)
		sudo rm -f $(iptables_setup)

