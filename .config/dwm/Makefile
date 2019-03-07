DWM := dwm/
SRC := https://git.suckless.org/dwm

all: clean build

deps:
	sudo apt-get install libxinerama-dev libxft-dev libx11-dev

clean:
	rm -rf $(DWM)
	git clone $(SRC)

build:
	cp config.h $(DWM)
	cd $(DWM) && make

install:
	sudo install -Dm755 $(DWM)dwm /usr/bin/dwm
