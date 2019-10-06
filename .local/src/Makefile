TARGET  := $(HOME)/.local/bin/
DWM     := $(HOME)/workspace/dwm/
POSTFIX := -bin
DIRS    := go rust

.PHONY: $(DIRS) dwm

all: $(DIRS) dwm install

$(DIRS):
	make -C $@

dwm:
	sudo apt install libx11-dev libxinerama-dev libxft-dev libfreetype6-dev
	rm -rf $(DWM)
	git clone git://voidedtech.com/external/dwm $(DWM)
	make -C $(DWM) dwm

install:
	install -Dm755 $(DWM)dwm $(TARGET)dwm$(POSTFIX)
	install -Dm755 go/qrencode $(TARGET)qrencode$(POSTFIX)
	install -Dm755 go/md2slides $(TARGET)md2slides$(POSTFIX)
	install -Dm755 rust/wsw/target/release/wsw $(TARGET)wsw$(POSTFIX)
