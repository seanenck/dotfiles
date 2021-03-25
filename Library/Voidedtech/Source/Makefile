TARGETS := vm
BIN     := $(HOME)/.bin

.PHONY: $(TARGETS)

all: bin $(TARGETS)

bin:
	mkdir -p $(BIN)

$(TARGETS):
	cd $@ && cargo build --release
	install -m755 $@/target/release/$@ $(BIN)/$@
