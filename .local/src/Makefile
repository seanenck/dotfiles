TARGET  := $(HOME)/.local/bin/
DWM     := $(HOME)/store/managed/dwm/
POSTFIX := -bin

all: build install

build:
	make -C go
	make -C $(DWM) dwm

install:
	install -Dm755 $(DWM)dwm $(TARGET)dwm$(POSTFIX)
	install -Dm755 go/bin/qrencode $(TARGET)qrencode$(POSTFIX)
