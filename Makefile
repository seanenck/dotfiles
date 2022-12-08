ABUILD_DIR  := $(HOME)/.abuild
ABUILD_CONF := $(ABUILD_DIR)/abuild.conf

all: abuild
	dotfiles .

abuild:
	@mkdir -p $(ABUILD_DIR)
	@echo 'PACKAGER="Sean Enck <enckse@voidedtech.com>"' > $(ABUILD_CONF)
	@echo 'PACKAGER_PRIVKEY="$(HOME)/.abuild/build@voidedtech.com.rsa"' >> $(ABUILD_CONF)