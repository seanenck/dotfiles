APPS   := $(shell find . -mindepth 2 -type f -name "*Makefile*" | xargs dirname)

build:
	for f in $(APPS); do make -C $$f; done
