SRC     := $(shell find . -type f -name "*.go")
OBJECTS := qrencode-bin md2slides-bin xinitdaemon-bin totp-bin aetig-bin
BINDATA := assets/bindata.go
ASSETS  := $(shell find assets/ -type f | grep -v "\.go")

.PHONY: build lint clean

build: $(OBJECTS) lint

$(BINDATA): $(ASSETS)
	go-bindata -o $(BINDATA) -pkg assets $(ASSETS)

$(OBJECTS): $(SRC) $(BINDATA)
	go build -buildmode=pie -o $@ cmd/$(shell echo $@ | sed "s/-bin//g")/main.go

clean:
	rm -f $(OBJECTS)

lint:
	@golinter
