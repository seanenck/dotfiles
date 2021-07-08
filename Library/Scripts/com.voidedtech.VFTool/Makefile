VFTOOL:= $(HOME)/Library/Caches/vftool

all:
	if [ ! -d $(VFTOOL) ]; then git clone https://github.com/evansm7/vftool $(VFTOOL); fi
	git -C $(VFTOOL) reset --hard
	git -C $(VFTOOL) pull
	git -C $(VFTOOL) apply $(PWD)/vftool.patch
	cd $(VFTOOL) && make
	install -m755 $(VFTOOL)/build/vftool $(HOME)/.bin/vftool
