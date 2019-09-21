TARGET := $(HOME)/.local/bin/
DWM    := $(HOME)/store/managed/dwm/

all:
	make -C go
	make -C $(DWM) dwm
	install -Dm755 $(DWM)dwm $(TARGET)dwm-bin
