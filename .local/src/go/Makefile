FLAGS   := -ldflags '-linkmode external -extldflags $(LDFLAGS) -s -w' -gcflags=all=-trimpath=$(GOPATH) -asmflags=all=-trimpath=$(GOPATH) -buildmode=pie
SRC     := $(shell find . -type f -name "*.go")
OBJECTS := qrencode-bin md2slides-bin xinitdaemon-bin totp-bin

.PHONY: build lint clean

build: $(OBJECTS) lint

$(OBJECTS): $(SRC)
	go build $(FLAGS) -o $@ cmd/$(shell echo $@ | sed "s/-bin//g")/main.go

clean:
	rm -f $(OBJECTS)

lint:
	@golinter
