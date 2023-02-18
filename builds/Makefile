TARGETS  := $(shell ls src/)
BIN      := $(HOME)/.cache/builds/
VARS     := vars
MKPKG    := pkgs.Makefile
DROP     := $(PKGS_STORE)

include $(BUILDINFO)
OUTPUT   := $(DROP)/build/$(TARGET).$(TAG).tar.xz

all:
	$(error "select a target")

clean:
	rm -rf $(BIN)

_build:
	echo $(TOOLBOX) | grep '^dev$$'
	test ! -e $(OUTPUT) || confirm "rebuild $(TARGET)"
	rm -f $(OUTPUT)
	test -e $(TAR) || wget -O $(TAR) $(URL)
	@echo $(SUMS) > checksums
	sha256sum -c checksums
	test -d $(SRCDIR) || tar xf $(TAR)
	cd $(SRCDIR) && $(BUILD)
	cp $(VARS) $(SRCDIR)/$(MKPKG)
	cd $(SRCDIR) && make -f $(MKPKG) install DESTDIR=$(HOME)/.bin/ STORE=$(DROP)
	tar cvJf $(OUTPUT) $(TAROPT) $(SRCDIR)

_prepare:
	@mkdir -p $(DESTDIR)
	@mkdir -p $(BIN)
	@cp Makefile $(DESTDIR)/
	@cp src/$(TARGET) $(DESTDIR)/$(VARS)
	@cd $(DESTDIR) && mkdir -p src/ && make _build BUILDINFO=$(VARS) 

$(TARGETS):
	@make _prepare DESTDIR=$(BIN)$@ TARGET=$@
