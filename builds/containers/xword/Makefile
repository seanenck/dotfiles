BUILD  := $(HOME)/.cache/xword/
UNTIL  := 
SOURCE := usa,uni

all: setup process

setup:
	mkdir -p $(BUILD)
	rm -f $(BUILD)*

process:
ifeq ($(UNTIL),)
	$(error "until required")
endif
	BUILD=$(BUILD) UNTIL=$(UNTIL) REMOTES=$(SOURCE) ./configure
	echo "until $(UNTIL), source: $(SOURCE)" >> $(HOME)/.cache/xword.log
