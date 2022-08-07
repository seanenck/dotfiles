UNTIL := $(shell date +%Y-%m-%d)
SINCE :=

all: download pdfs

download:
ifeq ($(SINCE),)
	$(error "since required")
endif
	cd xword-dl && ./configure --since $(SINCE) --until $(UNTIL)
	cp -r xword-dl/bin puztopdf/

pdfs:
	cd puztopdf && ./configure
