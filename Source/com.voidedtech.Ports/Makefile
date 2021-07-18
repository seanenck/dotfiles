PORTS       := $(shell cat ports)
PORTS_MUTT  := mutt -pop -imap -smtp +gpgme
PORTS_ISYNC := isync -bdb
LIBRARY     := $(HOME)/Library/Caches/Ports/
PORTS_STAT  := $(LIBRARY)ports
PORTS_PREV  := $(PORTS_STAT).prev

all: bin portinst

bin:
	mkdir -p $(LIBRARY)

.portinst:
	sudo port install $(PORTS)
	sudo port install $(PORTS_MUTT)
	sudo port install $(PORTS_ISYNC)

portinst:
	echo $(PORTS) $(PORTS_MUTT) $(PORTS_ISYNC) | tr ' ' '\n' > $(PORTS_STAT)
	touch $(PORTS_PREV)
	diff -u $(PORTS_PREV) $(PORTS_STAT) || make .portinst
	mv $(PORTS_STAT) $(PORTS_PREV)
