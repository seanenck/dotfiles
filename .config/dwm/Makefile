DWM   := dwm/
SRC   := git://git.suckless.org/dwm
PATCH := warnings bottomstack warp unused

all: clean patch build

deps:
	sudo apt-get install libxinerama-dev libxft-dev libx11-dev

patch: $(PATCH)

$(PATCH):
	cd $(DWM) && patch -p1 < ../$@.patch

clean:
	rm -rf $(DWM)
	git clone --depth 1 $(SRC)

build:
	cp config.h $(DWM)
	cd $(DWM) && make VERSION=$(shell git -C $(DWM) log --format=%h)

install:
	sudo install -Dm755 $(DWM)dwm /usr/bin/dwm
