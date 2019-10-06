TARGET  := $(HOME)/.local/bin/
DWM     := $(HOME)/workspace/dwm/
POSTFIX := -bin

all: build install

build:
	make -C rust
	make -C go
	rm -rf $(DWM)
	git clone enckse:external/dwm $(DWM)
	make -C $(DWM) dwm

install:
	install -Dm755 $(DWM)dwm $(TARGET)dwm$(POSTFIX)
	install -Dm755 go/bin/qrencode $(TARGET)qrencode$(POSTFIX)
	install -Dm755 rust/wsw/target/release/wsw $(TARGET)wsw$(POSTFIX)
