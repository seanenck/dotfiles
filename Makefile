FILES   := $(shell find . -type f -wholename "\./\.*" | cut -d '/' -f 2- | grep -v -E '\.(git/|null)' | grep -v -F -f .null)
DIRS    := $(shell find $(FILES) -type f -exec dirname {} \; | grep -v '^\.$$' | sort -u)
OS      := $(shell uname | tr '[:upper:]' '[:lower:]')

all:
	make install
	test -d $(OS) && cd $(OS) && make -f ../Makefile install

install: _dirs _files

_files:
	@for file in $(FILES) ; do \
		echo $$file; \
		ln -sf $(PWD)/$$file $(HOME)/$$file ; \
	done

_dirs:
	@for dir in $(DIRS) ; do \
		echo $$dir; \
		mkdir -p $(HOME)/$$dir ; \
	done
