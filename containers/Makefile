TARGETS := $(shell ls *.Containerfile | cut -d "." -f 1)

all:
	$(error select a target)

$(TARGETS):
	TARGETS="$(TARGETS)" ./configure "$@"
