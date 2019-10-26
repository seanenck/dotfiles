SRC     := $(shell find . -type f -name "*.go")
OBJECTS := qrencode-bin md2slides-bin xinitdaemon-bin totp-bin

.PHONY: build lint clean

build: $(OBJECTS) lint

$(OBJECTS): $(SRC)
	go build -buildmode=pie -o $@ cmd/$(shell echo $@ | sed "s/-bin//g")/main.go

clean:
	rm -f $(OBJECTS)

lint:
	@golinter
