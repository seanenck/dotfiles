OS      := $(shell uname | tr '[:upper:]' '[:lower:]')
FILES   := $(shell find . -type f | grep -F -f $(OS) | cut -d '/' -f 2-)
DIRS    := $(shell find $(FILES) -type f -exec dirname {} \; | grep -v '^\.$$' | sort -u)
CMD     := ln -sf
DESTDIR := $(HOME)
MKDIR   := mkdir -p
DRYRUN  := 0
RUN     :=
ifeq ($(DRYRUN),1)
	RUN = echo
endif

all: _dirs _files
ifeq ($(DRYRUN),1)
	@echo '[DRYRUN] completed'
endif

_files:
	@for file in $(FILES); do \
		echo $(CMD) $$file; \
		$(RUN) $(CMD) $(PWD)/$$file $(DESTDIR)/$$file ; \
	done

_dirs:
	@for dir in $(DIRS); do \
		echo $(MKDIR) $$dir; \
		$(RUN) $(MKDIR) $(DESTDIR)/$$dir ; \
	done
