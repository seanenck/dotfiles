PROFILE := $(DOTFILES_PROFILE)
FILES   := $(shell find . -type f -name "*\.*" | cut -d '/' -f 2-)
DIRS    := $(shell find $(FILES) -type f -exec dirname {} \; | grep -v '^\.$$' | sort -u)
DESTDIR := $(HOME)/.local/
ifeq ($(PROFILE),)
PROFILE := none
endif

.PHONY: dev server

$(PROFILE):
	cd $(PROFILE) && make -f ../Makefile _install
	mkdir -p $(DESTDIR)
	@for file in $(shell find bin/ -type f) ; do \
		ln -sf $(PWD)/$$file $(DESTDIR)$$file ; \
	done

_install: _dirs _files

_files:
	@for file in $(FILES) ; do \
		ln -sf $(PWD)/$$file $(HOME)/$$file ; \
	done

_dirs:
	@for dir in $(DIRS) ; do \
		mkdir -p $(HOME)/$$dir ; \
	done
