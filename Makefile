UNAME  := $(shell uname | tr '[:upper:]' '[:lower:]')
FILES  := $(shell find . -type f | cut -d '/' -f 2-)
DIRS   := $(shell find $(FILES) -type f -exec dirname {} \; | grep -v '^\.$$' | sort -u)

.PHONY: linux darwin

$(UNAME):
	cd $(UNAME) && make -f ../Makefile _install

_install: _dirs _files

_files:
	@for file in $(FILES) ; do \
		ln -sf $(PWD)/$$file $(HOME)/$$file ; \
	done

_dirs:
	@for dir in $(DIRS) ; do \
		mkdir -p $(HOME)/$$dir ; \
	done
