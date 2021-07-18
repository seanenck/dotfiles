VFTOOL:= $(HOME)/Library/Caches/vftool

all:
	if [ ! -d $(VFTOOL) ]; then git clone https://github.com/evansm7/vftool $(VFTOOL); fi
	git -C $(VFTOOL) reset --hard
	git -C $(VFTOOL) pull
	cd $(VFTOOL) && make

install:
	install -m755 $(VFTOOL)/build/vftool $(HOME)/.bin/vftool
