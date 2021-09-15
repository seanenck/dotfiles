TARGETS := bash kitty macports vmr git go macOS mutt vim

.PHONY: $(TARGETS)

all: $(TARGETS)

$(TARGETS):
	stow --target=$(HOME) $@
