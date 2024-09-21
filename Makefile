OS      := $(shell uname | tr '[:upper:]' '[:lower:]')
FILES   := $(shell find . -type f | grep -f $(OS) | cut -d '/' -f 2-)
DIRS    := $(shell find $(FILES) -type f -exec dirname {} \; | grep -v '^\.$$' | sort -u)
CMD     := ln -sf
DESTDIR := $(HOME)

all: _dirs _files

_files:
	@for file in $(FILES); do \
		echo $(CMD) $$file; \
		$(CMD) $(PWD)/$$file $(DESTDIR)/$$file ; \
	done

_dirs:
	@for dir in $(DIRS); do \
		echo mkdir $$dir; \
		mkdir -p $(DESTDIR)/$$dir ; \
	done
