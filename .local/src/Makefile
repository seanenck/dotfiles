DWM     := $(shell mktemp -d)/dwm/
DIRS    := go rust

.PHONY: $(DIRS) dwm

all: required $(DIRS) dwm

required:
ifeq ($(SCHROOT_CHROOT_NAME),)
	$(error "must be run in schroot")
endif

$(DIRS):
	make -C $@

dwm:
	sudo apt install libx11-dev libxinerama-dev libxft-dev libfreetype6-dev
	rm -rf $(DWM)
	git clone git://voidedtech.com/external/dwm $(DWM)
	make -C $(DWM) dwm
	install -Dm755 $(DWM)dwm $(HOME)/.local/bin/dwm-bin
