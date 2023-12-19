BIN     := bin/
OBJECTS := $(BIN)git-uncommitted $(BIN)git-oclone $(BIN)sys-update
VERSION := $(shell sha256sum *.ts | grep -v "generated.ts" | cut -d " " -f 1 | sha256sum | cut -d " " -f 1 | cut -c 1-7)

all: $(OBJECTS)

generated.ts: generated.ts.template
	cat generated.ts.template | sed "s/VERSION/$(VERSION)/g" > generated.ts

$(OBJECTS): generated.ts *.ts
	deno task $(shell basename $@ | cut -d "." -f 1)
