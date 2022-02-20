#!/usr/bin/make
NAME  := stable
CACHE := $(HOME)/.cache/apks
PACKS := /opt/packages
CONFS := $(PWD)/.abuild

clean:
	sudo rm -rf $(CONFS)
	sudo chown -R enck:enck $(PWD)
	sudo chown -R enck:enck $(PACKS)

build:
	podman build -f $(HOME)/.env/dotfiles/lib/buildenv.Containerfile -t $(NAME)
	mkdir -p $(CACHE) $(PACKS) $(CONFS)
	cp -rL $(HOME)/.abuild $(PWD)
	podman run -it --rm \
		-v $(CONFS):$(HOME)/.abuild:U \
		-v $(PWD):/apk:U \
		-v $(PACKS):$(HOME)/packages:U \
		-v $(CACHE):/etc/apk/cache \
		$(NAME) bash --login || exit 0
