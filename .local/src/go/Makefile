BIN     := bin/
FLAGS   := -ldflags '-linkmode external -extldflags $(LDFLAGS) -s -w' -gcflags=all=-trimpath=$(GOPATH) -asmflags=all=-trimpath=$(GOPATH) -buildmode=pie
SRC     := $(shell find . -type f -name "*.go")
FORMAT  := $(BIN)format
OBJECTS := $(BIN)qrencode

build: $(OBJECTS) $(FORMAT)

$(OBJECTS): $(SRC)
	go build $(FLAGS) -o $@ $(shell basename $@ | sed "s|$(BIN)||g")/main.go
	install -Dm755 $@ $(HOME)/.local/$@-bin

clean:
	rm -f $(BINDATA)
	rm -rf $(BIN)
	mkdir -p $(BIN)

$(FORMAT): $(SRC)
	goformatter
	@touch $(FORMAT)
