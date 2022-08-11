UNTIL  := $(shell date +%Y-%m-%d)
SINCE  :=
SOURCE := usa,uni,atl,lat

all: download pdfs

download:
ifeq ($(SINCE),)
	$(error "since required")
endif
	cd xword-dl && ./configure --since $(SINCE) --until $(UNTIL) --remotes $(SOURCE)
	rsync -avc --delete-after xword-dl/bin puztopdf/

pdfs:
	cd puztopdf && ./configure
