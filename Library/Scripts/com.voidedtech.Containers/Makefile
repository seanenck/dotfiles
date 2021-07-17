BIN := bin/
ISO := bin/isox

$(ISO): $(shell find cmd/ -type f)
	go build -o $(ISO) cmd/iso.go

install:
	install -Dm755 $(ISO) $(HOME)/.bin/isox

clean:
	rm -rf $(BIN)
	mkdir -p $(BIN)
