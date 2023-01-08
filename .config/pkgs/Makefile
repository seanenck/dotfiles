TARGETS  := $(shell ls src/)
BIN      := bin/
VARS     := vars
MKPKG    := pkgs.Makefile
DROP     := $(HOME)/.store/pkgs/

include $(BUILDINFO)
OUTPUT   := $(DROP)/build/$(TARGET).$(TAG).tar.xz

all:
	$(error "select a target")

clean:
	rm -rf $(BIN)

_build:
	test ! -e $(OUTPUT) || ! confirm "rebuild $(TARGET)"
	test -e $(TAR) || wget -O $(TAR) $(URL)
	echo $(SUMS) > checksums
	sha256sum -c checksums
	test -d $(SRCDIR) || tar xf $(TAR)
	cd $(SRCDIR) && $(BUILD)
	cp $(VARS) $(SRCDIR)/$(MKPKG)
	cd $(SRCDIR) && make -f $(MKPKG) install DESTDIR=$(HOME)/.bin/ STORE=$(DROP)
	tar cJf $(OUTPUT) $(TAROPT) $(SRCDIR)

_prepare:
	@mkdir -p $(DESTDIR)
	@cp Makefile $(DESTDIR)/
	@cp src/$(TARGET) $(DESTDIR)/$(VARS)
	@cd $(DESTDIR) && mkdir -p src/ && make _build BUILDINFO=$(VARS) 

$(TARGETS):
	@make _prepare DESTDIR=$(BIN)$@ TARGET=$@
