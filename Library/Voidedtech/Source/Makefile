TARGETS  := vm
EXTERNAL := $(HOME)/Git/vftool/build/vftool
BIN      := $(HOME)/.bin
export COMPLETIONS=$(HOME)/.completions/

.PHONY: $(TARGETS) $(EXTERNAL)

all: bin $(TARGETS) $(EXTERNAL)

bin:
	mkdir -p $(BIN)

$(TARGETS):
	cd $@ && cargo build --release
	install -m755 $@/target/release/$@ $(BIN)/$@

$(EXTERNAL):
	install -m755 $@ $(BIN)/$(shell basename $@)
