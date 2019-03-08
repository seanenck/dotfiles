BIN     := bin/
VERSION := DEVELOP
FLAGS   := -ldflags '-linkmode external -extldflags $(LDFLAGS) -s -w -X main.vers=$(VERSION)' -gcflags=all=-trimpath=$(GOPATH) -asmflags=all=-trimpath=$(GOPATH) -buildmode=pie
DIRS    := wsw
SRC     := $(shell find . -type f -name "*.go")

.PHONY: $(DIRS)

all: clean build format

build: $(DIRS)

$(DIRS):
	cd $@ && go build -o ../$(BIN)$@ $(FLAGS) main.go

clean:
	rm -rf $(BIN)
	mkdir -p $(BIN)

format:
	@echo $(SRC)
	exit $(shell goimports -l $(SRC) | wc -l)

install:
	install -Dm755 bin/wsw /usr/bin/wsw
	install -Dm644 wsw/wsw.service /lib/systemd/system/wsw.service
