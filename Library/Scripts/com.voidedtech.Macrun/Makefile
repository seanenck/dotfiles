BIN     := bin/
ISO     := bin/isox
HOMEBIN := $(HOME)/.bin/

$(ISO): $(shell find cmd/ -type f)
	go build -o $(ISO) cmd/iso.go

install:
	install -Dm755 $(ISO) $(HOMEBIN)isox
	install -Dm755 contain.pl $(HOMEBIN)contain
	for f in $(shell ls scripts/ | cut -d "." -f 1); do install -m755 scripts/$$f.pl $(HOMEBIN)contain-$$f; done
	install -Dm644 contain.bash $(HOME)/.completions/

clean:
	rm -rf $(BIN)
	mkdir -p $(BIN)
