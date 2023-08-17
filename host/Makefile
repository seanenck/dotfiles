TARGETS := $(shell ls *.Containerfile | cut -d "." -f 1)

all: $(TARGETS)

$(TARGETS):
	TARGETS="$(TARGETS)" ./configure "$@"
